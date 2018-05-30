\copy ottoman.cumulative_sale_future from /home/cbalducci/GITHUB/favorita/train-2018.csv csv header

\copy	ottoman.item from /home/cbalducci/GITHUB/favorita/items.csv csv header

\copy ottoman.store from /home/cbalducci/GITHUB/favorita/stores.csv csv header

insert into ottoman.future_promotion
	(promotion_id, local_date, store_nbr, item_nbr, on_promotion)
	select id, local_date, store_nbr,item_nbr,on_promotion
		from ottoman.cumulative_sale;
