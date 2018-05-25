-- object: ottoman.cumulative_sale_last_year | type: VIEW --
-- DROP VIEW ottoman.cumulative_sale_last_year;
CREATE VIEW ottoman.cumulative_sale_last_year
 AS SELECT *
 FROM ottoman.cumulative_sale
 WHERE local_date > CURRENT_DATE - INTERVAL '1 year';
-- ddl-end --
