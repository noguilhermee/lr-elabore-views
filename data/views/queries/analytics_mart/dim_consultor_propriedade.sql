/*
VIEW: analytics_mart.dim_consultor_propriedade

Finalidade:
Dimensão de relacionamento entre consultores e propriedades, identificando
os vínculos operacionalmente ativos. Consome da camada intermediária da propriedade.

Granularidade:
Uma linha por vínculo ativo entre consultor e propriedade.

Fontes principais:
- analytics_int.vw_int_dim_property

Regras de negócio:
- Consome exclusivamente da view intermediária (analytics_int.vw_int_dim_property).
- Seleciona apenas as propriedades que possuem consultor responsável cadastrado.

Forma de consulta:
SELECT * FROM analytics_mart.dim_consultor_propriedade;
*/

SELECT p.id_consultant AS id_consultor,
    p.consultant_name AS nome_consultor,
    p.id_property

FROM analytics_int.vw_int_dim_property p
WHERE p.id_consultant IS NOT NULL;