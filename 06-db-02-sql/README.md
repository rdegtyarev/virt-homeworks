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
  adminer:
    image: adminer
    restart: always
    ports:
      - 8080:8080
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
Формируем скрипт (положил в отдельный volume '/homework')
```sql
CREATE USER "test-admin-user" WITH encrypted password 'adminpassword';

CREATE DATABASE test_db WITH OWNER = "test-admin-user" ENCODING = 'UTF8';

\c test_db 

CREATE TABLE orders (
	"id" serial NOT NULL,
	"наименование" varchar(255) NULL,
	"цена" integer null,
	PRIMARY KEY (id)
);

CREATE TABLE clients (
	"id" serial NOT NULL,
	"фамилия" varchar NULL,
	"страна проживания" varchar NULL,
	CONSTRAINT "заказ" FOREIGN KEY (id) REFERENCES orders(id)
);
CREATE INDEX страна_проживания_idx ON clients ("страна проживания");
```
Выполняем скрипт: 

```bash
docker-compose exec db psql -U postgres -f /homework/task2.sql
```
#### Задачи
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

Можно использовать information_schema
Скрипт (~/postgre/homework/task2.1.sql)
```sql
\c test_db 

SELECT 
   table_catalog,
   table_name, 
   column_name, 
   data_type 
FROM 
   information_schema.columns
WHERE 
   table_name = 'orders';

SELECT 
   table_catalog,
   table_name, 
   column_name, 
   data_type 
FROM 
   information_schema.columns
WHERE 
   table_name = 'clients';
```
Запускаем:
```bash
docker-compose exec db psql -U postgres -f /homework/task2.1.sql

You are now connected to database "test_db" as user "postgres".
 table_catalog | table_name | column_name  |     data_type     
---------------+------------+--------------+-------------------
 test_db       | orders     | id           | integer
 test_db       | orders     | наименование | character varying
 test_db       | orders     | цена         | integer
(3 rows)

 table_catalog | table_name |    column_name    |     data_type     
---------------+------------+-------------------+-------------------
 test_db       | clients    | id                | integer
 test_db       | clients    | фамилия           | character varying
 test_db       | clients    | страна проживания | character varying
(3 rows)
```


- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db

- список пользователей с правами над таблицами test_db

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