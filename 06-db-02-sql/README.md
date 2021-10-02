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

Для удобства создал отдельный volume 'homework' для запуска SQL-запросов в контейнере.
Создаем [SQL-запрос](https://github.com/rdegtyarev/virt-homeworks/blob/master/06-db-02-sql/postgre/homework/task2.sql)
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

- итоговый список БД после выполнения пунктов выше
> docker-compose exec db psql -U postgres -l
```bash
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
> docker-compose exec db psql -U test-admin-user test_db -c "\d+ orders" -c "\d+ clients"
```bash
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
Создаем [SQL-запрос](https://github.com/rdegtyarev/virt-homeworks/blob/master/06-db-02-sql/postgre/homework/task2.1.sql)
```sql
SELECT table_catalog, grantee, string_agg(privilege_type, ', ')
FROM information_schema.role_table_grants 
WHERE table_catalog='test_db' and table_schema = 'public'
group by table_catalog, grantee
```
Запускаем:
>docker-compose exec db psql -U test-admin-user test_db -f /homework/task2.1.sql

```bash
 table_catalog |     grantee      |                                                          string_agg                                                          
---------------+------------------+------------------------------------------------------------------------------------------------------------------------------
 test_db       | test-admin-user  | INSERT, SELECT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER, INSERT, SELECT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
 test_db       | test-simple-user | INSERT, INSERT, SELECT, UPDATE, DELETE, SELECT, UPDATE, DELETE
 ```


- список пользователей с правами над таблицами test_db
> docker-compose exec db psql -U test-admin-user test_db -c "\dp"
```bash
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
Создаем [SQL-запрос](https://github.com/rdegtyarev/virt-homeworks/blob/master/06-db-02-sql/postgre/homework/task3.sql)

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
Создаем [SQL-запрос](https://github.com/rdegtyarev/virt-homeworks/blob/master/06-db-02-sql/postgre/homework/task3.1.sql)
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
Запускаем
> docker-compose exec db psql -U test-admin-user test_db -f /homework/task3.1.sql
```bash
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

### Решение
Создаем [SQL-запрос](https://github.com/rdegtyarev/virt-homeworks/blob/master/06-db-02-sql/postgre/homework/task4.sql) для связи таблиц.

```sql
DO
$BODY$
DECLARE
    omgjson json := '[{"fio": "Иванов Иван Иванович", "order": "Книга"}, 
{"fio": "Петров Петр Петрович", "order": "Монитор"}, 
{"fio": "Иоганн Себастьян Бах", "order": "Гитара"}]';
    i json;
BEGIN
  FOR i IN SELECT * FROM json_array_elements(omgjson)
  loop
  	update clients 
	set заказ = orders_tbl.id
	from (select id from orders where наименование = i->>'order') as orders_tbl
	where фамилия = i->>'fio';
  END LOOP;
END;
$BODY$ language plpgsql
```
Запускаем:
>docker-compose exec db psql -U test-admin-user test_db -f /homework/task4.sql

Создаем [SQL-запрос](https://github.com/rdegtyarev/virt-homeworks/blob/master/06-db-02-sql/postgre/homework/task4.1.sql) для выдачи всех пользователей с заказами.
```sql
select c.фамилия, o.наименование from clients c 
left join orders o on o.id = c.заказ 
where c.заказ is not null
```
Запускаем:
>docker-compose exec db psql -U test-admin-user test_db -f /homework/task4.1.sql
```bash
       фамилия        | наименование 
----------------------+--------------
 Иванов Иван Иванович | Книга
 Петров Петр Петрович | Монитор
 Иоганн Себастьян Бах | Гитара
(3 rows)
```


## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

### Решение
Создаем [SQL-запрос](https://github.com/rdegtyarev/virt-homeworks/blob/master/06-db-02-sql/postgre/homework/task5.sql) для выполнения EXPLAIN
```sql
EXPLAIN SELECT c.фамилия, o.наименование FROM clients c 
LEFT JOIN orders o ON o.id = c.заказ 
WHERE c.заказ IS NOT NULL
```
Запускаем:
> docker-compose exec db psql -U test-admin-user test_db -f /homework/task5.sql
```bash
                               QUERY PLAN                                
-------------------------------------------------------------------------
 Hash Left Join  (cost=13.15..33.41 rows=806 width=548)
   Hash Cond: (c."заказ" = o.id)
   ->  Seq Scan on clients c  (cost=0.00..18.10 rows=806 width=36)
         Filter: ("заказ" IS NOT NULL)
   ->  Hash  (cost=11.40..11.40 rows=140 width=520)
         ->  Seq Scan on orders o  (cost=0.00..11.40 rows=140 width=520)
(6 rows)
```
Отображена оценка стоимости запроса с учетом cвящи left join.

---

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

### Решение
Сделал полный бэкап
> docker-compose exec db pg_dumpall -U postgres  > ./backup/backup
Восстановление в другом контейнере
> docker-compose exec backup_db psql -U postgres -f ./backup/backup

Если нужно забекапить и восстановить одну таблицу, можно воспользоваться командой pg_dump, но понадобится предварительно в новом контейнере создать пустую БД и соотвествующих пользователей.
---

## Порядок выполнения скриптов
- docker-compose exec db psql -U postgres -f /homework/task2.sql (создание ДБ и таблиц)
- docker-compose exec db psql -U test-admin-user test_db -f /homework/task3.sql (наполение таблиц, в целевой дб и под пользователем test-admin-user)
- docker-compose exec db psql -U test-admin-user test_db -f /homework/task4.sql (создание связей)
