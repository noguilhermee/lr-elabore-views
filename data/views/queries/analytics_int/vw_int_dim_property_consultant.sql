/*
VIEW: analytics_int.vw_int_dim_property_consultant

Finalidade:
Mapeia todos os vínculos de consultores com propriedades rurais (incluindo vínculos históricos).

Granularidade:
Uma linha por vínculo entre consultor e propriedade (id_property + id_consultant).

Fontes principais:
- public.PropertyUsers
- public.User
- public.UserType

Regras de negócio:
- Seleciona todos os vínculos de usuários do tipo "Consultor(a)".
- Preserva a cardinalidade histórica N:N (múltiplos consultores por propriedade).

Forma de consulta:
SELECT * FROM analytics_int.vw_int_dim_property_consultant;
*/

CREATE OR REPLACE VIEW analytics_int.vw_int_dim_property_consultant AS
SELECT pu.id_property,
       pu.id_user AS id_consultant,
       u.name AS consultant_name,
       u.email AS consultant_email
FROM "PropertyUsers" pu
    JOIN "User" u ON u.id_user = pu.id_user
    JOIN "UserType" ut ON ut.id_type = u.id_type
WHERE ut.name = 'Consultor(a)'::text;

