WITH hist AS (
    SELECT h.id_area,
        h.value AS land_value,
        h.updated_at::timestamp without time zone AS event_at,
        'AreaLandValueHistory'::text AS source
    
        FROM "AreaLandValueHistory" h
        ), fallback_area AS (
            SELECT a.id_area,
                a.raw_land_value AS land_value,
                COALESCE(a.updated_at, a.created_at, a.started_at)::timestamp without time zone AS event_at,
                'Area.raw_land_value'::text AS source
                
                FROM "Area" a
        )
SELECT hist.id_area,
    hist.land_value,
    hist.event_at,
    hist.source
    
    FROM hist
    UNION ALL
        SELECT fallback_area.id_area,
            fallback_area.land_value,
            fallback_area.event_at,
            fallback_area.source
            
            FROM fallback_area;