/*
VIEW: analytics_int.vw_int_forage_production

Finalidade:
Camada intermediária de produção agrícola e forragens com vínculo de custo.
Consolida os dados de plantio, colheita, áreas, volumes produzidos e
agrega os custos totais acumulados e mensais das culturas correspondentes.

Granularidade:
Uma linha por registro de produção agrícola ativo (id_production).

Fontes principais:
- public.Production
- public.PlantedCulture
- public.Area
- public.Culture
- public.CultureHarvestProduct
- public.CultureExpenseManagement
- public.CultureExpenseManagementProduct

Regras de negócio:
- Considera apenas lançamentos ativos de produção (Production.is_active = true) e plantio (PlantedCulture.is_active = true).
- Associa os custos de manejo (CultureExpenseManagementProduct) agregados por cultura e área no mês.
- Normaliza a data de referência mensal para o primeiro dia do mês da colheita.
- Calcula o rendimento (produção / área colhida) e custo unitário por kg (custo / produção).

Forma de consulta:
SELECT * FROM analytics_int.vw_int_forage_production;
*/

WITH forage_costs AS (
    SELECT 
        cem.id_property,
        cem.id_culture,
        cem.id_area,
        date_trunc('month'::text, COALESCE(cemp.applied_at, cem.created_at))::date AS reference_month,
        SUM(COALESCE(cemp.line_total, 0::double precision)) AS monthly_cost
    FROM "CultureExpenseManagementProduct" cemp
    JOIN "CultureExpenseManagement" cem ON cemp.id_management = cem.id_management
    WHERE cem.is_active = true 
      AND cemp.is_active = true
      AND COALESCE(cemp.operation::text, ''::text) <> 'ESTOCAR'::text
    GROUP BY cem.id_property, cem.id_culture, cem.id_area, date_trunc('month'::text, COALESCE(cemp.applied_at, cem.created_at))::date
)
SELECT 
    a.id_property,
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
    chp.name AS harvest_product_name,
    
    -- Custos e Produtividade
    COALESCE(fc.monthly_cost, 0::double precision) AS monthly_forage_cost,
    CASE 
        WHEN p.harvested_area > 0 THEN round((p.quantity_produced / p.harvested_area)::numeric, 2)::double precision 
        ELSE 0::double precision 
    END AS yield_kg_per_ha,
    CASE 
        WHEN p.quantity_produced > 0 THEN round((COALESCE(fc.monthly_cost, 0::double precision) / p.quantity_produced)::numeric, 4)::double precision 
        ELSE 0::double precision 
    END AS cost_per_kg

FROM "Production" p
JOIN "PlantedCulture" pc ON p.id_planted_culture = pc.id_planted_culture
JOIN "Area" a ON pc.id_area = a.id_area
LEFT JOIN "Culture" c ON pc.id_culture = c.id_culture
LEFT JOIN "CultureHarvestProduct" chp ON c.id_culture = chp.id_culture AND chp.is_active = true
LEFT JOIN forage_costs fc ON pc.id_culture = fc.id_culture 
                         AND pc.id_area = fc.id_area 
                         AND a.id_property = fc.id_property 
                         AND date_trunc('month'::text, p.produced_at)::date = fc.reference_month
WHERE p.is_active = true 
  AND pc.is_active = true;
