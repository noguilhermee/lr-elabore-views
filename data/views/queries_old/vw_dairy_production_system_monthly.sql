CREATE OR REPLACE VIEW analytics_mart.vw_dairy_production_system_monthly AS

WITH expanded_months AS (

    -- Expande cada registro de LACTATION para todos os meses
    -- entre started_at e finished_at ou o mês atual.
    SELECT
        dp.id_dairy,
        dp.id_property,

        dp.compost_barn,
        dp.free_stall,
        dp.semi_confined,
        dp.pasture,
        dp.unstructured_confinment,

        dp.started_at,
        dp.finished_at,
        dp.created_at,
        dp.updated_at,

        gs.reference_month::date AS reference_month

    FROM "DairyProduction" AS dp

    CROSS JOIN LATERAL generate_series(
        DATE_TRUNC(
            'month',
            dp.started_at
        )::date,

        DATE_TRUNC(
            'month',
            LEAST(
                COALESCE(
                    dp.finished_at,
                    CURRENT_DATE::timestamp
                ),
                CURRENT_DATE::timestamp
            )
        )::date,

        INTERVAL '1 month'
    ) AS gs(reference_month)

    WHERE dp.started_at IS NOT NULL
      AND dp.category::text = 'LACTATION'
      AND COALESCE(
            dp.finished_at,
            CURRENT_DATE::timestamp
          ) >= dp.started_at
),

ranked_records AS (

    -- Caso dois registros cubram a mesma propriedade e mês,
    -- mantém prioridade para o maior started_at.
    SELECT
        em.*,

        ROW_NUMBER() OVER (
            PARTITION BY
                em.id_property,
                em.reference_month

            ORDER BY
                em.started_at DESC,
                em.updated_at DESC NULLS LAST,
                em.created_at DESC NULLS LAST,
                em.id_dairy DESC
        ) AS record_order

    FROM expanded_months AS em
),

selected_records AS (

    -- Uma única configuração de LACTATION por propriedade e mês.
    SELECT
        id_property,
        reference_month,

        COALESCE(compost_barn, 0) AS compost_barn,
        COALESCE(free_stall, 0) AS free_stall,
        COALESCE(semi_confined, 0) AS semi_confined,
        COALESCE(pasture, 0) AS pasture,
        COALESCE(
            unstructured_confinment,
            0
        ) AS unstructured_confinment

    FROM ranked_records

    WHERE record_order = 1
),

system_percentages AS (

    -- Transforma as cinco colunas de porcentagem em linhas temporárias.
    SELECT
        sr.id_property,
        sr.reference_month,
        systems.production_system,
        systems.percentage

    FROM selected_records AS sr

    CROSS JOIN LATERAL (
        VALUES
            (
                'COMPOST_BARN',
                sr.compost_barn
            ),
            (
                'FREE_STALL',
                sr.free_stall
            ),
            (
                'SEMI_CONFINED',
                sr.semi_confined
            ),
            (
                'PASTURE',
                sr.pasture
            ),
            (
                'UNSTRUCTURED_CONFINMENT',
                sr.unstructured_confinment
            )
    ) AS systems(
        production_system,
        percentage
    )
),

scored_systems AS (

    -- Identifica a maior porcentagem em cada propriedade e mês.
    SELECT
        sp.*,

        MAX(sp.percentage) OVER (
            PARTITION BY
                sp.id_property,
                sp.reference_month
        ) AS maximum_percentage

    FROM system_percentages AS sp
)

SELECT
    id_property,
    reference_month,

    CASE
        -- Caso dois ou mais sistemas tenham a mesma maior
        -- porcentagem, classifica como MIXED.
        WHEN COUNT(*) FILTER (
            WHERE percentage = maximum_percentage
        ) > 1
        THEN 'MIXED'

        ELSE MAX(production_system) FILTER (
            WHERE percentage = maximum_percentage
        )
    END AS production_system

FROM scored_systems

GROUP BY
    id_property,
    reference_month;