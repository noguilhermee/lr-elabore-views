/*
VIEW: analytics_int.vw_int_forage_cost_items

Finalidade:
Camada intermediária para itens brutos de custo de manejo de culturas e forrageiras.
Combina os lançamentos de gestão de cultura e produtos aplicados (insumos, fertilizantes, sementes, serviços),
vincula o plantio (PlantedCulture), a cultura (Culture) e a área (Area), normaliza a data de referência mensal
(reference_month) pela data de aplicação e filtra lançamentos ativos.

Granularidade:
Uma linha por item de produto aplicado (id_management_product).

Fontes principais:
- public.CultureExpenseManagementProduct
- public.CultureExpenseManagement
- public.PlantedCulture
- public.Culture
*/

SELECT 
    cem.id_property,
    pc.id_planted_culture,
    cem.id_culture,
    cem.id_area,
    cem.id_management,
    cemp.id_management_product,
    cemp.id_culture_expense_item,
    date_trunc('month'::text, COALESCE(cemp.applied_at, cem.created_at))::date AS reference_month,
    pc.planted_at,
    cemp.applied_at,
    c.name AS culture_name,
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
WHERE cem.is_active = true 
  AND cemp.is_active = true 
  AND COALESCE(cemp.operation::text, ''::text) <> 'ESTOCAR'::text;
