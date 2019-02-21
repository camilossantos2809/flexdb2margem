-- top 3000 produtos por valor
with vendas as (
    select
        vopr_prod_codigo,
        sum(coalesce(vopr_qtde,0)) as quantidade,
        sum(coalesce(vopr_valor-vopr_desconto,0)) as valor
    from
        erp.vdonlineprod vd
    where
        vd.vopr_datamvto=CURRENT_DATE
        and vd.vopr_unid_codigo = lpad(cast(numeroLoja as varchar),3,'0')
    group by
        vopr_prod_codigo
    order by
        "valor" desc
    limit 3000
)
select
    ite_codbarra as codigo,
    ite_descricao as descricao,
    tpc_preco as valor_unitario,
    quantidade,
    valor
from
    vendas vd
        left join tabitens
            on (vd.vopr_prod_codigo=cast(ite_cod_interno as numeric))
        left join tabprecos2
            on (
                vd.vopr_prod_codigo=cast(tpc_cod_interno as numeric)
                and ite_cod_interno = tpc_cod_interno
                )
where
    tpc_unidade = lpad(cast(numeroLoja as varchar),3,'0')
order by
    valor desc;