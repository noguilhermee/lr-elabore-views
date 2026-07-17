SELECT *
FROM analytics_mart.vw_labor
ORDER BY id_property, reference_month;

SELECT
    id_property,
    DATE_TRUNC('month', reference_month)::date AS reference_month,

    -- Mão de obra familiar (family labor)
    SUM(CASE
        WHEN (tab = 'LABOR'    AND line_code = 'familiar')
          OR (tab = 'OWN_MILK' AND line_code = 'family-labor')
        THEN amount_total
        ELSE 0
    END) AS family_labor_expenses,

    SUM(CASE
        WHEN (tab = 'LABOR'    AND line_code = 'familiar')
        THEN COALESCE(quantity, 0)
        ELSE 0
    END) AS family_labor_quantity,

    -- Mão de obra contratada (hired labor)
    SUM(CASE
        WHEN (tab = 'LABOR'    AND line_code IN ('hired-general', 'hired-milker', 'hired-relief', 'hired-tractor', 'labor-charges', 'labor-others' ))
          OR (tab = 'OWN_MILK' AND line_code = 'hired-labor')
        THEN amount_total
        ELSE 0
    END) AS hired_labor_expenses,

    SUM(CASE
        WHEN tab = 'LABOR'     AND line_code IN ( 'hired-general', 'hired-milker', 'hired-relief', 'hired-tractor', 'labor-charges', 'labor-others' )
        THEN COALESCE(quantity, 0)
        ELSE 0
    END) AS hired_labor_quantity

FROM "ExpenseEntry"

WHERE is_active = TRUE
  AND tab IN ('LABOR', 'OWN_MILK')
  AND COALESCE(operation::text, '') <> 'ESTOCAR'

GROUP BY
    id_property,
    DATE_TRUNC('month', reference_month)

ORDER BY
    id_property,
    reference_month;