# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch. 

### Решение
- текст Dockerfile манифеста
```Dockerfile
FROM centos:7

ARG http_port=9200
ARG transport_port=9300

RUN yum -y update && yum install -y wget perl-Digest-SHA

RUN groupadd elastic && \
useradd elastic -g elastic

WORKDIR /opt

RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.15.1-linux-x86_64.tar.gz \
&& wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.15.1-linux-x86_64.tar.gz.sha512 \
&& shasum -a 512 -c elasticsearch-7.15.1-linux-x86_64.tar.gz.sha512 \
&& tar -xzf elasticsearch-7.15.1-linux-x86_64.tar.gz

EXPOSE ${http_port}
EXPOSE ${transport_port}

WORKDIR /opt/elasticsearch-7.15.1
COPY ./config/elasticsearch.yml ./config/
COPY ./config/jvm.options ./config/

RUN chown -R elastic:elastic /opt/elasticsearch-7.15.1 /var/lib

USER elastic

CMD ["./bin/elasticsearch"]
```  

- ссылку на образ в репозитории dockerhub  
https://hub.docker.com/repository/docker/rdegtyarev/netology-hw-6.5  

- ответ `elasticsearch` на запрос пути `/` в json виде  

```json
{
  "name" : "netology_test",
  "cluster_name" : "netology",
  "cluster_uuid" : "jgX6OlWxQOSsM-ztGBBbkw",
  "version" : {
    "number" : "7.15.1",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "83c34f456ae29d60e94d886e455e6a3409bba9ed",
    "build_date" : "2021-10-07T21:56:19.031608185Z",
    "build_snapshot" : false,
    "lucene_version" : "8.9.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```
---

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

### Решение  

>Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.
```
green  open .geoip_databases b20xl_zHTb2wJr4MM617fQ 1 0 41 0 39.6mb 39.6mb
green  open ind-1            5EdkQ_MKQgq3b4RDQXL65Q 1 0  0 0   208b   208b
yellow open ind-3            a-MPHloPQ6OLRzqVMpc3Lw 3 2  0 0   624b   624b
yellow open ind-2            nXo7QMPLQtemhfSZe-q4rw 2 1  0 0   416b   416b
```  

>Получите состояние кластера `elasticsearch`, используя API.
```json
{
    "cluster_name": "netology",
    "status": "yellow",
    "timed_out": false,
    "number_of_nodes": 1,
    "number_of_data_nodes": 1,
    "active_primary_shards": 7,
    "active_shards": 7,
    "relocating_shards": 0,
    "initializing_shards": 0,
    "unassigned_shards": 8,
    "delayed_unassigned_shards": 0,
    "number_of_pending_tasks": 0,
    "number_of_in_flight_fetch": 0,
    "task_max_waiting_in_queue_millis": 0,
    "active_shards_percent_as_number": 46.666666666666664
}
```  

>Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?  
Потому что кластер на одной ноде, индексы для которых указано количество реплик не реплицировались на другие ноды.

>Удалите все индексы.
DELETE http://localhost:9200/_all
---

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---
