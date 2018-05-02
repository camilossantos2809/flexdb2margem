-- top 100 produtos por valor
select
    ite_codbarra as codigo,
    ite_descricao as descricao,
    max(coalesce(tpc_preco,0)) as valor_unitario,
    sum(coalesce(vopr_qtde,0)) as quantidade,
    sum(coalesce(vopr_valor,0)) as valor
from
    erp.vdonlineprod vd
        left join tabitens
            on (vd.vopr_prod_codigo=cast(ite_cod_interno as numeric))
        left join tabprecos2
            on (vd.vopr_prod_codigo=cast(tpc_cod_interno as numeric))
where vd.vopr_datamvto=CURRENT_DATE
    and vd.vopr_unid_codigo='001'
    and tpc_unidade='001'
group by
    ite_codbarra,
    ite_descricao
order by
    "valor" desc
limit 100;