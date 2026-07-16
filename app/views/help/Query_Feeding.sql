#
# Listar os registros no PostgreSQL
#

SELECT
    f.id_expense_entry,
    f.id_property,
    DATE_TRUNC('month', e.reference_month)::date AS reference_month,
    e.unit,
	
    CASE WHEN f.category_code = 'VOLUMOSO' THEN f.purchased_quantity ELSE 0 END AS voluminous_purchased_quantity,
    CASE WHEN f.category_code = 'VOLUMOSO' THEN f.consumed_quantity ELSE 0 END AS voluminous_consumed_quantity,
    CASE WHEN f.category_code = 'VOLUMOSO' THEN e.amount_total ELSE 0 END AS voluminous_amount_total,

    CASE WHEN f.category_code = 'CONCENTRADO' THEN f.purchased_quantity ELSE 0 END AS concentrate_purchased_quantity,
    CASE WHEN f.category_code = 'CONCENTRADO' THEN f.consumed_quantity ELSE 0 END AS concentrate_consumed_quantity,
    CASE WHEN f.category_code = 'CONCENTRADO' THEN e.amount_total ELSE 0 END AS concentrate_amount_total,

    CASE WHEN f.category_code = 'MINERAIS' THEN f.purchased_quantity ELSE 0 END AS mineral_purchased_quantity,
    CASE WHEN f.category_code = 'MINERAIS' THEN f.consumed_quantity ELSE 0 END AS mineral_consumed_quantity,
    CASE WHEN f.category_code = 'MINERAIS' THEN e.amount_total ELSE 0 END AS mineral_amount_total

FROM "FeedingExpenseEntry" f

LEFT JOIN "ExpenseEntry" e
    ON f.id_expense_entry = e.id_expense_entry

WHERE e.is_active = TRUE
  AND f.operation <> 'ESTOCAR'

ORDER BY
    f.id_property,
    reference_month;
    

#
# Listar os registros no PostgreSQL, duplicados
#
SELECT
    f.id_expense_entry,
    f.id_property,
    DATE_TRUNC('month', e.reference_month)::date AS reference_month,
    f.category_code,
    f.operation,
    f.item_code,
    f.purchased_quantity,
    f.consumed_quantity,
    f.unit_price,
    e.amount_total

FROM "FeedingExpenseEntry" f

LEFT JOIN "ExpenseEntry" e
    ON f.id_expense_entry = e.id_expense_entry

WHERE e.is_active = TRUE

ORDER BY
    f.id_property,
    reference_month;