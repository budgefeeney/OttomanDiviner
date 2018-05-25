-- object: ottoman.item | type: TABLE --
-- DROP TABLE ottoman.item;
CREATE TABLE ottoman.item(
	item_nbr bigint NOT NULL,
	family text,
	class bigint,
	perishable smallint,
	CONSTRAINT pk_item_nbr PRIMARY KEY (item_nbr)
);
-- ddl-end --
