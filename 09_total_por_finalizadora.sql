-- Venda por finalizadora
SELECT
    vdo_final as meio_pagto,
    fin_descricao as descricao,
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
            on (vdo_final=lpad(fin_codigo::text, 2,'0'))
where 
    (
        vdo_data >= CURRENT_DATE 
        and vdo_data < CURRENT_DATE + interval '1 day'
    )
    and vdo_unidade = lpad(cast(numeroLoja as varchar),3,'0')
    and vdo_tipo in('V','v')
group by vdo_final, fin_descricao
order by 1;
