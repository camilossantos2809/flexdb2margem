-- Venda por operador e finalizadora

with fin as (
    select
        lpad(fin_codigo::text, 2,'0') as codigo,
        fin_config,
        upper(fin_descricao) as fin_descricao
    from finalizadoras
    group by 1, 2, 3
)
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
    count(distinct vdo_cupom) filter (where vdo_tipo='V') as qtd
FROM
    vdonline
        left join usuario
            on (vdo_operador=usu_codigo)
        inner join estac
            on (vdo_pdv = est_pdv)
        inner join fin
            on (
                vdo_final=codigo
                and fin_config=est_conf_final
            )
where 
    (
        vdo_data >= CURRENT_DATE 
        and vdo_data < CURRENT_DATE + interval '1 day'
    )
    and vdo_unidade = '001'--lpad(cast(numeroLoja as varchar),3,'0')
    and vdo_tipo in('V','v')
    and vdo_final <> ''
group by
    cast(vdo_data as date),
    concat(vdo_operador,' - ', usu_nome),
    vdo_final,
    fin_descricao
order by 2,3;
