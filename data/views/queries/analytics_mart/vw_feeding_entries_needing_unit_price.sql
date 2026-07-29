DROP VIEW IF EXISTS analytics_mart.vw_feeding_entries_needing_unit_price;

CREATE VIEW analytics_mart.vw_feeding_entries_needing_unit_price AS
WITH producao AS (
    SELECT
        s.id_stock_control_item,
        s.source_reference_id   AS id_production,
        p.id_property,
        p.id_planted_culture,
        p.id_culture_harvest_product,
        p.culture_name,
        p.harvest_product_name,
        p.reference_month       AS production_reference_month,
        p.planted_at,
        p.harvest_date,
        p.production              AS quantidade_produzida
    FROM "StockControlMovement" s
    JOIN analytics_mart.vw_forage_production p
      ON s.source_reference_id = p.id_production::text
    WHERE s.source_module = 'PLANTED_CULTURE_PRODUCTION'
      AND s.movement_type = 'ENTRY'
),
consumo AS (
    SELECT
        s.id_stock_control_item,
        s.source_reference_id AS id_expense_entry
    FROM "StockControlMovement" s
    WHERE s.source_module = 'EXPENSES'
      AND s.movement_type = 'EXIT'
)
SELECT
    prod.id_property,
	f.id_expense_entry,
    prod.id_production,
    prod.id_planted_culture,
    prod.id_culture_harvest_product,
	prod.culture_name,
    prod.harvest_product_name,
 	DATE_TRUNC('month', f.created_at)::date AS consumption_reference_month,
    f.consumed_quantity,
    f.unit_price               AS current_unit_price
    
FROM consumo c
JOIN producao prod
  ON c.id_stock_control_item = prod.id_stock_control_item
JOIN "FeedingExpenseEntry" f
  ON c.id_expense_entry = f.id_expense_entry::text
WHERE f.unit_price = 0
  AND f.id_property = prod.id_property;