-- Venda por finalizadora/meio de pagamento

with fin as (
    select
        lpad(fin_codigo::text, 2,'0') as codigo,
        fin_config,
        upper(fin_descricao) as fin_descricao
    from finalizadoras
    group by 1, 2, 3
)
SELECT
    case
        when vdo_final is null or vdo_final=''
        then null else fin_config || vdo_final
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
    count(distinct (vdo_cupom, vdo_pdv)) filter (where vdo_tipo='V') as qtd
FROM
    vdonline
        inner join estac
            on (
                vdo_pdv = est_pdv
                and vdo_unidade = est_unidade
            )
        inner join fin
            on (
                vdo_final=codigo
                and fin_config=est_conf_final
            )
where 
    (
        vdo_data >= CURRENT_DATE 
        and vdo_data < CURRENT_DATE::date + interval '1 day'
    )
    and vdo_unidade = '001'--lpad(cast(numeroLoja as varchar),3,'0')
    and vdo_tipo in('V','v')
    and vdo_final <> ''
group by vdo_final, fin_descricao, fin_config
order by 1;