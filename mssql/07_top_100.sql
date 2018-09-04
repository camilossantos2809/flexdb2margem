-- top 100 produtos por valor
select top 100
    ite_codbarra as codigo,
    ite_descricao as descricao,
    max(coalesce(tpc_preco,0)) as valor_unitario,
    sum(coalesce(vopr_qtde,0)) as quantidade,
    sum(coalesce(vopr_valor-vopr_desconto,0)) as valor
from
    erp.dbo.vdonlineprod vd
        left join tabitens
            on (vd.vopr_prod_codigo=cast(ite_cod_interno as numeric))
        left join tabprecos2
            on (vd.vopr_prod_codigo=cast(tpc_cod_interno as numeric))
where
    vopr_datamvto = cast(CURRENT_TIMESTAMP as date)
    and vopr_unid_codigo = '001' --right('000'+cast(numeroLoja as varchar(3)), 3)
    and tpc_unidade = '001' --right('000'+cast(numeroLoja as varchar(3)), 3)
group by
    ite_codbarra,
    ite_descricao
order by
    "valor" desc
GO