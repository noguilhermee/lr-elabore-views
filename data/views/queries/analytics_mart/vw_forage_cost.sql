/*
VIEW: analytics_mart.vw_forage_cost

Finalidade:
Consolida mensalmente o custo total de forrageiras e culturas por propriedade,
distribuindo os valores lançados entre as principais etapas de manejo (pré-plantio, plantio,
tratos culturais e colheita).

Granularidade:
Uma linha por propriedade e mês de referência (id_property + reference_month).

Fontes principais:
- analytics_int.vw_int_forage_cost_items

Regras de negócio:
- Consome da view intermediária analytics_int.vw_int_forage_cost_items (já filtrada por is_active = true e sem ESTOCAR).
- Agrupa todas as etapas no nível mensal por propriedade.
- Pivota os custos por etapa: pre_planting_cost, planting_cost, cultural_treatments_cost, harvest_grain_cost, harvest_whole_plant_cost e total_forage_cost.

Forma de consulta:
SELECT * FROM analytics_mart.vw_forage_cost;
*/

SELECT 
    fci.id_property,
    fci.reference_month,
    SUM(CASE WHEN fci.stage = 'PRE_PLANTIO' THEN fci.line_total ELSE 0::double precision END) AS pre_planting_cost,
    SUM(CASE WHEN fci.stage = 'PLANTIO' THEN fci.line_total ELSE 0::double precision END) AS planting_cost,
    SUM(CASE WHEN fci.stage = 'TRATOS_CULTURAIS' THEN fci.line_total ELSE 0::double precision END) AS cultural_treatments_cost,
    SUM(CASE WHEN fci.stage = 'COLHEITA_ENSILAGEM_GRAO' THEN fci.line_total ELSE 0::double precision END) AS harvest_grain_cost,
    SUM(CASE WHEN fci.stage = 'COLHEITA_ENSILAGEM_PLANTA_INTEIRA' THEN fci.line_total ELSE 0::double precision END) AS harvest_whole_plant_cost,
    SUM(fci.line_total) AS total_forage_cost
FROM analytics_int.vw_int_forage_cost_items fci
GROUP BY fci.id_property, fci.reference_month
ORDER BY fci.id_property, fci.reference_month;
