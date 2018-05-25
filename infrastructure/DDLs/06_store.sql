-- object: ottoman.store | type: TABLE --
-- DROP TABLE ottoman.store;
CREATE TABLE ottoman.store(
	store_nbr bigint NOT NULL,
	city text,
	state text,
	type text,
	cluster smallint,
	CONSTRAINT pk_store_nbr PRIMARY KEY (store_nbr)
);
-- ddl-end --
