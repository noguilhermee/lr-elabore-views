/*
VIEW: analytics_int.vw_int_forage_cost_items

Finalidade:
Camada intermediária para itens de custo de culturas e forrageiras.
Combina os lançamentos de gestão de cultura e produtos aplicados,
normaliza a data de referência mensal e filtra lançamentos ativos e válidos.

Granularidade:
Uma linha por item de produto aplicado (id_management_product).

Fontes principais:
- public.CultureExpenseManagementProduct
- public.CultureExpenseManagement
- public.Culture

Regras de negócio:
- Considera apenas lançamentos ativos (CultureExpenseManagement.is_active = true e CultureExpenseManagementProduct.is_active = true).
- Exclui operações de armazenamento (ESTOCAR).
- Normaliza a data de competência (applied_at) para o primeiro dia do mês.
- Trata etapas (stage): PRE_PLANTIO, PLANTIO, TRATOS_CULTURAIS, COLHEITA_ENSILAGEM_GRAO, COLHEITA_ENSILAGEM_PLANTA_INTEIRA.

Forma de consulta:
SELECT * FROM analytics_int.vw_int_forage_cost_items;
*/

SELECT 
    cem.id_property,
    cemp.id_management_product,
    cemp.id_culture_expense_item,
    cem.id_management,
    cem.id_culture,
    cem.id_area,
    date_trunc('month'::text, COALESCE(cemp.applied_at, cem.created_at))::date AS reference_month,
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
LEFT JOIN "Culture" c ON cem.id_culture = c.id_culture
WHERE cem.is_active = true 
  AND cemp.is_active = true 
  AND COALESCE(cemp.operation::text, ''::text) <> 'ESTOCAR'::text;
