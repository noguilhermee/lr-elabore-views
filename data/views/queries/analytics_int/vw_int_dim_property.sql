/*
VIEW: analytics_int.vw_int_dim_property

Finalidade:
Cria a dimensão cadastral intermediária consolidada das propriedades rurais, reunindo em
uma única linha por propriedade os dados da fazenda, empreendedor, agroindústria,
consultor operacional atual, localização e valor mais recente da terra.

Granularidade:
Uma linha por propriedade (id_property).

Fontes principais:
- public.Property
- public.Entrepreneur
- public.Agroindustry
- public.PropertyUsers
- public.User
- public.UserType
- public.PropertyLandValueHistory

Regras de negócio:
- Consolida os dados cadastrais da propriedade com o produtor e agroindústria ativos.
- Inclui a sub-consulta do consultor operacional ativo mais recente (desempate por data de associação).
- Calcula o valor da terra mais recente via ordenação por data de atualização.

Forma de consulta:
SELECT * FROM analytics_int.vw_int_dim_property;
*/

WITH latest_land_value AS (
    SELECT plvh.id_property,
           plvh.value AS land_value_latest,
           plvh.updated_at AS land_value_updated_at,
           row_number() OVER (PARTITION BY plvh.id_property ORDER BY plvh.updated_at DESC, plvh.created_at DESC) AS rn
    FROM "PropertyLandValueHistory" plvh
),
current_consultant AS (
    SELECT pu.id_property,
           pu.id_user AS id_consultant,
           u.name AS consultant_name,
           u.email AS consultant_email,
           row_number() OVER (
               PARTITION BY pu.id_property 
               ORDER BY COALESCE(pu."approvedAt", pu.created_at) DESC, pu.created_at DESC
           ) AS rn
    FROM "PropertyUsers" pu
        JOIN "User" u ON u.id_user = pu.id_user
        JOIN "UserType" ut ON ut.id_type = u.id_type
        JOIN "Property" p ON p.id_property = pu.id_property
    WHERE ut.name = 'Consultor(a)'::text
      AND pu.return_date IS NULL 
      AND pu."isAssociationApproved" = true 
      AND u."isActive" = true 
      AND p."isActive" = true
)
SELECT p.id_property,
    p.property_name,
    p.legal_name,
    p.state_registration,
    p.labor_rural_code,
    p.agroindustry_code,
    
    -- Produtor
    p.id_entrepreneur,
    e.name AS entrepreneur_name,
    
    -- Agroindústria / Laticínio
    p.id_agroindustry,
    a.name AS agroindustry_name,
    a.cnpj AS agroindustry_cnpj,
    
    -- Consultor Responsável Atual
    cc.id_consultant,
    cc.consultant_name,
    cc.consultant_email,
    
    -- Localização
    p.latitude,
    p.longitude,
    p.altitude,
    p.uf,
    p.city,
    p.dairy_region,
    
    -- Status e Cadastro
    p."isActive" AS property_is_active,
    p."isApproved" AS property_is_approved,
    p.entry_at,
    p.created_at,
    p.updated_at,
    
    -- Valor da Terra
    p.raw_land_value AS raw_land_value_property,
    llv.land_value_latest,
    llv.land_value_updated_at,
    
    CASE
        WHEN p."isActive" = true AND p."isApproved" = true THEN 'active_approved'::text
        WHEN p."isActive" = true AND p."isApproved" = false THEN 'active_pending'::text
        ELSE 'inactive'::text
    END AS property_status

FROM "Property" p
    LEFT JOIN "Entrepreneur" e ON e.id_entrepreneur = p.id_entrepreneur
    LEFT JOIN "Agroindustry" a ON a.id_agroindustry = p.id_agroindustry
    LEFT JOIN latest_land_value llv ON llv.id_property = p.id_property AND llv.rn = 1
    LEFT JOIN current_consultant cc ON cc.id_property = p.id_property AND cc.rn = 1;
