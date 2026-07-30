/*
VIEW: analytics_int.vw_int_feeding_entries_needing_unit_price

Finalidade:
Camada intermediária que conecta movimentações de estoque de consumo de alimentação
(EXPENSES/EXIT) com entradas de produção de culturas (PLANTED_CULTURE_PRODUCTION/ENTRY),
aplicando filtros de lançamentos ativos e conversão de unidades para kg.

Granularidade:
Uma linha por item de despesa de alimentação (id_expense_entry).

Fontes principais:
- public.StockControlMovement
- public.FeedingExpenseEntry
- public.ExpenseEntry

Regras de negócio:
- Considera apenas lançamentos ativos (ExpenseEntry.is_active = true).
- Exclui operações de armazenamento (ESTOCAR).
- Converte quantidade consumida para kg (toneladas * 1000, saca * 25).
- Filtra lançamentos com unit_price = 0 para posterior precificação por custo de produção.

Forma de consulta:
SELECT * FROM analytics_int.vw_int_feeding_entries_needing_unit_price;
*/

DROP VIEW IF EXISTS analytics_int.vw_int_feeding_entries_needing_unit_price CASCADE;

CREATE VIEW analytics_int.vw_int_feeding_entries_needing_unit_price AS
WITH producao AS (
    SELECT s.id_stock_control_item,
        s.source_reference_id AS id_production
    FROM "StockControlMovement" s
    WHERE s.source_module = 'PLANTED_CULTURE_PRODUCTION'::text 
      AND s.movement_type = 'ENTRY'::"StockControlMovementType"
), 
consumo AS (
    SELECT s.id_stock_control_item,
        s.source_reference_id AS id_expense_entry
    FROM "StockControlMovement" s
    WHERE s.source_module = 'EXPENSES'::text 
      AND s.movement_type = 'EXIT'::"StockControlMovementType"
)
SELECT f.id_expense_entry,
    f.id_property,
    f.unit_price AS current_unit_price,
    (f.consumed_quantity * CASE
        WHEN lower(TRIM(BOTH FROM e.unit)) = 'ton'::text THEN 1000
        WHEN lower(TRIM(BOTH FROM e.unit)) = 'feeding-unit-saca-1778245226249'::text THEN 25
        ELSE 1
    END)::double precision AS consumed_quantity_kg,
    f.consumed_quantity AS raw_consumed_quantity,
    e.unit,
    date_trunc('month'::text, e.reference_month)::date AS consumption_reference_month,
    prod.id_production
FROM consumo c
JOIN producao prod ON c.id_stock_control_item = prod.id_stock_control_item
JOIN "FeedingExpenseEntry" f ON c.id_expense_entry = f.id_expense_entry
JOIN "ExpenseEntry" e ON f.id_expense_entry = e.id_expense_entry
WHERE e.is_active = true
  AND f.operation <> 'ESTOCAR'::"ExpenseOperation"
  AND f.unit_price = 0::double precision;
