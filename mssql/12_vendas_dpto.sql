-- vendas por departamento/seção
select
    dpt_codigo as codigo,
    dpt_nome as descricao,
    sum(coalesce(vopr_qtde,0)) as quantidade,
    sum(coalesce(vopr_valor-vopr_desconto,0)) as valor
from
    erp.dbo.vdonlineprod vd
        left join tabitens
            on (vd.vopr_prod_codigo=cast(ite_cod_interno as numeric))
        left join departamentos
            on (ite_cod_dpto=dpt_codigo)
where
    vopr_datamvto = cast(CURRENT_TIMESTAMP as date)
    and vopr_unid_codigo = '001' --right('000'+cast(numeroLoja as varchar(3)), 3)
group by
    dpt_codigo,
    dpt_nome
order by
    "valor" desc
GO