/*
VIEW: analytics_mart.vw_property_consultor_atual

Finalidade:
Relaciona as propriedades cadastradas aos consultores que possuem vínculo
operacional vigente.

Granularidade:
Uma linha por propriedade e consultor operacional atual.

Fontes principais:
- analytics_int.vw_dim_property_base
- analytics_int.vw_bridge_property_consultant

Informações retornadas:
- Identificação e nome da propriedade
- UF e município
- Identificação, nome e e-mail do consultor

Observação:
A consulta não utiliza ranking para escolher somente um consultor. Caso uma
propriedade possua mais de um vínculo operacional atual, ela poderá aparecer
em várias linhas. Propriedades sem consultor também são mantidas devido ao
LEFT JOIN.

Forma de consulta:
SELECT *
FROM analytics_mart.vw_property_consultor_atual;
*/

SELECT d.id_property,
    d.property_name,
    d.uf,
    d.city,
    b.id_consultant,
    b.consultant_name,
    b.consultant_email
    
    FROM analytics_int.vw_dim_property_base d
        LEFT JOIN analytics_int.vw_bridge_property_consultant b ON b.id_property = d.id_property AND b.is_current_operational = true;