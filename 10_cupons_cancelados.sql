-- Cupons cancelados
SELECT
    vdo_pdv as pdv,
    cast(vdo_data as date) as dataproc,
    cast(vdo_data as time) as hora,
    usu_nome as operador,
    'null' as supervisor,
    vdo_valor as valor,
    vdo_cupom as nrocupom
FROM
    vdonline
        left join usuario
            on (vdo_operador=usu_codigo)
where 
    (
        vdo_data >= CURRENT_DATE 
        and vdo_data < CURRENT_DATE + interval '1 day'
    )
    and vdo_unidade = '001'
    and vdo_norm_canc='C'
order by "hora";
