-- object: ottoman.transaction_content | type: TABLE --
-- DROP TABLE ottoman.transaction_content;
CREATE TABLE ottoman.transaction_content(
	transaction_id bigint NOT NULL,
  item_nbr bigint,
	unit_sale smallint,
	on_promotion boolean,
	CONSTRAINT pk_transaction_content_id_item_nbr PRIMARY KEY (transaction_id, item_nbr)
);
-- ddl-end --
