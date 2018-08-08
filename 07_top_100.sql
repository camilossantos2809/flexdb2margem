-- top 100 produtos por valor
with prun as (
    select
        prun_prod_codigo, 
        prun_ctmedio,
        prun_ctvenda
    from erp.produn
    where prun_unid_codigo='001' --lpad(cast(numeroLoja as varchar),3,'0')
        and prun_ativo = 'S'
        and (
            prun_ctmedio > 0
            or prun_ctvenda > 0
        )
), top100 as(
    select
        ite_codbarra as codigo,
        ite_descricao as descricao,
        max(coalesce(tpc_preco,0)) as valor_unitario,
        sum(coalesce(vopr_qtde,0)) as quantidade,
        sum(coalesce(vopr_valor-vopr_desconto,0)) as valor,
        cast(coalesce(prun_ctmedio,0) + coalesce(prun_ctvenda,0) as numeric(10,2)) as custo
    from
        erp.vdonlineprod vd
            left join tabitens
                on (vd.vopr_prod_codigo=cast(ite_cod_interno as numeric))
            left join tabprecos2
                on (vd.vopr_prod_codigo=cast(tpc_cod_interno as numeric))
            left join prun
                on (vopr_prod_codigo=prun_prod_codigo)
    where
        vd.vopr_datamvto=CURRENT_DATE
        and vd.vopr_unid_codigo = '001'--lpad(cast(numeroLoja as varchar),3,'0')
        and tpc_unidade = '001'--lpad(cast(numeroLoja as varchar),3,'0')
    group by
        ite_codbarra,
        ite_descricao,
        prun_ctmedio,
        prun_ctvenda
    order by
        "valor" desc
    limit 100
)
select
    codigo,
    descricao,
    valor_unitario,
    quantidade,
    valor,
    cast(custo*quantidade as numeric(10,2)) as custo,
    cast(valor-(custo*quantidade) as numeric (10,2)) as lucro
from
    top100;
