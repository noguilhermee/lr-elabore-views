SELECT *
FROM analytics_mart.vw_feeding
ORDER BY id_property, reference_month;



SELECT
    f.id_property,
    DATE_TRUNC('month', e.reference_month)::date AS reference_month,

    CASE
        WHEN LOWER(TRIM(e.unit)) IN ('ton', 'feeding-unit-saca-1778245226249') THEN 'kg'
        ELSE LOWER(TRIM(e.unit))
    END AS unit,

    SUM(CASE WHEN f.category_code = 'VOLUMOSO' THEN f.purchased_quantity *
        CASE
            WHEN LOWER(TRIM(e.unit)) = 'ton' THEN 1000
            WHEN LOWER(TRIM(e.unit)) = 'feeding-unit-saca-1778245226249' THEN 25
            ELSE 1
        END
        ELSE 0
    END) AS voluminous_purchased_quantity,

    SUM(CASE WHEN f.category_code = 'VOLUMOSO' THEN f.consumed_quantity *
        CASE
            WHEN LOWER(TRIM(e.unit)) = 'ton' THEN 1000
            WHEN LOWER(TRIM(e.unit)) = 'feeding-unit-saca-1778245226249' THEN 25
            ELSE 1
        END
        ELSE 0
    END) AS voluminous_consumed_quantity,

    SUM(CASE WHEN f.category_code = 'VOLUMOSO' THEN e.amount_total ELSE 0 END) AS voluminous_amount_total,

    SUM(CASE WHEN f.category_code = 'CONCENTRADO' THEN f.purchased_quantity *
        CASE
            WHEN LOWER(TRIM(e.unit)) = 'ton' THEN 1000
            WHEN LOWER(TRIM(e.unit)) = 'feeding-unit-saca-1778245226249' THEN 25
            ELSE 1
        END
        ELSE 0
    END) AS concentrate_purchased_quantity,

    SUM(CASE WHEN f.category_code = 'CONCENTRADO' THEN f.consumed_quantity *
        CASE
            WHEN LOWER(TRIM(e.unit)) = 'ton' THEN 1000
            WHEN LOWER(TRIM(e.unit)) = 'feeding-unit-saca-1778245226249' THEN 25
            ELSE 1
        END
        ELSE 0
    END) AS concentrate_consumed_quantity,

    SUM(CASE WHEN f.category_code = 'CONCENTRADO' THEN e.amount_total ELSE 0 END) AS concentrate_amount_total,

    SUM(CASE WHEN f.category_code = 'MINERAIS' THEN f.purchased_quantity *
        CASE
            WHEN LOWER(TRIM(e.unit)) = 'ton' THEN 1000
            WHEN LOWER(TRIM(e.unit)) = 'feeding-unit-saca-1778245226249' THEN 25
            ELSE 1
        END
        ELSE 0
    END) AS mineral_purchased_quantity,

    SUM(CASE WHEN f.category_code = 'MINERAIS' THEN f.consumed_quantity *
        CASE
            WHEN LOWER(TRIM(e.unit)) = 'ton' THEN 1000
            WHEN LOWER(TRIM(e.unit)) = 'feeding-unit-saca-1778245226249' THEN 25
            ELSE 1
        END
        ELSE 0
    END) AS mineral_consumed_quantity,

    SUM(CASE WHEN f.category_code = 'MINERAIS' THEN e.amount_total ELSE 0 END) AS mineral_amount_total

FROM "FeedingExpenseEntry" f

LEFT JOIN "ExpenseEntry" e
    ON f.id_expense_entry = e.id_expense_entry

WHERE e.is_active = TRUE
  AND f.operation <> 'ESTOCAR'

GROUP BY
    f.id_property,
    DATE_TRUNC('month', e.reference_month),
    CASE
        WHEN LOWER(TRIM(e.unit)) IN ('ton', 'feeding-unit-saca-1778245226249') THEN 'kg'
        ELSE LOWER(TRIM(e.unit))
    END

ORDER BY
    f.id_property,
    reference_month,
    unit;