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

Regras de negócio:
- Considera somente lançamentos ativos (CultureExpenseManagement.is_active = true
  e CultureExpenseManagementProduct.is_active = true).
- Exclui operações de armazenamento (ESTOCAR).

- VÍNCULO COM O PLANTIO
  CultureExpenseManagement não possui id_planted_culture nem chave estrangeira
  para PlantedCulture. Na origem o plantio é identificado implicitamente pela
  combinação (id_area, id_culture, harvest_season). A coluna
  planting_production NÃO é identificador: contém rótulos de ciclo
  ("1ª safra", "2ª safra", "Planta de cobertura") e não casa com
  PlantedCulture nem com Production.

  PlantedCulture não armazena a safra, apenas planted_at. A safra é portanto
  derivada de planted_at no formato YY/YY, com corte no mês de julho
  (plantio de julho em diante pertence à safra YY/YY+1).

  Entre os plantios candidatos de (id_area, id_culture), escolhe-se um único,
  na seguinte ordem de precedência:
    1. safra derivada igual a CultureExpenseManagement.harvest_season;
    2. em empate, planted_at mais próximo de applied_at (distância absoluta,
       porque insumo de plantio é aplicado antes de planted_at e insumo de
       colheita muito depois);
    3. em empate, menor id_planted_culture, para tornar o resultado determinístico.

  O filtro PlantedCulture.is_active NÃO é aplicado no vínculo. Apenas 904 dos
  2.312 plantios estão ativos, e exigir is_active deixava 9.532 dos 14.282
  lançamentos de custo (67%) sem plantio algum, o que descartava cerca de 62%
  do custo total de forrageira.

  Cobertura resultante: 13.875 dos 14.282 lançamentos ativos (97,15%), que é
  exatamente o total de lançamentos com id_culture preenchido. Os 407 restantes
  não têm cultura informada na origem e permanecem com id_planted_culture nulo.

Forma de consulta:
SELECT * FROM analytics_int.vw_int_forage_cost_items;
*/

WITH plantio AS (
    SELECT
        pc.id_planted_culture,
        pc.id_area,
        pc.id_culture,
        pc.planted_at,
        CASE
            WHEN EXTRACT(MONTH FROM pc.planted_at) >= 7
                THEN to_char(pc.planted_at, 'YY') || '/' ||
                     to_char(pc.planted_at + INTERVAL '1 year', 'YY')
            ELSE to_char(pc.planted_at - INTERVAL '1 year', 'YY') || '/' ||
                 to_char(pc.planted_at, 'YY')
        END AS harvest_season_derivada
    FROM "PlantedCulture" pc
),
vinculo_ranqueado AS (
    SELECT
        cem.id_management,
        p.id_planted_culture,
        ROW_NUMBER() OVER (
            PARTITION BY cem.id_management
            ORDER BY
                (p.harvest_season_derivada = cem.harvest_season) DESC,
                abs(EXTRACT(EPOCH FROM (p.planted_at - cem.applied_at))) ASC,
                p.id_planted_culture ASC
        ) AS ordem
    FROM "CultureExpenseManagement" cem
    JOIN plantio p
      ON cem.id_area = p.id_area
     AND cem.id_culture = p.id_culture
    WHERE cem.is_active = true
),
vinculo AS (
    SELECT
        id_management,
        id_planted_culture
    FROM vinculo_ranqueado
    WHERE ordem = 1
)
SELECT
    cem.id_property,
    v.id_planted_culture,
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
    COALESCE(cemp.quantity, 0::double precision)          AS quantity,
    COALESCE(cemp.consumed_quantity, 0::double precision) AS consumed_quantity,
    COALESCE(cemp.unit_cost, 0::double precision)         AS unit_cost,
    COALESCE(cemp.line_total, 0::double precision)        AS line_total,
    cem.planting_production,
    cem.cycle,
    cem.harvest_season
FROM "CultureExpenseManagementProduct" cemp
JOIN "CultureExpenseManagement" cem
  ON cemp.id_management = cem.id_management
LEFT JOIN vinculo v
  ON v.id_management = cem.id_management
LEFT JOIN "PlantedCulture" pc
  ON pc.id_planted_culture = v.id_planted_culture
LEFT JOIN "Culture" c
  ON cem.id_culture = c.id_culture
WHERE cem.is_active = true
  AND cemp.is_active = true
  AND COALESCE(cemp.operation::text, ''::text) <> 'ESTOCAR'::text;
