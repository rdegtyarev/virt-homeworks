EXPLAIN SELECT c.фамилия, o.наименование FROM clients c 
LEFT JOIN orders o ON o.id = c.заказ 
WHERE c.заказ IS NOT NULL