-- 5000 produtos mais vendidos, por valor
with prun as (
    select
        prun_prod_codigo, 
        prun_ctmedio,
        prun_ctvenda
    from erp.dbo.produn
    where prun_unid_codigo='001' --right('000'+cast(numeroLoja as varchar(3)), 3)
        and prun_ativo = 'S'
        and (
            prun_ctmedio > 0
            or prun_ctvenda > 0
        )
), top5000 as(
    select top 5000
        ite_codbarra as codigo,
        ite_descricao as descricao,
        max(coalesce(tpc_preco,0)) as valor_unitario,
        sum(coalesce(vopr_qtde,0)) as quantidade,
        sum(coalesce(vopr_valor-vopr_desconto,0)) as valor,
        cast(coalesce(prun_ctmedio,0) + coalesce(prun_ctvenda,0) as numeric(10,2)) as custo
    from
        erp.dbo.vdonlineprod vd
            left join tabitens
                on (vd.vopr_prod_codigo=cast(ite_cod_interno as numeric))
            left join tabprecos2
                on (vd.vopr_prod_codigo=cast(tpc_cod_interno as numeric))
            left join prun
                on (vopr_prod_codigo=prun_prod_codigo)
    where
        vd.vopr_datamvto = cast(CURRENT_TIMESTAMP as date)
        and vd.vopr_unid_codigo = '001'--right('000'+cast(numeroLoja as varchar(3)), 3)
        and tpc_unidade = '001'--right('000'+cast(numeroLoja as varchar(3)), 3)
    group by
        ite_codbarra,
        ite_descricao,
        prun_ctmedio,
        prun_ctvenda
    order by
        "valor" desc
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
    top5000
GO