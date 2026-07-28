/*
VIEW: analytics_int.vw_int_forage_cost_items

Finalidade:
Camada intermediária para itens de custo de culturas e forrageiras.
Combina os lançamentos de gestão de cultura e produtos aplicados, vincula o plantio (PlantedCulture)
e o produto colhido (CultureHarvestProduct para recuperar a categoria alimentar feeding_category),
normaliza a data de referência mensal e filtra lançamentos ativos e válidos.

Granularidade:
Uma linha por item de produto aplicado (id_management_product).

Fontes principais:
- public.CultureExpenseManagementProduct
- public.CultureExpenseManagement
- public.PlantedCulture
- public.Culture
- public.CultureHarvestProduct

Forma de consulta:
SELECT * FROM analytics_int.vw_int_forage_cost_items;
*/

SELECT 
    cem.id_property,
    cemp.id_management_product,
    cemp.id_culture_expense_item,
    cem.id_management,
    pc.id_planted_culture,
    cem.id_culture,
    cem.id_area,
    date_trunc('month'::text, COALESCE(cemp.applied_at, cem.created_at))::date AS reference_month,
    cemp.applied_at,
    c.name AS culture_name,
    chp.name AS harvest_product_name,
    chp.feeding_category,
    cemp.product_name,
    cemp.category,
    cemp.stage,
    cemp.operation,
    COALESCE(cemp.quantity, 0::double precision) AS quantity,
    COALESCE(cemp.consumed_quantity, 0::double precision) AS consumed_quantity,
    COALESCE(cemp.unit_cost, 0::double precision) AS unit_cost,
    COALESCE(cemp.line_total, 0::double precision) AS line_total,
    cem.planting_production,
    cem.cycle,
    cem.harvest_season
FROM "CultureExpenseManagementProduct" cemp
JOIN "CultureExpenseManagement" cem ON cemp.id_management = cem.id_management
LEFT JOIN "PlantedCulture" pc ON cem.id_area = pc.id_area AND cem.id_culture = pc.id_culture AND pc.is_active = true
LEFT JOIN "Culture" c ON cem.id_culture = c.id_culture
LEFT JOIN "CultureHarvestProduct" chp ON c.id_culture = chp.id_culture AND chp.is_active = true
WHERE cem.is_active = true 
  AND cemp.is_active = true 
  AND COALESCE(cemp.operation::text, ''::text) <> 'ESTOCAR'::text;
