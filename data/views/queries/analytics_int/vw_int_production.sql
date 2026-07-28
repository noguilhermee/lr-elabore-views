/*
VIEW: analytics_int.vw_int_production

Finalidade:
Camada intermediária de produção agrícola e forragens. Consolida os dados
de plantio, colheita, área plantada/colhida, cultura e produto colhido.

Granularidade:
Uma linha por registro de produção agrícola ativo (id_production).

Fontes principais:
- public.Production
- public.PlantedCulture
- public.Area
- public.Culture
- public.CultureHarvestProduct

Regras de negócio:
- Considera apenas lançamentos ativos de produção (Production.is_active = true) e plantio (PlantedCulture.is_active = true).
- Relaciona a produção à área cadastrada na propriedade.
- Recupera a cultura e o produto/alimento colhido associado à cultura.
- Normaliza a data de competência/referência mensal para o primeiro dia do mês da colheita.

Forma de consulta:
SELECT * FROM analytics_int.vw_int_production;
*/

SELECT a.id_property,
    p.id_production,
    p.id_planted_culture,
    pc.id_culture,
    chp.id_culture_harvest_product,
    
    -- Datas
    date_trunc('month'::text, p.produced_at)::date AS reference_month,
    pc.planted_at,
    p.produced_at AS harvest_date,
    
    -- Áreas e Produção
    pc.planted_area,
    p.harvested_area,
    p.quantity_produced AS production,
    
    -- Cultura e Alimento Colhido
    c.name AS culture_name,
    chp.name AS harvest_product_name

FROM "Production" p
    JOIN "PlantedCulture" pc ON p.id_planted_culture = pc.id_planted_culture
    JOIN "Area" a ON pc.id_area = a.id_area
    LEFT JOIN "Culture" c ON pc.id_culture = c.id_culture
    LEFT JOIN "CultureHarvestProduct" chp ON c.id_culture = chp.id_culture AND chp.is_active = true
WHERE p.is_active = true 
  AND pc.is_active = true;
