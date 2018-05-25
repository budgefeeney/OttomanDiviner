


copy
	future_cumulative_sales (
		id,
		date,
		store_nbr,
		item_nbr,
		unit_sales,
		onpromotion

	)
from
	'/tmp/train-2018.csv'
csv header

-- drop table if exists future_promotions;
--
-- create table if not exists future_promotions (
-- 	id int primary key,
-- 	date date,
-- 	store_nbr int,
-- 	item_nbr int,
-- 	onpromotion boolean
-- );

insert into future_promotions (id, date, store_nbr, item_nbr, onpromotion) select id, date, store_nbr,item_nbr,onpromotion from cumulative_sales;

	--drop table if exists stores;

	-- create table if not exists stores (
	-- 	item_nbr int primary key,
	-- 	family varchar(120),
	-- 	class int,
	-- 	perishable boolean
	-- );

	copy
		items (
			item_nbr,family,class,perishable


		)
	from
		'/tmp/items.csv'
	csv header;

	drop table if exists stores;

create table if not exists stores (
	store_nbr int primary key,
	city varchar(120),
	state varchar(120),
	type char(1),
	cluster int
);

copy
	stores (
		store_nbr,city,state,type,cluster
	)
from
	'/tmp/stores.csv'
csv header;
