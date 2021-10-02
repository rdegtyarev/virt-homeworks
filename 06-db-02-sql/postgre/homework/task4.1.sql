select c.фамилия, o.наименование from clients c 
left join orders o on o.id = c.заказ 
where c.заказ is not null