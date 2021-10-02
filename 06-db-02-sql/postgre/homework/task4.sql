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