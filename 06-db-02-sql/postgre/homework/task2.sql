CREATE USER "test-admin-user" WITH CREATEDB CREATEROLE LOGIN encrypted password 'adminpassword';
b
CREATE DATABASE test_db WITH OWNER = "test-admin-user" ENCODING = 'UTF8';

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

CREATE USER "test-simple-user" WITH encrypted password 'userpassword';
GRANT SELECT, INSERT, UPDATE, DELETE ON orders, clients TO "test-simple-user";e