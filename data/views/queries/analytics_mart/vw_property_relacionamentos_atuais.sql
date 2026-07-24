/*
VIEW: analytics_mart.vw_property_relacionamentos_atuais

Finalidade:
Consolida em uma única linha os relacionamentos operacionais atuais de cada
propriedade com consultor, empreendedor e agroindústria.

Granularidade:
Uma linha por propriedade.

Fontes principais:
- analytics_int.vw_dim_property_base
- analytics_int.vw_bridge_property_consultant
- analytics_int.vw_bridge_property_entrepreneur
- analytics_int.vw_bridge_property_agroindustry

Regras principais:
- Considera apenas relacionamentos operacionais atuais.
- Quando existe mais de um vínculo, seleciona o registro mais recente.
- Para consultores, utiliza também a data de criação da associação como
  critério de desempate.
- Mantém propriedades sem algum dos relacionamentos por meio de LEFT JOIN.
- Retorna também a situação cadastral e a aprovação da propriedade.

Forma de consulta:
SELECT *
FROM analytics_mart.vw_property_relacionamentos_atuais;
*/

WITH consultor_rank AS (
        SELECT b.id_property,
            b.id_consultant,
            b.consultant_name,
            b.consultant_email,
            b.valid_from,
            b.valid_to,
            b.is_current_structural,
            b.is_current_operational,
            b.consultant_is_active,
            b.property_is_active,
            b."isAssociationApproved",
            b.request_type,
            b.association_created_at,
            b."approvedAt",
            b.return_date,
            row_number() OVER (PARTITION BY b.id_property ORDER BY b.valid_from DESC, b.association_created_at DESC) AS rn

            FROM analytics_int.vw_bridge_property_consultant b
            WHERE b.is_current_operational = true
    ), entrepreneur_rank AS (
        SELECT b.id_property,
            b.id_entrepreneur,
            b.entrepreneur_name,
            b.entrepreneur_cpf,
            b.valid_from,
            b.valid_to,
            b.is_current_structural,
            b.is_current_operational,
            b.property_is_active,
            b.entrepreneur_is_active,
            row_number() OVER (PARTITION BY b.id_property ORDER BY b.valid_from DESC) AS rn

            FROM analytics_int.vw_bridge_property_entrepreneur b
            WHERE b.is_current_operational = true
    ), agro_rank AS (
        SELECT b.id_property,
            b.id_agroindustry,
            b.agroindustry_name,
            b.agroindustry_cnpj,
            b.valid_from,
            b.valid_to,
            b.is_current_structural,
            b.is_current_operational,
            b.property_is_active,
            b.agroindustry_is_active,
            row_number() OVER (PARTITION BY b.id_property ORDER BY b.valid_from DESC) AS rn
            
            FROM analytics_int.vw_bridge_property_agroindustry b
            WHERE b.is_current_operational = true
    )
SELECT d.id_property,
    d.property_name,
    d.uf,
    d.city,
    d.property_status,
    c.id_consultant,
    c.consultant_name,
    c.consultant_email,
    e.id_entrepreneur,
    e.entrepreneur_name,
    a.id_agroindustry,
    a.agroindustry_name,
    d.property_is_active,
    d.property_is_approved
    
    FROM analytics_int.vw_dim_property_base d
        LEFT JOIN consultor_rank c ON c.id_property = d.id_property AND c.rn = 1
        LEFT JOIN entrepreneur_rank e ON e.id_property = d.id_property AND e.rn = 1
        LEFT JOIN agro_rank a ON a.id_property = d.id_property AND a.rn = 1;