/*
OBJETO: analytics_mart.dim_consultor_propriedade

Finalidade:
Cria uma dimensão de relacionamento entre consultores e propriedades,
identificando os usuários cadastrados com o tipo "Consultor(a)" e as
propriedades às quais estão vinculados.

Granularidade:
Uma linha por vínculo entre consultor e propriedade.

Fontes principais:
- PropertyUsers
- User
- UserType

Observação:
A consulta não aplica filtro de usuário ativo nem seleciona apenas o vínculo
mais recente. Um consultor pode aparecer em várias propriedades, e uma
propriedade pode aparecer associada a mais de um consultor.

Forma de consulta:
SELECT *
FROM analytics_mart.dim_consultor_propriedade;
*/

SELECT u.id_user AS id_consultor,
    u.name AS nome_consultor,
    pu.id_property
    
    FROM "PropertyUsers" pu
    JOIN "User" u ON u.id_user = pu.id_user
    JOIN "UserType" ut ON ut.id_type = u.id_type
    WHERE ut.name = 'Consultor(a)'::text;