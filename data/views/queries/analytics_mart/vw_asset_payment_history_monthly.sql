/*
VIEW: analytics_mart.vw_asset_payment_history_monthly

Finalidade atual:
Disponibiliza os dados cadastrais e financeiros dos ativos, incluindo valor,
entrada, parcelas, taxa de juros, vida útil, datas e situação do ativo.

Granularidade:
Uma linha por ativo.

Fonte principal:
- Assets

Observação importante:
Apesar do nome "payment_history_monthly", a consulta atual não cria uma linha
por mês, não calcula parcelas mensais e não consulta uma tabela de histórico
de pagamentos. Atualmente, ela funciona apenas como uma extração da tabela
Assets.

Forma de consulta:
SELECT *
FROM analytics_mart.vw_asset_payment_history_monthly;
*/

SELECT "Assets".id_asset,
    "Assets".id_property,
    "Assets".id_classification,
    "Assets".id_type,
    "Assets".name,
    "Assets".quantity,
    "Assets".acquired_at,
    "Assets".value,
    "Assets".corrected,
    "Assets".finished_at,
    "Assets".service_life,
    "Assets".installment,
    "Assets".is_active,
    "Assets".created_at,
    "Assets".updated_at,
    "Assets".down_payment,
    "Assets".interest_rate,
    "Assets".installment_yearly,
    "Assets".is_in_construction,
    "Assets".depreciation_starts_at,
    "Assets".activity_usage_percent
    
FROM "Assets";