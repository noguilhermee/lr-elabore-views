/*
VIEW: analytics_mart.vw_area_ativa_mes

Finalidade:
Consolida mensalmente as áreas vigentes de cada propriedade, do período
equivalente aos últimos três anos até o mês atual. Calcula as áreas próprias,
arrendadas, destinadas à atividade e destinadas à APP ou reserva, além dos
valores médios da terra ponderados pela quantidade de hectares.

Granularidade:
Uma linha por propriedade e mês.

Regras principais:
- Considera apenas áreas com data de início preenchida.
- Mantém a área nos meses compreendidos entre seu início e término.
- Recupera o valor da terra vigente em cada mês.
- Prioriza o histórico de valores da terra sobre o valor da tabela Area.
- Identifica APP ou reserva por meio do id_area_usage definido na consulta.
- Calcula os valores médios da terra de forma ponderada pelos hectares.

Forma de consulta:
SELECT *
FROM analytics_mart.vw_area_ativa_mes;
*/

WITH params AS (
        SELECT date_trunc('month'::text, CURRENT_DATE - '3 years'::interval)::date AS min_month,
        date_trunc('month'::text, CURRENT_DATE::timestamp with time zone)::date AS max_month
    ), meses AS (
        SELECT gs.gs::date AS month_start,
        (gs.gs + '1 mon -1 days'::interval)::date AS month_end
        FROM params p
            CROSS JOIN LATERAL generate_series(p.min_month::timestamp without time zone, p.max_month::timestamp without time zone, '1 mon'::interval) gs(gs)
    ), areas AS (
        SELECT ab.id_area,
        ab.id_property,
        ab.property_name,
        ab.id_area_usage,
        ab.area_usage_name,
        ab.area_name,
        ab.hectares_owned,
        ab.hectares_rented,
        ab.hectares_total,
        ab.started_at::date AS started_dt,
        COALESCE(ab.finished_at::date, '9999-12-31'::date) AS finished_dt
        FROM analytics_int.vw_area_base ab
        WHERE ab.started_at IS NOT NULL AND NOT (COALESCE(ab.is_active, false) = false AND ab.finished_at IS NULL)
    ), area_mes AS (
        SELECT a.id_area,
        a.id_property,
        a.property_name,
        a.id_area_usage,
        a.area_usage_name,
        a.area_name,
        a.hectares_owned,
        a.hectares_rented,
        a.hectares_total,
        a.started_dt,
        a.finished_dt,
        m.month_start,
        m.month_end
        FROM areas a
            JOIN meses m ON a.started_dt <= m.month_end AND a.finished_dt >= m.month_start
    ), timeline_raw AS (
        SELECT h.id_area,
        h.value AS land_value,
        h.updated_at::timestamp without time zone AS event_at,
        2 AS source_priority
        FROM "AreaLandValueHistory" h
    UNION ALL
        SELECT a.id_area,
        a.raw_land_value AS land_value,
        COALESCE(a.updated_at, a.created_at, a.started_at)::timestamp without time zone AS event_at,
        1 AS source_priority
        FROM "Area" a
    ), timeline_dedup AS (
        SELECT x.id_area,
        x.land_value,
        x.event_at
        FROM ( SELECT tr.id_area,
                tr.land_value,
                tr.event_at,
                tr.source_priority,
                row_number() OVER (PARTITION BY tr.id_area, tr.event_at ORDER BY tr.source_priority DESC) AS rn
                FROM timeline_raw tr
                WHERE tr.event_at IS NOT NULL) x
        WHERE x.rn = 1
    ), value_ranges AS (
        SELECT t.id_area,
        t.land_value,
        t.event_at AS valid_from,
        lead(t.event_at) OVER (PARTITION BY t.id_area ORDER BY t.event_at) AS valid_to
        FROM timeline_dedup t
    ), area_month_value AS (
        SELECT am.id_area,
        am.id_property,
        am.property_name,
        am.id_area_usage,
        am.area_usage_name,
        am.hectares_owned,
        am.hectares_rented,
        am.hectares_total,
        am.month_start,
        am.month_end,
        vr.land_value AS land_value_month,
        am.id_area_usage = '9bb614b8-ac9d-4327-aa9a-5c8f54c40874'::text AS is_app_reserva
        FROM area_mes am
            LEFT JOIN value_ranges vr ON vr.id_area = am.id_area AND am.month_end::timestamp without time zone >= vr.valid_from AND (vr.valid_to IS NULL OR am.month_end::timestamp without time zone < vr.valid_to)
    )
SELECT amv.id_property,
    amv.property_name,
    amv.month_start,
    amv.month_end,
    sum(amv.hectares_owned) AS hectares_propria,
    sum(amv.hectares_rented) AS hectares_arrendada,
    sum( CASE WHEN amv.is_app_reserva THEN amv.hectares_total ELSE 0::double precision END) AS hectares_app_reserva,
    sum( CASE WHEN NOT amv.is_app_reserva THEN amv.hectares_total ELSE 0::double precision END) AS hectares_atividade,
    sum(amv.hectares_total) AS hectares_area_total,
    sum(amv.land_value_month * amv.hectares_owned) / NULLIF(sum( CASE WHEN amv.land_value_month IS NOT NULL THEN amv.hectares_owned ELSE 0::double precision END), 0::double precision) AS land_value_propria,
    sum( CASE WHEN amv.is_app_reserva THEN amv.land_value_month * amv.hectares_total ELSE 0::double precision END) / NULLIF(sum( CASE WHEN amv.is_app_reserva AND amv.land_value_month IS NOT NULL THEN amv.hectares_total ELSE 0::double precision END), 0::double precision) AS land_value_app_reserva,
    sum( CASE WHEN NOT amv.is_app_reserva THEN amv.land_value_month * amv.hectares_total ELSE 0::double precision END) / NULLIF(sum( CASE WHEN NOT amv.is_app_reserva AND amv.land_value_month IS NOT NULL THEN amv.hectares_total ELSE 0::double precision END), 0::double precision) AS land_value_atividade,
    sum(amv.land_value_month * amv.hectares_total) / NULLIF(sum( CASE WHEN amv.land_value_month IS NOT NULL THEN amv.hectares_total ELSE 0::double precision END), 0::double precision) AS land_value_area_total
    
    FROM area_month_value amv
    GROUP BY amv.id_property, amv.property_name, amv.month_start, amv.month_end
    ORDER BY amv.id_property, amv.month_start;