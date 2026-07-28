 SELECT mvw_area_land_summary.id_property,
    mvw_area_land_summary.reference_month,
    mvw_area_land_summary.hectares_owned_benfeitorias_estradas,
    mvw_area_land_summary.hectares_owned_app_reserva_legal,
    mvw_area_land_summary.hectares_owned_forrageiras,
    mvw_area_land_summary.hectares_rented_benfeitorias_estradas,
    mvw_area_land_summary.hectares_rented_app_reserva_legal,
    mvw_area_land_summary.hectares_rented_forrageiras,
    mvw_area_land_summary.raw_land_value_benfeitorias_estradas,
    mvw_area_land_summary.raw_land_value_app_reserva_legal,
    mvw_area_land_summary.raw_land_value_forrageiras
   FROM analytics_mart.mvw_area_land_summary;