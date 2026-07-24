/* VIEW: analytics_int.vw_bridge_property_consultant

- Finalidade:
Consolida os vínculos entre propriedades e consultores, incluindo o período
de validade, a situação da aprovação, o status operacional e a remoção de
registros duplicados do mesmo vínculo.

- Forma de consulta:
SELECT *
FROM analytics_int.vw_bridge_property_consultant;

*/

WITH consultant_links AS (
    SELECT pu.id_property,
        pu.id_user AS id_consultant,
        u.name AS consultant_name,
        u.email AS consultant_email,
        u."isActive" AS consultant_is_active,
        p."isActive" AS property_is_active,
        pu."isAssociationApproved",
        pu.request_type,
        pu.created_at AS association_created_at,
        pu."approvedAt",
        pu.return_date,
        COALESCE(pu."approvedAt", pu.created_at) AS valid_from,
        pu.return_date AS valid_to,
        row_number() OVER (PARTITION BY pu.id_property, pu.id_user, (COALESCE(pu."approvedAt", pu.created_at)) ORDER BY pu.created_at DESC) AS rn_dedup
        
    FROM "PropertyUsers" pu
        JOIN "User" u ON u.id_user = pu.id_user
        JOIN "UserType" ut ON ut.id_type = u.id_type
        JOIN "Property" p ON p.id_property = pu.id_property
    WHERE ut.name = 'Consultor(a)'::text
)
SELECT consultant_links.id_property,
    consultant_links.id_consultant,
    consultant_links.consultant_name,
    consultant_links.consultant_email,
    consultant_links.valid_from,
    consultant_links.valid_to,
    consultant_links.valid_to IS NULL AND consultant_links."isAssociationApproved" = true AS is_current_structural,
    consultant_links.valid_to IS NULL AND consultant_links."isAssociationApproved" = true AND consultant_links.consultant_is_active = true AND consultant_links.property_is_active = true AS is_current_operational,
    consultant_links.consultant_is_active,
    consultant_links.property_is_active,
    consultant_links."isAssociationApproved",
    consultant_links.request_type,
    consultant_links.association_created_at,
    consultant_links."approvedAt",
    consultant_links.return_date
    
    FROM consultant_links
    WHERE consultant_links.rn_dedup = 1;