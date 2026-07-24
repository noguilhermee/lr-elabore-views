SELECT *
FROM analytics_mart.vw_production
ORDER BY id_property, reference_month;



SELECT
    a.id_property,
    p.id_production AS id,
    pc.id_culture,
    pc.id_planted_culture,
    DATE_TRUNC('month', p.produced_at)::date AS reference_month,
    p.harvested_area AS produced_area,
    p.quantity_produced AS production,
    p.produced_at AS harvest_date

FROM "Production" p

INNER JOIN "PlantedCulture" pc
    ON p.id_planted_culture = pc.id_planted_culture

INNER JOIN "Area" a
    ON pc.id_area = a.id_area

WHERE p.is_active = TRUE
  AND pc.is_active = TRUE

ORDER BY
    a.id_property,
    reference_month;