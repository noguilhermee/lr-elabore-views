/*
VIEW: analytics_mart.vw_forage_production

Finalidade:
View analítica de produção de forrageiras e culturas agrícolas, contendo dados de áreas plantada/colhida,
volume produzido, produto colhido, custo mensal associado e indicadores de produtividade (kg/ha e R$/kg).

Granularidade:
Uma linha por registro de produção (id_production).

Fontes principais:
- analytics_int.vw_int_forage_production

Regras de negócio:
- Consome da view intermediária analytics_int.vw_int_forage_production (já com joins de área, cultura, produto e custo mensal).
- Traz os indicadores calculados de produtividade (yield_kg_per_ha) e custo unitário de produção (cost_per_kg).

Forma de consulta:
SELECT * FROM analytics_mart.vw_forage_production;
*/

SELECT 
    fp.id_property,
    fp.id_production,
    fp.id_culture,
    fp.id_planted_culture,
    fp.id_culture_harvest_product,
    fp.reference_month,
    
    -- Datas e Áreas
    fp.planted_at,
    fp.harvest_date,
    fp.planted_area,
    fp.harvested_area,
    fp.production,
    
    -- Cultura e Alimento Colhido
    fp.culture_name,
    fp.harvest_product_name,
    
    -- Custo e Produtividade
    fp.monthly_forage_cost AS forage_cost,
    fp.yield_kg_per_ha,
    fp.cost_per_kg
    
FROM analytics_int.vw_int_forage_production fp
ORDER BY fp.id_property, fp.reference_month;
