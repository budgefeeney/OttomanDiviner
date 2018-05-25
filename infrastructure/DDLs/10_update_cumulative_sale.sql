-- object: ottoman.update_cumulative_sale_function | type: FUNCTION --
-- DROP FUNCTION ottoman.update_cumulative_sale_function;
CREATE OR REPLACE FUNCTION ottoman.update_cumulative_sale_function()
  RETURNS trigger AS
$BODY$
DECLARE
  my_local_date date;
  my_store_nbr bigint;
BEGIN
  SELECT local_date INTO my_local_date
    FROM ottoman.transaction
    WHERE transaction_id = NEW.transaction_id;
  SELECT store_nbr INTO my_store_nbr
    FROM ottoman.transaction
    WHERE transaction_id = NEW.transaction_id;
  INSERT INTO ottoman.cumulative_sale(store_nbr, item_nbr,local_date, unit_sale, on_promotion)
    VALUES(my_store_nbr, NEW.item_nbr, my_local_date,NEW.unit_sale, NEW.on_promotion);
  RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

-- object: ottoman.transaction_content_trg | type: TRIGGER --
-- DROP TRIGGER ottoman.transaction_content_trg;
CREATE TRIGGER transaction_content_trg
  AFTER INSERT
  ON ottoman.transaction_content
  FOR EACH ROW
  EXECUTE PROCEDURE ottoman.update_cumulative_sale_function();

-- ddl-end --

--this store, in this date sold this many hats
