/*
VIEW: analytics_mart.vw_dim_property

Finalidade:
Dimensão única e consolidada da propriedade rural (Fazenda). Reúne em uma
única linha por propriedade todos os atributos cadastrais, de localização,
produtor responsável, agroindústria vinculada, consultor atual e valor da terra.

Granularidade:
Uma linha por propriedade (id_property).

Fontes principais:
- analytics_int.vw_int_dim_property

Regras de negócio:
- Consome da view intermediária autônoma analytics_int.vw_int_dim_property.
- Projeta estritamente as colunas necessárias para exportação final no Excel e relatórios analíticos.
- Nomes de colunas totalmente em inglês para padronização da camada mart.

Forma de consulta:
SELECT * FROM analytics_mart.vw_dim_property;
*/

SELECT 
    p.id_property,
    p.property_name,
    p.legal_name,
    p.state_registration,
    p.labor_rural_code,
    p.agroindustry_code,
    
    -- Empreendedor / Produtor
    p.id_entrepreneur,
    p.entrepreneur_name,
    
    -- Agroindústria / Laticínio
    p.id_agroindustry,
    p.agroindustry_name,
    p.agroindustry_cnpj,
    
    -- Consultor Responsável Atual
    p.id_consultant,
    p.consultant_name,
    p.consultant_email,
    
    -- Localização
    p.uf,
    p.city,
    p.dairy_region,
    p.latitude,
    p.longitude,
    p.altitude,
    
    -- Valor da Terra
    p.raw_land_value_property,
    p.land_value_latest,
    p.land_value_updated_at,
    
    -- Status e Cadastro
    p.property_status,
    p.entry_at
FROM analytics_int.vw_int_dim_property p
ORDER BY p.id_property;
