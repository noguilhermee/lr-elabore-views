/*
VIEW: analytics_mart.vw_dairy_production_system_monthly

Finalidade:
Classifica mensalmente o sistema predominante de produção de leite utilizado
por cada propriedade.

Granularidade:
Uma linha por propriedade e mês (id_property + reference_month).

Fontes principais:
- analytics_int.vw_int_dairy_production

Regras de negócio:
- Consome da view intermediária analytics_int.vw_int_dairy_production (já filtrada para categoria LACTATION e expandida mês a mês).
- Quando existem vários registros no mesmo mês, seleciona o mais recente.
- Sistemas avaliados: COMPOST_BARN, FREE_STALL, SEMI_CONFINED, PASTURE, UNSTRUCTURED_CONFINMENT.
- Classifica como predominante o sistema com maior percentual.
- Retorna MIXED quando dois ou mais sistemas possuem o mesmo maior percentual.

Forma de consulta:
SELECT * FROM analytics_mart.vw_dairy_production_system_monthly;
*/

WITH expanded_months AS (
        SELECT dpb.id_dairy,
            dpb.id_property,
            dpb.compost_barn,
            dpb.free_stall,
            dpb.semi_confined,
            dpb.pasture,
            dpb.unstructured_confinment,
            dpb.started_at,
            dpb.finished_at,
            dpb.created_at,
            dpb.updated_at,
            dpb.reference_month
            FROM analytics_int.vw_int_dairy_production dpb
    ), ranked_records AS (
        SELECT em.id_dairy,
            em.id_property,
            em.compost_barn,
            em.free_stall,
            em.semi_confined,
            em.pasture,
            em.unstructured_confinment,
            em.started_at,
            em.finished_at,
            em.created_at,
            em.updated_at,
            em.reference_month,
            row_number() OVER (PARTITION BY em.id_property, em.reference_month ORDER BY em.started_at DESC, em.updated_at DESC NULLS LAST, em.created_at DESC NULLS LAST, em.id_dairy DESC) AS record_order
            FROM expanded_months em
    ), selected_records AS (
        SELECT ranked_records.id_property,
        ranked_records.reference_month,
        COALESCE(ranked_records.compost_barn, 0) AS compost_barn,
        COALESCE(ranked_records.free_stall, 0) AS free_stall,
        COALESCE(ranked_records.semi_confined, 0) AS semi_confined,
        COALESCE(ranked_records.pasture, 0) AS pasture,
        COALESCE(ranked_records.unstructured_confinment, 0) AS unstructured_confinment
        FROM ranked_records
        WHERE ranked_records.record_order = 1
    ), system_percentages AS (
        SELECT sr.id_property,
        sr.reference_month,
        systems.production_system,
        systems.percentage
        FROM selected_records sr
            CROSS JOIN LATERAL ( VALUES ('COMPOST_BARN'::text,sr.compost_barn), ('FREE_STALL'::text,sr.free_stall), ('SEMI_CONFINED'::text,sr.semi_confined), ('PASTURE'::text,sr.pasture), ('UNSTRUCTURED_CONFINMENT'::text,sr.unstructured_confinment)) systems(production_system, percentage)
    ), scored_systems AS (
        SELECT sp.id_property,
        sp.reference_month,
        sp.production_system,
        sp.percentage,
        max(sp.percentage) OVER (PARTITION BY sp.id_property, sp.reference_month) AS maximum_percentage
        FROM system_percentages sp
    )
SELECT scored_systems.id_property,
    scored_systems.reference_month,
    
    CASE
        WHEN count(*) FILTER (WHERE scored_systems.percentage = scored_systems.maximum_percentage) > 1 THEN 'MIXED'::text
        ELSE max(scored_systems.production_system) FILTER (WHERE scored_systems.percentage = scored_systems.maximum_percentage)
    END AS production_system
    FROM scored_systems
    GROUP BY scored_systems.id_property, scored_systems.reference_month;