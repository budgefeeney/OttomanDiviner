-- object: ottoman.transaction_pk_seq | type: SEQUENCE --
-- DROP SEQUENCE ottoman.transaction_pk_seq;
CREATE SEQUENCE ottoman.transaction_pk_seq
	INCREMENT BY 1
	MINVALUE 0
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;

-- object: ottoman.transaction | type: TABLE --
-- DROP TABLE ottoman.transaction;
CREATE TABLE ottoman.transaction(
	transaction_id bigint NOT NULL DEFAULT nextval('ottoman.transaction_pk_seq'::regclass),
  store_nbr bigint,
	local_date date,
	CONSTRAINT pk_transaction_id_store_nbr PRIMARY KEY (transaction_id, store_nbr)
);
-- ddl-end --
