-- Venda por faixa de hora
select
    *,
    round(num_itens/num_cupons, 2) as media_itens,
    round(valor/num_cupons, 2) as media_valor
from (
    select
        left(vopr_hora,2) as hora,
        sum(coalesce(vopr_valor-vopr_desconto,0)) as valor,
        count(distinct vopr_cupom) as num_cupons,
        count(distinct vopr_prod_codigo) as num_itens
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