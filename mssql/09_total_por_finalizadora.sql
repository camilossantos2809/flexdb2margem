-- Venda por finalizadora/meio de pagamento

SELECT
    case
        when vdo_final is null or vdo_final=''
        then null else vdo_final
    end as meio_pagto,
    case
        when fin_descricao is null or fin_descricao = ''
        then null else fin_descricao
    end as descricao,
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
        left join finalizadoras
            on (vdo_final=right('00'+fin_codigo, 2))
where 
    cast(vdo_data as date) = cast(CURRENT_TIMESTAMP as date)
    and vdo_unidade = '001' --right('000'+cast(numeroLoja as varchar(3)), 3)
    and vdo_norm_canc = 'N'
    and vdo_final <> ''
group by vdo_final, fin_descricao
order by 1
GO