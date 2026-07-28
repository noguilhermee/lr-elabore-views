/*
VIEW: analytics_mart.vw_forage_cost_stage

Finalidade:
Consolida mensalmente os custos de forrageiras e culturas por etapa do manejo
(PRE_PLANTIO, PLANTIO, TRATOS_CULTURAIS, COLHEITA_ENSILAGEM_GRAO, COLHEITA_ENSILAGEM_PLANTA_INTEIRA).

Granularidade:
Uma linha por propriedade, mês de referência e etapa (id_property + reference_month + stage).

Fontes principais:
- analytics_int.vw_int_forage_cost_items

Regras de negócio:
- Consome da view intermediária analytics_int.vw_int_forage_cost_items (já filtrada por is_active = true e sem ESTOCAR).
- Agrupa os valores financeiros (line_total) e quantidades consumidas por etapa.
- Retorna contagem de itens aplicados e custo total da etapa no mês.

Forma de consulta:
SELECT * FROM analytics_mart.vw_forage_cost_stage;
*/

SELECT 
    fci.id_property,
    fci.reference_month,
    fci.stage,
    SUM(fci.line_total) AS stage_total_cost,
    SUM(fci.consumed_quantity) AS stage_consumed_quantity,
    COUNT(fci.id_management_product) AS items_applied_count
FROM analytics_int.vw_int_forage_cost_items fci
GROUP BY fci.id_property, fci.reference_month, fci.stage
ORDER BY fci.id_property, fci.reference_month, fci.stage;
