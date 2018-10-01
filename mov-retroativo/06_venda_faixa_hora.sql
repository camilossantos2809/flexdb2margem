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
        vdonlineprod
    where
        vopr_datamvto='2018-09-27'
        and vopr_unid_codigo = '001'--lpad(cast(numeroLoja as varchar),3,'0')
    group by
        left(vopr_hora,2)
) as x
order by
    hora;
