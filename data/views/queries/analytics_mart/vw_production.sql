/*
VIEW: analytics_mart.vw_production

Finalidade:
View analítica final de produção agrícola e colheitas em inglês, contendo os dados de plantio,
colheita, áreas plantada/colhida, volume produzido, cultura e alimento colhido.

Granularidade:
Uma linha por registro de produção (id_production).

Fontes principais:
- analytics_int.vw_int_production

Forma de consulta:
SELECT * FROM analytics_mart.vw_production;
*/

SELECT pr.id_property,
    pr.id_production AS id,
    pr.id_culture,
    pr.id_planted_culture,
    pr.id_culture_harvest_product,
    pr.reference_month,
    
    -- Datas e Áreas
    pr.planted_at,
    pr.harvest_date,
    pr.planted_area,
    pr.harvested_area,
    pr.production,
    
    -- Cultura e Produto Colhido
    pr.culture_name,
    pr.harvest_product_name

FROM analytics_int.vw_int_production pr
ORDER BY pr.id_property, pr.reference_month;