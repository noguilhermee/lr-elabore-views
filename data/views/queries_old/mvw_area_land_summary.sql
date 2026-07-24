CREATE MATERIALIZED VIEW analytics_mart.mvw_area_land_summary AS
WITH area_usage_map AS (
    SELECT
        a.id_area,
        a.id_property,
        a.hectares_owned,
        a.hectares_rented,
        a.raw_land_value,
        a.started_at,
        a.finished_at,
        a.is_active,
        au.name AS area_usage_type
    FROM "Area" a
    JOIN "AreaUsage" au
        ON a.id_area_usage = au.id_area_usage
    WHERE NOT (a.is_active = FALSE AND a.finished_at IS NULL)
),

area_timeline AS (
    SELECT
        m.id_area,
        m.id_property,
        m.area_usage_type,
        m.hectares_owned,
        m.hectares_rented,
        m.raw_land_value,
        gs.reference_month::date AS reference_month
    FROM area_usage_map m
    CROSS JOIN LATERAL generate_series(
        date_trunc('month', m.started_at),
        date_trunc('month', COALESCE(m.finished_at, CURRENT_DATE)),
        interval '1 month'
    ) AS gs(reference_month)
),

area_pivot AS (
    SELECT
        id_area,
        id_property,
        reference_month,
        CASE WHEN area_usage_type = 'Área de Benfeitorias e Estradas' THEN hectares_owned END AS hectares_owned_benfeitorias_estradas,
        CASE WHEN area_usage_type = 'Reserva Legal e APP'              THEN hectares_owned END AS hectares_owned_app_reserva_legal,
        CASE WHEN area_usage_type = 'Forrageiras'                      THEN hectares_owned END AS hectares_owned_forrageiras,

        CASE WHEN area_usage_type = 'Área de Benfeitorias e Estradas' THEN hectares_rented END AS hectares_rented_benfeitorias_estradas,
        CASE WHEN area_usage_type = 'Reserva Legal e APP'              THEN hectares_rented END AS hectares_rented_app_reserva_legal,
        CASE WHEN area_usage_type = 'Forrageiras'                      THEN hectares_rented END AS hectares_rented_forrageiras,

        CASE WHEN area_usage_type = 'Área de Benfeitorias e Estradas' THEN raw_land_value END AS raw_land_value_benfeitorias_estradas,
        CASE WHEN area_usage_type = 'Reserva Legal e APP'              THEN raw_land_value END AS raw_land_value_app_reserva_legal,
        CASE WHEN area_usage_type = 'Forrageiras'                      THEN raw_land_value END AS raw_land_value_forrageiras
    FROM area_timeline
)

SELECT
    id_property,
    reference_month,

    SUM(hectares_owned_benfeitorias_estradas) AS hectares_owned_benfeitorias_estradas,
    SUM(hectares_owned_app_reserva_legal)     AS hectares_owned_app_reserva_legal,
    SUM(hectares_owned_forrageiras)           AS hectares_owned_forrageiras,

    SUM(hectares_rented_benfeitorias_estradas) AS hectares_rented_benfeitorias_estradas,
    SUM(hectares_rented_app_reserva_legal)     AS hectares_rented_app_reserva_legal,
    SUM(hectares_rented_forrageiras)           AS hectares_rented_forrageiras,

    SUM(raw_land_value_benfeitorias_estradas * hectares_owned_benfeitorias_estradas)
        / NULLIF(SUM(hectares_owned_benfeitorias_estradas), 0) AS raw_land_value_benfeitorias_estradas,

    SUM(raw_land_value_app_reserva_legal * hectares_owned_app_reserva_legal)
        / NULLIF(SUM(hectares_owned_app_reserva_legal), 0) AS raw_land_value_app_reserva_legal,

    SUM(raw_land_value_forrageiras * hectares_owned_forrageiras)
        / NULLIF(SUM(hectares_owned_forrageiras), 0) AS raw_land_value_forrageiras

FROM area_pivot
GROUP BY id_property, reference_month
WITH DATA;