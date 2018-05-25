-- object: ottoman.cumulative_sale_pk_seq | type: SEQUENCE --
-- DROP SEQUENCE ottoman.cumulative_sale_pk_seq;
CREATE SEQUENCE ottoman.cumulative_sale_pk_seq
	INCREMENT BY 1
	MINVALUE 0
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;

-- object: ottoman.cumulative_sale | type: TABLE --
-- DROP TABLE ottoman.cumulative_sale;
CREATE TABLE ottoman.cumulative_sale(
	id bigint NOT NULL DEFAULT nextval('ottoman.cumulative_sale_pk_seq'::regclass),
  store_nbr bigint,
  item_nbr bigint,
	local_date date,
	unit_sale bigint, --float?
	on_promotion boolean,
	CONSTRAINT pk_cumulative_sale_id PRIMARY KEY (id)
);
-- ddl-end --
