CREATE OR REPLACE FUNCTION count_rows(_tbl regclass, OUT result integer) AS
$func$
BEGIN
   EXECUTE format('SELECT count(*) FROM %s', _tbl)
   INTO result;
END
$func$  LANGUAGE plpgsql;  

select table_name as "Имя таблицы", count_rows(table_name::text) AS "Количество строк" from information_schema.tables
where table_schema = 'public'