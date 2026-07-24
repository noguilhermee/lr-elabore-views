/*
VIEW: analytics_mart.vw_production

Finalidade:
Disponibiliza os registros de produção e colheita das culturas vinculadas às
áreas de cada propriedade.

Granularidade:
Uma linha por registro de produção ou colheita.

Informações principais:
- Propriedade
- Cultura
- Cultura plantada
- Mês de referência
- Área produzida ou colhida
- Quantidade produzida
- Data da colheita

Regras principais:
- Considera somente registros de produção ativos.
- Considera somente culturas plantadas ativas.
- Identifica a propriedade por meio da área vinculada à cultura plantada.
- A coluna reference_month corresponde ao primeiro dia do mês da colheita.

Observação:
A consulta não consolida os registros mensalmente. Uma propriedade pode ter
várias linhas no mesmo mês.

Forma de consulta:
SELECT *
FROM analytics_mart.vw_production;
*/

SELECT a.id_property,
    p.id_production AS id,
    pc.id_culture,
    pc.id_planted_culture,
    date_trunc('month'::text, p.produced_at)::date AS reference_month,
    p.harvested_area AS produced_area,
    p.quantity_produced AS production,
    p.produced_at AS harvest_date
    
    FROM "Production" p
        JOIN "PlantedCulture" pc ON p.id_planted_culture = pc.id_planted_culture
        JOIN "Area" a ON pc.id_area = a.id_area
    WHERE p.is_active = true AND pc.is_active = true
    ORDER BY a.id_property, (date_trunc('month'::text, p.produced_at)::date);