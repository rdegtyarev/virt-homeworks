# Домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.  

### Решение
```yaml
version: '3.2'
services:
  db:
    image: postgres:12
    restart: always
    volumes:
      - ./data:/var/lib/postgresql/data/
      - ./backup:/backup
      - ./homework:/homework
    environment:
      - POSTGRES_PASSWORD=password
    ports:
      - 5432:5432
```

---

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

### Решение  
#### Подготовка
Создаем скрипт (положил в отдельный volume '/homework/task2.sql')
```sql
CREATE USER "test-admin-user" WITH encrypted password 'adminpassword';

CREATE DATABASE test_db WITH OWNER = "test-admin-user" ENCODING = 'UTF8';

GRANT SELECT, INSERT, UPDATE, DELETE ON DATABASE test_db TO "test-admin-user";

\c test_db test-admin-user

CREATE TABLE orders (
	"id" serial NOT NULL,
	"наименование" varchar(255) NULL,
	"цена" integer null,
	PRIMARY KEY (id)
);

CREATE TABLE public.clients (
	id serial not NULL,
	фамилия varchar NULL,
	"страна проживания" varchar NULL,
	заказ integer NULL,
	FOREIGN KEY (заказ) REFERENCES public.orders(id)
);
CREATE INDEX clients_страна_проживания_idx ON public.clients ("страна проживания");

```
Запускаем
>docker-compose exec db psql -U postgres -f /homework/task2.sql

#### Ответы
Приведите:
- итоговый список БД после выполнения пунктов выше
```bash
docker-compose exec db psql -U postgres -l

                                    List of databases
   Name    |      Owner      | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+-----------------+----------+------------+------------+-----------------------
 postgres  | postgres        | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres        | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |                 |          |            |            | postgres=CTc/postgres
 template1 | postgres        | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |                 |          |            |            | postgres=CTc/postgres
 test_db   | test-admin-user | UTF8     | en_US.utf8 | en_US.utf8 | 
(4 rows)
```
- описание таблиц (describe)  

```bash
docker-compose exec db psql -U test-admin-user test_db -c "\d+ orders" -c "\d+ clients"
                                                           Table "public.orders"
    Column    |          Type          | Collation | Nullable |              Default               | Storage  | Stats target | Description 
--------------+------------------------+-----------+----------+------------------------------------+----------+--------------+-------------
 id           | integer                |           | not null | nextval('orders_id_seq'::regclass) | plain    |              | 
 наименование | character varying(255) |           |          |                                    | extended |              | 
 цена         | integer                |           |          |                                    | plain    |              | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "заказ" FOREIGN KEY (id) REFERENCES orders(id)
Access method: heap

                                                           Table "public.clients"
      Column       |       Type        | Collation | Nullable |               Default               | Storage  | Stats target | Description 
-------------------+-------------------+-----------+----------+-------------------------------------+----------+--------------+-------------
 id                | integer           |           | not null | nextval('clients_id_seq'::regclass) | plain    |              | 
 фамилия           | character varying |           |          |                                     | extended |              | 
 страна проживания | character varying |           |          |                                     | extended |              | 
Indexes:
    "страна_проживания_idx" btree ("страна проживания")
Foreign-key constraints:
    "заказ" FOREIGN KEY (id) REFERENCES orders(id)
Access method: heap
```


- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db  

Приложен ./homework/task2.1.sql
```sql
SELECT table_catalog, grantee, string_agg(privilege_type, ', ')
FROM information_schema.role_table_grants 
WHERE table_catalog='test_db' and table_schema = 'public'
group by table_catalog, grantee
```
```bash
docker-compose exec db psql -U test-admin-user test_db -f /homework/task2.1.sql
 table_catalog |     grantee      |                                                          string_agg                                                          
---------------+------------------+------------------------------------------------------------------------------------------------------------------------------
 test_db       | test-admin-user  | INSERT, SELECT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER, INSERT, SELECT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
 test_db       | test-simple-user | INSERT, INSERT, SELECT, UPDATE, DELETE, SELECT, UPDATE, DELETE
 ```


- список пользователей с правами над таблицами test_db
```bash
docker-compose exec db psql -U test-admin-user test_db -c "\dp"
                                                Access privileges
 Schema |      Name      |   Type   |              Access privileges              | Column privileges | Policies 
--------+----------------+----------+---------------------------------------------+-------------------+----------
 public | clients        | table    | "test-admin-user"=arwdDxt/"test-admin-user"+|                   | 
        |                |          | "test-simple-user"=arwd/"test-admin-user"   |                   | 
 public | clients_id_seq | sequence |                                             |                   | 
 public | orders         | table    | "test-admin-user"=arwdDxt/"test-admin-user"+|                   | 
        |                |          | "test-simple-user"=arwd/"test-admin-user"   |                   | 
 public | orders_id_seq  | sequence |                                             |                   | 
(4 rows)
```
---

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.
### Решение

Создаем скрипт наполнения таблиц (разместил ./homework/task3.sql):
```sql
INSERT INTO orders ("наименование", "цена") 
VALUES ('Шоколад', 10), 
	('Принтер', 3000), 
	('Книга', 500), 
	('Монитор', 7000), 
	('Гитара', 4000);

INSERT INTO clients ("фамилия", "страна проживания")
VALUES 	('Иванов Иван Иванович', 'USA'), 
	('Петров Петр Петрович', 'Canada'), 
	('Иоганн Себастьян Бах', 'Japan'), 
	('Ронни Джеймс Дио', 'Russia'), 
	('Ritchie Blackmore', 'Russia');
```  
Запускаем
> docker-compose exec db psql -U test-admin-user test_db -f /homework/task3.sql

Запрос на количество записей. Использовал функцию, можно и проще, по запросу count(*) по каждой таблице, но так интереснее.

```sql
CREATE OR REPLACE FUNCTION count_rows(_tbl regclass, OUT result integer) AS
$func$
BEGIN
   EXECUTE format('SELECT count(*) FROM %s', _tbl)
   INTO result;
END
$func$  LANGUAGE plpgsql;  

select table_name as "Имя таблицы", count_rows(table_name::text) AS "Количество строк" from information_schema.tables
where table_schema = 'public'
```

Результат выполнения:  
```bash
docker-compose exec db psql -U test-admin-user test_db -f /homework/task3.1.sql
CREATE FUNCTION
 Имя таблицы | Количество строк 
-------------+------------------
 orders      |                5
 clients     |                5
(2 rows)
```

---

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказк - используйте директиву `UPDATE`.

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

---