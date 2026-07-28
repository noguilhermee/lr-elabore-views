 SELECT a.id_property,
    p.id_production AS id,
    pc.id_culture,
    pc.id_planted_culture,
    date_trunc('month'::text, p.produced_at)::date AS reference_month,
    p.harvested_area AS produced_area,
    p.quantity_produced AS production,
    p.produced_at AS harvest_date
   FROM "Production" p
     JOIN "PlantedCulture" pc ON p.id_planted_culture = pc.id_planted_culture
     JOIN "Area" a ON pc.id_area = a.id_area
  WHERE p.is_active = true AND pc.is_active = true
  ORDER BY a.id_property, (date_trunc('month'::text, p.produced_at)::date);