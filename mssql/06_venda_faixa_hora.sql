-- Venda por faixa de hora
select
    *,
    cast(round(num_itens/num_cupons, 2) as numeric(10,2)) as media_itens,
    cast(round(valor/num_cupons, 2) as numeric(10,2)) as media_valor
from (
    select
        cast(left(vopr_hora,2) as varchar(2)) as hora,
        cast(sum(coalesce(vopr_valor-vopr_desconto,0)) as numeric(10,2)) as valor,
        cast(count(distinct vopr_cupom) as integer) as num_cupons,
        cast(count(distinct vopr_prod_codigo) as integer) as num_itens
    from
        erp.dbo.vdonlineprod vd
            left join tabitens
                on (vd.vopr_prod_codigo=cast(ite_cod_interno as numeric))
    where
        vopr_datamvto = cast(CURRENT_TIMESTAMP as date)
        and vopr_unid_codigo = '001' --right('000'+cast(numeroLoja as varchar(3)), 3)
    group by
        left(vopr_hora,2)
) as x
order by
    hora
GO