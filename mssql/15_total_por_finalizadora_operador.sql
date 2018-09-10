-- Venda por operador e finalizadora
SELECT
    cast(vdo_data as date) as data,
    concat(vdo_operador,' - ', usu_nome) as operador,
    vdo_final as meio_pagto,
    fin_descricao as descricao,
    cast(sum(
        case 
            when vdo_norm_canc='N'
            then vdo_valor else vdo_valor * (-1)
        end
    ) as numeric(10,2)) as valor,
    count(distinct 
        case
            when vdo_tipo = 'V'
            then vdo_cupom
        end
    ) as qtd
FROM
    vdonline
        left join usuario
            on (vdo_operador=usu_codigo)
        left join finalizadoras
            on (vdo_final=right('00'+fin_codigo, 2))
where 
    cast(vdo_data as date) = cast(CURRENT_TIMESTAMP as date)
    and vdo_unidade = '001' --right('000'+cast(numeroLoja as varchar(3)), 3)
    and vdo_norm_canc='N'
    and vdo_final <> ''
group by
    cast(vdo_data as date),
    concat(vdo_operador,' - ', usu_nome),
    vdo_final,
    fin_descricao
order by 2,3
GO