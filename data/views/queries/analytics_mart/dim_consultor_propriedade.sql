SELECT u.id_user AS id_consultor,
    u.name AS nome_consultor,
    pu.id_property
    
    FROM "PropertyUsers" pu
    JOIN "User" u ON u.id_user = pu.id_user
    JOIN "UserType" ut ON ut.id_type = u.id_type
    WHERE ut.name = 'Consultor(a)'::text;