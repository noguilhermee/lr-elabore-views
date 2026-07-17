SELECT *
FROM analytics_mart.vw_own_milk
ORDER BY id_property, reference_month;



SELECT
    id_property,
    DATE_TRUNC('month', reference_month)::date AS reference_month,

    MAX(unit_price) AS unit_price,
    
    SUM(CASE WHEN line_code = 'hired-labor' THEN COALESCE(quantity, 0) ELSE 0 END) AS hired_labor_quantity,
    SUM(CASE WHEN line_code = 'hired-labor' THEN COALESCE(amount_total, 0) ELSE 0 END) AS hired_labor_amount_total,

    SUM(CASE WHEN line_code = 'discarded' THEN COALESCE(quantity, 0) ELSE 0 END) AS discarded_quantity,
    SUM(CASE WHEN line_code = 'discarded' THEN COALESCE(amount_total, 0) ELSE 0 END) AS discarded_amount_total,

    SUM(CASE WHEN line_code = 'calves' THEN COALESCE(quantity, 0) ELSE 0 END) AS calves_quantity,
    SUM(CASE WHEN line_code = 'calves' THEN COALESCE(amount_total, 0) ELSE 0 END) AS calves_amount_total,

    SUM(CASE WHEN line_code = 'family-labor' THEN COALESCE(quantity, 0) ELSE 0 END) AS family_labor_quantity,
    SUM(CASE WHEN line_code = 'family-labor' THEN COALESCE(amount_total, 0) ELSE 0 END) AS family_labor_amount_total

FROM "ExpenseEntry"

WHERE is_active = TRUE
  AND tab = 'OWN_MILK'

GROUP BY
    id_property,
    DATE_TRUNC('month', reference_month)

ORDER BY
    id_property,
    reference_month;
