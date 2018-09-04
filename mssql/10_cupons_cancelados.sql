-- Cupons cancelados
SELECT
    vdo_pdv as pdv,
    cast(vdo_data as date) as dataproc,
    cast(vdo_data as time) as hora,
    usu_nome as operador,
    'NULL' as supervisor,
    vdo_valor as valor,
    vdo_cupom as nrocupom
FROM
    vdonline
        left join usuario
            on (vdo_operador=usu_codigo)
where 
    cast(vdo_data as date) = cast(CURRENT_TIMESTAMP as date)
    and vdo_unidade = '001' --right('000'+cast(numeroLoja as varchar(3)), 3)
    and vdo_norm_canc='C'
order by "hora"
GO