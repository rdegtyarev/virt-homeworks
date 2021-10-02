DO
$BODY$
DECLARE
    updatejson json := '[{"fio": "Иванов Иван Иванович", "order": "Книга"}, 
{"fio": "Петров Петр Петрович", "order": "Монитор"}, 
{"fio": "Иоганн Себастьян Бах", "order": "Гитара"}]';
    i json;
BEGIN
  FOR i IN SELECT * FROM json_array_elements(updatejson)
  LOOP
  	UPDATE clients 
	  SET заказ = orders_tbl.id
	  FROM (SELECT id FROM orders WHERE наименование = i->>'order') AS orders_tbl
	  WHERE фамилия = i->>'fio';
  END LOOP;
END;
$BODY$ language plpgsql