with vendas as (
    select
        tvd_unidade,
        tvd_data_hora,
        tvd_pdv,
        tvd_cupom,
        tvd_operador,
        tvd_cpseq,
        string_to_array(tvd_registro, '|') as tvd_registro
    from tab_venda_0518
    where
        (
            tvd_data_hora >= CURRENT_DATE 
            and tvd_data_hora < CURRENT_DATE + interval '1 day'
        )
        and tvd_tipo_reg = 'VITN'
        and tvd_unidade = '001'
)
select
    cast(tvd_data_hora as date) as dataproc,
    cast(tvd_data_hora as time) as hora,
    tvd_operador as operador,
    tvd_registro[22] as supervisor,
    round(cast(tvd_registro[29] as numeric)/100,2) as valor,
    tvd_cupom as nro_cupom,
    cast(tvd_cpseq as integer)-1 as item,
    tvd_registro[1] as codigo_ean,
    tvd_registro[2] as desc_item
from vendas
where tvd_registro[29]<>'';