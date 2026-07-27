/*
VIEW: analytics_mart.dim_consultor_propriedade

Finalidade:
Dimensão de relacionamento entre consultores e propriedades, identificando
os vínculos operacionalmente ativos. Consome da bridge intermediária para
evitar duplicação de lógica de deduplicação e vigência.

Granularidade:
Uma linha por vínculo ativo entre consultor e propriedade.

Fontes principais:
- analytics_int.vw_bridge_property_consultant

Regras de negócio:
- Consome exclusivamente da bridge intermediária (analytics_int).
- Filtra apenas vínculos operacionalmente ativos (is_current_operational).
- Um consultor pode aparecer em várias propriedades.
- Uma propriedade pode ter mais de um consultor vinculado.
- A deduplicação de vínculos duplicados é feita na bridge (analytics_int).

Forma de consulta:
SELECT * FROM analytics_mart.dim_consultor_propriedade;
*/

SELECT bpc.id_consultant AS id_consultor,
    bpc.consultant_name AS nome_consultor,
    bpc.id_property
    
    FROM analytics_int.vw_bridge_property_consultant bpc
    WHERE bpc.is_current_operational = true;