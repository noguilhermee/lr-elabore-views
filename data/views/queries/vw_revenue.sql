SELECT *
FROM analytics_mart.vw_revenue
ORDER BY id_property, reference_month;


CREATE OR REPLACE VIEW analytics_mart.vw_revenue AS

SELECT
    id_property,
    DATE_TRUNC('month', reference_month)::date AS reference_month,

    SUM(CASE WHEN type = 'MILK_SOLD' THEN amount_total ELSE 0 END) AS milk_sold,
    SUM(CASE WHEN type = 'MILK_SOLD' THEN COALESCE((payload::jsonb ->> 'quantity')::numeric, 0) ELSE 0 END) AS milk_volume_sold,
    MAX(CASE WHEN type = 'MILK_SOLD' THEN (payload::jsonb ->> 'unit_price')::numeric END) AS unit_price,

    MAX(CASE WHEN type = 'MILK_SOLD' THEN (quality_indicators::jsonb ->> 'ccs')::numeric END) AS ccs,
    MAX(CASE WHEN type = 'MILK_SOLD' THEN (quality_indicators::jsonb ->> 'cpp')::numeric END) AS cpp,
    MAX(CASE WHEN type = 'MILK_SOLD' THEN (quality_indicators::jsonb ->> 'fat')::numeric END) AS fat,
    MAX(CASE WHEN type = 'MILK_SOLD' THEN (quality_indicators::jsonb ->> 'protein')::numeric END) AS protein,

    SUM(CASE WHEN type = 'RECEIVED_LOANS' THEN amount_total ELSE 0 END) AS received_loans,
    SUM(CASE WHEN type = 'ANIMAL_SALE' THEN amount_total ELSE 0 END) AS animal_sale,
    SUM(CASE WHEN type = 'OTHER_REVENUES' THEN amount_total ELSE 0 END) AS other_revenues,
    SUM(CASE WHEN type = 'PRICE_BONUS' THEN amount_total ELSE 0 END) AS price_bonus,
    SUM(CASE WHEN type = 'PRICE_PENALTY' THEN amount_total ELSE 0 END) AS price_penalty,
    SUM(CASE WHEN type = 'MILK_DERIVATIVES' THEN amount_total ELSE 0 END) AS milk_derivatives,
    SUM(CASE WHEN type = 'VOLUMOUS_SOLD' THEN amount_total ELSE 0 END) AS voluminous_sold,
    SUM(CASE WHEN type = 'SURPLUS_DIVISION' THEN amount_total ELSE 0 END) AS surplus_division

FROM "RevenueEntry"

WHERE is_active = TRUE

GROUP BY
    id_property,
    DATE_TRUNC('month', reference_month);