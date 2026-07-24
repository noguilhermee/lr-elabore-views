SELECT p.id_property,
    p.id_entrepreneur,
    e.name AS entrepreneur_name,
    e.cpf AS entrepreneur_cpf,
    COALESCE(p.entry_at, p.created_at) AS valid_from,
    NULL::timestamp without time zone AS valid_to,
    p.id_entrepreneur IS NOT NULL AS is_current_structural,
    p.id_entrepreneur IS NOT NULL AND p."isActive" = true AND COALESCE(e."isActive", true) = true AS is_current_operational,
    p."isActive" AS property_is_active,
    e."isActive" AS entrepreneur_is_active
    
    FROM "Property" p
        LEFT JOIN "Entrepreneur" e ON e.id_entrepreneur = p.id_entrepreneur
    WHERE p.id_entrepreneur IS NOT NULL;