/*
VIEW: analytics_mart.vw_culture_expense

Finalidade:
Detalha os produtos e insumos aplicados nas culturas, reunindo informações
sobre propriedade, área, cultura, estágio, operação, quantidade, consumo,
custo unitário e custo total.

Granularidade:
Uma linha por item ou produto aplicado em um manejo de cultura.

Fontes principais:
- CultureExpenseManagementProduct
- CultureExpenseManagement

Regras principais:
- Considera apenas manejos ativos.
- Considera apenas produtos ou itens ativos.
- Exclui operações de armazenamento identificadas como ESTOCAR.
- Define a competência mensal a partir da data de aplicação do produto.

Forma de consulta:
SELECT *
FROM analytics_mart.vw_culture_expense;
*/

SELECT cem.id_property,
    cemp.id_management_product,
    date_trunc('month'::text, cemp.applied_at)::date AS reference_month,
    cem.id_culture,
    cemp.product_name,
    cemp.id_culture_expense_item,
    cemp.category,
    cemp.operation,
    cemp.quantity,
    cemp.consumed_quantity,
    cemp.unit_cost,
    cem.id_area,
    cemp.stage,
    cem.planting_production,
    cem.id_management,
    cem.total_cost,
    cem.application_label,
    cem.cycle,
    cem.harvest_season,
    cemp.line_total
    
    FROM "CultureExpenseManagementProduct" cemp
        JOIN "CultureExpenseManagement" cem ON cemp.id_management = cem.id_management
    WHERE cem.is_active = true AND cemp.is_active = true AND COALESCE(cemp.operation::text, ''::text) <> 'ESTOCAR'::text
    ORDER BY cem.id_property, (date_trunc('month'::text, cemp.applied_at)::date), cemp.stage, cemp.product_name;