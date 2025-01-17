# Домашнее задание к занятию "5.4. Практические навыки работы с Docker"

## Задача 1 

В данном задании вы научитесь изменять существующие Dockerfile, адаптируя их под нужный инфраструктурный стек.

Измените базовый образ предложенного Dockerfile на Arch Linux c сохранением его функциональности.

```text
FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:vincent-c/ponysay && \
    apt-get update
 
RUN apt-get install -y ponysay

ENTRYPOINT ["/usr/bin/ponysay"]
CMD ["Hey, netology”]
```

Для получения зачета, вам необходимо предоставить:
- Написанный вами Dockerfile
- Скриншот вывода командной строки после запуска контейнера из вашего базового образа
- Ссылку на образ в вашем хранилище docker-hub  

### Решение  
Dockerfile
```dockerfile
FROM archlinux
RUN yes | pacman -Sy ponysay
ENTRYPOINT ["/usr/bin/ponysay"]
CMD ["Hey, netology"]
```  
Результат выполнения:  
![Результат выполнения](https://github.com/rdegtyarev/virt-homeworks/blob/master/05-virt-04-docker-practical-skills/task-1/ponysay.png)

Обубликован в dockerhub

>docker run rdegtyarev/netology-hw-5.4.1

---

## Задача 2 

В данной задаче вы составите несколько разных Dockerfile для проекта Jenkins, опубликуем образ в `dockerhub.io` и посмотрим логи этих контейнеров.

- Составьте 2 Dockerfile:

    - Общие моменты:
        - Образ должен запускать [Jenkins server](https://www.jenkins.io/download/)
        
    - Спецификация первого образа:
        - Базовый образ - [amazoncorreto](https://hub.docker.com/_/amazoncorretto)
        - Присвоить образу тэг `ver1` 
    
    - Спецификация второго образа:
        - Базовый образ - [ubuntu:latest](https://hub.docker.com/_/ubuntu)
        - Присвоить образу тэг `ver2` 

- Соберите 2 образа по полученным Dockerfile
- Запустите и проверьте их работоспособность
- Опубликуйте образы в своём dockerhub.io хранилище

Для получения зачета, вам необходимо предоставить:
- Наполнения 2х Dockerfile из задания
- Скриншоты логов запущенных вами контейнеров (из командной строки)
- Скриншоты веб-интерфейса Jenkins запущенных вами контейнеров (достаточно 1 скриншота на контейнер)
- Ссылки на образы в вашем хранилище docker-hub

### Решение  

#### Dockerfile 1
- Наполнения 2х Dockerfile из задания  

```dockerfile
FROM amazoncorretto

ARG http_port=8080
ARG agent_port=50000

RUN yum -y update && yum install -y wget
RUN wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo \
    && rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key \
    && amazon-linux-extras install -y epel java-openjdk11 \
    && yum install -y jenkins

EXPOSE ${http_port}
EXPOSE ${agent_port}

CMD [ "java", "-jar",  "/usr/lib/jenkins/jenkins.war"]
```
- Скриншоты логов запущенных вами контейнеров (из командной строки)
![Результат выполнения](https://github.com/rdegtyarev/virt-homeworks/blob/master/05-virt-04-docker-practical-skills/task-2/docker1/logs.png)
- Скриншоты веб-интерфейса Jenkins запущенных вами контейнеров (достаточно 1 скриншота на контейнер)
![Результат выполнения](https://github.com/rdegtyarev/virt-homeworks/blob/master/05-virt-04-docker-practical-skills/task-2/docker1/web.png)
- Ссылки на образы в вашем хранилище docker-hub 
```bash 
docker pull rdegtyarev/netology-hw-5.4.2:ver1
```

#### Dockerfile 2
- Наполнения 2х Dockerfile из задания  

```dockerfile
FROM ubuntu:latest

RUN apt-get update && apt-get install -y wget gnupg2 openjdk-11-jdk && rm -rf /var/lib/apt/lists/*

ARG http_port=8080
ARG agent_port=50000

RUN wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add - \
    && sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list' \
    && apt-get update && apt-get install -y jenkins

EXPOSE ${http_port}

EXPOSE ${agent_port}

ENTRYPOINT service jenkins start && bash
```
- Скриншоты логов запущенных вами контейнеров (из командной строки)
![Результат выполнения](https://github.com/rdegtyarev/virt-homeworks/blob/master/05-virt-04-docker-practical-skills/task-2/docker2/logs.png)
- Скриншоты веб-интерфейса Jenkins запущенных вами контейнеров (достаточно 1 скриншота на контейнер)
![Результат выполнения](https://github.com/rdegtyarev/virt-homeworks/blob/master/05-virt-04-docker-practical-skills/task-2/docker2/web.png)
- Ссылки на образы в вашем хранилище docker-hub 
```bash 
docker pull rdegtyarev/netology-hw-5.4.2:ver2
```

## Задача 3 

В данном задании вы научитесь:
- объединять контейнеры в единую сеть
- исполнять команды "изнутри" контейнера

Для выполнения задания вам нужно:
- Написать Dockerfile: 
    - Использовать образ https://hub.docker.com/_/node как базовый
    - Установить необходимые зависимые библиотеки для запуска npm приложения https://github.com/simplicitesoftware/nodejs-demo
    - Выставить у приложения (и контейнера) порт 3000 для прослушки входящих запросов  
    - Соберите образ и запустите контейнер в фоновом режиме с публикацией порта

- Запустить второй контейнер из образа ubuntu:latest 
- Создайть `docker network` и добавьте в нее оба запущенных контейнера
- Используя `docker exec` запустить командную строку контейнера `ubuntu` в интерактивном режиме
- Используя утилиту `curl` вызвать путь `/` контейнера с npm приложением  

Для получения зачета, вам необходимо предоставить:
- Наполнение Dockerfile с npm приложением
- Скриншот вывода вызова команды списка docker сетей (docker network cli)
- Скриншот вызова утилиты curl с успешным ответом


### Решение  
- Наполнение Dockerfile с npm приложением
```docker
FROM node
WORKDIR /var/www
RUN git clone https://github.com/simplicitesoftware/nodejs-demo.git

WORKDIR /var/www/nodejs-demo
EXPOSE 3000

RUN npm install

ENTRYPOINT npm start --host 0.0.0.0
```

- Скриншот вывода вызова команды списка docker сетей (docker network cli) 
Создана сеть netotoly-hw-5.4.2, добавлены контейнеры app (с node), и client (ubuntu).  
![Результат выполнения](https://github.com/rdegtyarev/virt-homeworks/blob/master/05-virt-04-docker-practical-skills/task-3/docker1/network.png)
- Скриншот вызова утилиты curl с успешным ответом  
В сети резолвится по имени контейнера (app), делаем curl по имени.  
![Результат выполнения](https://github.com/rdegtyarev/virt-homeworks/blob/master/05-virt-04-docker-practical-skills/task-3/docker1/curl.png)

---
