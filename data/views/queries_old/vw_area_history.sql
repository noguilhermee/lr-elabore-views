CREATE OR REPLACE VIEW analytics_mart.vw_area_history AS

WITH params AS (
    SELECT
        DATE '2025-01-01' AS min_month,
        DATE_TRUNC('month', CURRENT_DATE)::date AS max_month
),

months AS (
    SELECT
        gs.reference_month::date AS reference_month,
        (
            gs.reference_month
            + INTERVAL '1 month'
            - INTERVAL '1 day'
        )::date AS month_end

    FROM params p

    CROSS JOIN LATERAL GENERATE_SERIES(
        p.min_month,
        p.max_month,
        INTERVAL '1 month'
    ) AS gs(reference_month)
),

active_area_months AS (
    SELECT
        ab.id_area,
        ab.id_property,
        ab.property_name,
        ab.id_area_usage,
        ab.area_usage_name,
        ab.area_name,

        COALESCE(ab.hectares_owned, 0)::numeric AS hectares_owned,
        COALESCE(ab.hectares_rented, 0)::numeric AS hectares_rented,
        COALESCE(ab.hectares_total, 0)::numeric AS hectares_total,

        ab.raw_land_value::numeric AS current_land_value,
        ab.started_at,
        ab.finished_at,
        ab.created_at,
        ab.updated_at,

        m.reference_month,
        m.month_end

    FROM analytics_int.vw_area_base ab

    JOIN months m
      ON ab.started_at::date <= m.month_end
     AND COALESCE(ab.finished_at::date, DATE '9999-12-31')
         >= m.reference_month

    WHERE ab.started_at IS NOT NULL
      AND NOT (
          COALESCE(ab.is_active, FALSE) = FALSE
          AND ab.finished_at IS NULL
      )
),

area_month_values AS (
    SELECT
        am.*,

        COALESCE(
            history_value.land_value,
            CASE
                WHEN NOT EXISTS (
                    SELECT 1
                    FROM "AreaLandValueHistory" any_history
                    WHERE any_history.id_area = am.id_area
                )
                THEN am.current_land_value
            END
        )::numeric AS land_value_per_hectare,

        COALESCE(
            history_value.value_reference_date,
            CASE
                WHEN NOT EXISTS (
                    SELECT 1
                    FROM "AreaLandValueHistory" any_history
                    WHERE any_history.id_area = am.id_area
                )
                THEN am.started_at::date
            END
        ) AS land_value_reference_date

    FROM active_area_months am

    LEFT JOIN LATERAL (
        SELECT
            h.value::numeric AS land_value,
            h.updated_at::date AS value_reference_date

        FROM "AreaLandValueHistory" h

        WHERE h.id_area = am.id_area
          AND h.updated_at
              < am.reference_month + INTERVAL '1 month'

        ORDER BY
            h.updated_at DESC,
            h.created_at DESC,
            h.id DESC

        LIMIT 1
    ) history_value ON TRUE
)

SELECT
    id_area,
    id_property,
    property_name,
    id_area_usage,
    area_usage_name,
    area_name,

    started_at,
    finished_at,
    reference_month,
    month_end,

    ROUND(hectares_owned, 4) AS hectares_owned,
    ROUND(hectares_rented, 4) AS hectares_rented,
    ROUND(hectares_total, 4) AS hectares_total,

    ROUND(land_value_per_hectare, 2) AS land_value_per_hectare,
    land_value_reference_date,

    ROUND(
        land_value_per_hectare * hectares_owned,
        2
    ) AS gross_capital_stock_owned,

    ROUND(
        land_value_per_hectare * hectares_rented,
        2
    ) AS gross_capital_stock_rented,

    ROUND(
        land_value_per_hectare * hectares_total,
        2
    ) AS gross_capital_stock_total,

    (
        id_area_usage = '9bb614b8-ac9d-4327-aa9a-5c8f54c40874'
    ) AS is_app_reserva

FROM area_month_values;


-- Consulta de validação no pgAdmin:
SELECT *
FROM analytics_mart.vw_area_history
ORDER BY id_property, reference_month, id_area
LIMIT 1000;
