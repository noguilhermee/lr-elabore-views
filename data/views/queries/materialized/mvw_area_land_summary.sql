WITH area_usage_map AS (
        SELECT a.id_area,
        a.id_property,
        a.hectares_owned,
        a.hectares_rented,
        a.raw_land_value,
        a.started_at,
        a.finished_at,
        a.is_active,
        au.name AS area_usage_type
        FROM "Area" a
            JOIN "AreaUsage" au ON a.id_area_usage = au.id_area_usage
        WHERE NOT (a.is_active = false AND a.finished_at IS NULL)
    ), area_timeline AS (
        SELECT m.id_area,
        m.id_property,
        m.area_usage_type,
        m.hectares_owned,
        m.hectares_rented,
        m.raw_land_value,
        gs.reference_month::date AS reference_month
        FROM area_usage_map m
            CROSS JOIN LATERAL generate_series(date_trunc('month'::text, m.started_at), date_trunc('month'::text, COALESCE(m.finished_at, CURRENT_DATE::timestamp without time zone)), '1 mon'::interval) gs(reference_month)
    ), area_pivot AS (
        SELECT area_timeline.id_area,
        area_timeline.id_property,
        area_timeline.reference_month,
            CASE
                WHEN area_timeline.area_usage_type = 'Área de Benfeitorias e Estradas'::text THEN area_timeline.hectares_owned
                ELSE NULL::double precision
            END AS hectares_owned_benfeitorias_estradas,
            CASE
                WHEN area_timeline.area_usage_type = 'Reserva Legal e APP'::text THEN area_timeline.hectares_owned
                ELSE NULL::double precision
            END AS hectares_owned_app_reserva_legal,
            CASE
                WHEN area_timeline.area_usage_type = 'Forrageiras'::text THEN area_timeline.hectares_owned
                ELSE NULL::double precision
            END AS hectares_owned_forrageiras,
            CASE
                WHEN area_timeline.area_usage_type = 'Área de Benfeitorias e Estradas'::text THEN area_timeline.hectares_rented
                ELSE NULL::double precision
            END AS hectares_rented_benfeitorias_estradas,
            CASE
                WHEN area_timeline.area_usage_type = 'Reserva Legal e APP'::text THEN area_timeline.hectares_rented
                ELSE NULL::double precision
            END AS hectares_rented_app_reserva_legal,
            CASE
                WHEN area_timeline.area_usage_type = 'Forrageiras'::text THEN area_timeline.hectares_rented
                ELSE NULL::double precision
            END AS hectares_rented_forrageiras,
            CASE
                WHEN area_timeline.area_usage_type = 'Área de Benfeitorias e Estradas'::text THEN area_timeline.raw_land_value
                ELSE NULL::double precision
            END AS raw_land_value_benfeitorias_estradas,
            CASE
                WHEN area_timeline.area_usage_type = 'Reserva Legal e APP'::text THEN area_timeline.raw_land_value
                ELSE NULL::double precision
            END AS raw_land_value_app_reserva_legal,
            CASE
                WHEN area_timeline.area_usage_type = 'Forrageiras'::text THEN area_timeline.raw_land_value
                ELSE NULL::double precision
            END AS raw_land_value_forrageiras
        FROM area_timeline
    )
SELECT area_pivot.id_property,
    area_pivot.reference_month,
    sum(area_pivot.hectares_owned_benfeitorias_estradas) AS hectares_owned_benfeitorias_estradas,
    sum(area_pivot.hectares_owned_app_reserva_legal) AS hectares_owned_app_reserva_legal,
    sum(area_pivot.hectares_owned_forrageiras) AS hectares_owned_forrageiras,
    sum(area_pivot.hectares_rented_benfeitorias_estradas) AS hectares_rented_benfeitorias_estradas,
    sum(area_pivot.hectares_rented_app_reserva_legal) AS hectares_rented_app_reserva_legal,
    sum(area_pivot.hectares_rented_forrageiras) AS hectares_rented_forrageiras,
    sum(area_pivot.raw_land_value_benfeitorias_estradas * area_pivot.hectares_owned_benfeitorias_estradas) / NULLIF(sum(area_pivot.hectares_owned_benfeitorias_estradas), 0::double precision) AS raw_land_value_benfeitorias_estradas,
    sum(area_pivot.raw_land_value_app_reserva_legal * area_pivot.hectares_owned_app_reserva_legal) / NULLIF(sum(area_pivot.hectares_owned_app_reserva_legal), 0::double precision) AS raw_land_value_app_reserva_legal,
    sum(area_pivot.raw_land_value_forrageiras * area_pivot.hectares_owned_forrageiras) / NULLIF(sum(area_pivot.hectares_owned_forrageiras), 0::double precision) AS raw_land_value_forrageiras
    
    FROM area_pivot
    GROUP BY area_pivot.id_property, area_pivot.reference_month;