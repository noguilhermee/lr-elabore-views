WITH params AS (
        SELECT '2025-01-01'::date AS min_month,
        date_trunc('month'::text, CURRENT_DATE::timestamp with time zone)::date AS max_month
    ), months AS (
        SELECT gs.reference_month::date AS reference_month,
        (gs.reference_month + '1 mon'::interval - '1 day'::interval)::date AS month_end
        FROM params p
            CROSS JOIN LATERAL generate_series(p.min_month::timestamp with time zone, p.max_month::timestamp with time zone, '1 mon'::interval) gs(reference_month)
    ), active_area_months AS (
        SELECT ab.id_area,
            ab.id_property,
            ab.property_name,
            ab.id_area_usage,
            ab.area_usage_name,
            ab.area_name,
            COALESCE(ab.hectares_owned, 0::double precision)::numeric AS hectares_owned,
            COALESCE(ab.hectares_rented, 0::double precision)::numeric AS hectares_rented,
            COALESCE(ab.hectares_total, 0::double precision)::numeric AS hectares_total,
            ab.raw_land_value::numeric AS current_land_value,
            ab.started_at,
            ab.finished_at,
            ab.created_at,
            ab.updated_at,
            m.reference_month,
            m.month_end
            
            FROM analytics_int.vw_area_base ab
                JOIN months m ON ab.started_at::date <= m.month_end AND COALESCE(ab.finished_at::date, '9999-12-31'::date) >= m.reference_month
            WHERE ab.started_at IS NOT NULL AND NOT (COALESCE(ab.is_active, false) = false AND ab.finished_at IS NULL)
    ), area_month_values AS (
        SELECT am.id_area,
            am.id_property,
            am.property_name,
            am.id_area_usage,
            am.area_usage_name,
            am.area_name,
            am.hectares_owned,
            am.hectares_rented,
            am.hectares_total,
            am.current_land_value,
            am.started_at,
            am.finished_at,
            am.created_at,
            am.updated_at,
            am.reference_month,
            am.month_end,
            COALESCE(history_value.land_value, CASE WHEN NOT (EXISTS ( SELECT 1 FROM "AreaLandValueHistory" any_history WHERE any_history.id_area = am.id_area)) THEN am.current_land_value ELSE NULL::numeric END) AS land_value_per_hectare,
            COALESCE(history_value.value_reference_date, CASE WHEN NOT (EXISTS ( SELECT 1 FROM "AreaLandValueHistory" any_history WHERE any_history.id_area = am.id_area)) THEN am.started_at::date ELSE NULL::date END) AS land_value_reference_date
            
            FROM active_area_months am
                LEFT JOIN LATERAL ( SELECT h.value::numeric AS land_value,
                        h.updated_at::date AS value_reference_date
                    FROM "AreaLandValueHistory" h
                    WHERE h.id_area = am.id_area AND h.updated_at < (am.reference_month + '1 mon'::interval)
                    ORDER BY h.updated_at DESC, h.created_at DESC, h.id DESC
                    LIMIT 1) history_value ON true
    )
SELECT area_month_values.id_area,
    area_month_values.id_property,
    area_month_values.id_area_usage,
    area_month_values.property_name,
    area_month_values.area_usage_name,
    area_month_values.area_name,
    area_month_values.started_at,
    area_month_values.finished_at,
    area_month_values.reference_month,
    area_month_values.month_end,
    round(area_month_values.hectares_owned, 4) AS hectares_owned,
    round(area_month_values.hectares_rented, 4) AS hectares_rented,
    round(area_month_values.hectares_total, 4) AS hectares_total,
    round(area_month_values.land_value_per_hectare, 2) AS land_value_per_hectare,
    area_month_values.land_value_reference_date,
    area_month_values.id_area_usage = '9bb614b8-ac9d-4327-aa9a-5c8f54c40874'::text AS is_app_reserva
    
    FROM area_month_values;