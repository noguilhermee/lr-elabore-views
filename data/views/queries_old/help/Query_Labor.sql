

SELECT
    id_property,
    DATE_TRUNC('month', reference_month)::date AS reference_month,

    -- LABOR
    SUM(CASE WHEN tab = 'LABOR' AND line_code = 'familiar' THEN amount_total ELSE 0 END) AS familiar_labor,
    SUM(CASE WHEN tab = 'LABOR' AND line_code = 'hired-general' THEN amount_total ELSE 0 END) AS hired_general,
    SUM(CASE WHEN tab = 'LABOR' AND line_code = 'hired-milker' THEN amount_total ELSE 0 END) AS hired_milker,
    SUM(CASE WHEN tab = 'LABOR' AND line_code = 'hired-relief' THEN amount_total ELSE 0 END) AS hired_relief,
    SUM(CASE WHEN tab = 'LABOR' AND line_code = 'hired-tractor' THEN amount_total ELSE 0 END) AS hired_tractor,
    SUM(CASE WHEN tab = 'LABOR' AND line_code = 'labor-charges' THEN amount_total ELSE 0 END) AS labor_charges,
    SUM(CASE WHEN tab = 'LABOR' AND line_code = 'labor-others' THEN amount_total ELSE 0 END) AS labor_others,


    SUM(CASE WHEN tab = 'OWN_MILK' AND line_code = 'hired-labor' THEN amount_total ELSE 0 END) AS own_milk_hired_labor,
    SUM(CASE WHEN tab = 'OWN_MILK' AND line_code = 'family-labor' THEN amount_total ELSE 0 END) AS own_milk_family_labor,

FROM "ExpenseEntry"

WHERE is_active = TRUE
  AND tab = 'LABOR'
  AND COALESCE(operation::text, '') <> 'ESTOCAR'
    
GROUP BY
    id_property,
    DATE_TRUNC('month', reference_month)

ORDER BY
    id_property,
    reference_month;