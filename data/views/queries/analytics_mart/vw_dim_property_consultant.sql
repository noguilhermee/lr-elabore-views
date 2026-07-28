/*
VIEW: analytics_mart.vw_dim_property_consultant

Finalidade:
Dimensão de relacionamento entre consultores e propriedades em inglês, identificando
todos os vínculos de consultores com as propriedades.

Granularidade:
Uma linha por vínculo entre consultor e propriedade.

Fontes principais:
- analytics_int.vw_int_dim_property_consultant

Forma de consulta:
SELECT * FROM analytics_mart.vw_dim_property_consultant;
*/

CREATE OR REPLACE VIEW analytics_mart.vw_dim_property_consultant AS
SELECT pc.id_consultant,
       pc.consultant_name,
       pc.id_property
FROM analytics_int.vw_int_dim_property_consultant pc;
