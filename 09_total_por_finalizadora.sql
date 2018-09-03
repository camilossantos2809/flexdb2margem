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
    count(distinct vdo_cupom) filter (where vdo_tipo='V') as qtd
FROM
    vdonline
        left join finalizadoras
            on (
                vdo_final=lpad(fin_codigo::text, 2,'0')
            )
where 
    (
        vdo_data >= CURRENT_DATE 
        and vdo_data < CURRENT_DATE + interval '1 day'
    )
    and vdo_unidade = '001'--lpad(cast(numeroLoja as varchar),3,'0')
    and vdo_tipo in('V','v')
    and vdo_final <> ''
group by vdo_final, fin_descricao
order by 1;