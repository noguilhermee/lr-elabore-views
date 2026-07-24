/* VIEW: analytics_int.vw_bridge_property_agroindustry

- Finalidade:
Relaciona cada propriedade à sua agroindústria, apresentando os dados de
identificação, o período de validade do vínculo e os indicadores de vínculo
estrutural e operacional atualmente ativos.

- Forma de consulta:
SELECT * FROM analytics_int.vw_bridge_property_agroindustry;
*/


SELECT p.id_property,
    p.id_agroindustry,
    a.name AS agroindustry_name,
    a.cnpj AS agroindustry_cnpj,
    COALESCE(p.entry_at, p.created_at) AS valid_from,
    NULL::timestamp without time zone AS valid_to,
    p.id_agroindustry IS NOT NULL AS is_current_structural,
    p.id_agroindustry IS NOT NULL AND p."isActive" = true AND COALESCE(a.is_active, true) = true AS is_current_operational,
    p."isActive" AS property_is_active,
    a.is_active AS agroindustry_is_active
    
    FROM "Property" p
        LEFT JOIN "Agroindustry" a ON a.id_agroindustry = p.id_agroindustry
    WHERE p.id_agroindustry IS NOT NULL;