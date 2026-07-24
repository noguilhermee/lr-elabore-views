SELECT d.id_property,
    d.property_name,
    d.uf,
    d.city,
    b.id_consultant,
    b.consultant_name,
    b.consultant_email
    
    FROM analytics_int.vw_dim_property_base d
        LEFT JOIN analytics_int.vw_bridge_property_consultant b ON b.id_property = d.id_property AND b.is_current_operational = true;