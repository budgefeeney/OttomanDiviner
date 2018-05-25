copy
	future_cumulative_sales (
		id,
		local_date,
		store_nbr,
		item_nbr,
		unit_sale,
		on_promotion
	)
	from '/tmp/train-2018.csv'
	csv header;

insert into future_promotions
	(id, local_date, store_nbr, item_nbr, on_promotion)
	select id, local_date, store_nbr,item_nbr,on_promotion
		from cumulative_sales;

copy
	items (
		item_nbr,
		family,
		class,
		perishable
	)
	from '/tmp/items.csv'
	csv header;

copy
	stores (
		store_nbr,
		city,
		state,
		type,
		cluster
	)
	from '/tmp/stores.csv'
	csv header;
