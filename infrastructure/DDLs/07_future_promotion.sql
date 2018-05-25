-- object: ottoman.future_promotion_id_pk_seq | type: SEQUENCE --
-- DROP SEQUENCE ottoman.future_promotion_id_pk_seq;
CREATE SEQUENCE ottoman.future_promotion_id_pk_seq
	INCREMENT BY 1
	MINVALUE 0
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;


-- object: ottoman.future_promotion | type: TABLE --
-- DROP TABLE ottoman.future_promotion;
CREATE TABLE ottoman.future_promotion(
	promotion_id bigint NOT NULL DEFAULT nextval('ottoman.future_promotion_id_pk_seq'::regclass),
	store_nbr bigint NOT NULL,
	item_nbr bigint NOT NULL,
	local_date date,
	on_promotion boolean,
	CONSTRAINT pk_future_promotion_id PRIMARY KEY (promotion_id)
);
-- ddl-end --
