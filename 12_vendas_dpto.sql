-- vendas por departamento/seção
with prun as (
    select
        prun_prod_codigo,
        prun_ctmedio,
        prun_ctvenda
    from erp.produn
    where prun_unid_codigo='001' --lpad(cast(numeroLoja as varchar),3,'0')
        and (
            prun_ctmedio > 0
            or prun_ctvenda > 0
        )
), total_venda as (
    SELECT
        vopr_prod_codigo,
        cast(sum(coalesce(vopr_valor - vopr_desconto, 0)) as numeric(10,2)) as valor,
        sum(coalesce(vopr_qtde,0)) as quantidade,
        cast((max(coalesce(prun_ctmedio,0)) + max(coalesce(prun_ctvenda,0)))*sum(vopr_qtde) as numeric(10,2)) as custo
    FROM
        erp.vdonlineprod
            left join prun
                on (vopr_prod_codigo=prun_prod_codigo)
    where 
        vopr_datamvto=CURRENT_DATE
        and vopr_unid_codigo = '001'--lpad(cast(numeroLoja as varchar),3,'0')
    group by
        vopr_prod_codigo
)
select
    dpt_codigo as codigo,
    dpt_nome as descricao,
    sum(quantidade) as quantidade,
    sum(valor) as valor,
    cast(sum(custo) as numeric(10,2)) as custo,
    cast(sum(valor)-sum(custo) as numeric(10,2)) as lucro
from
    total_venda
        left join tabitens
            on (vopr_prod_codigo=cast(ite_cod_interno as numeric))
        left join departamentos
            on (ite_cod_dpto=dpt_codigo)
group by
    dpt_codigo,
    dpt_nome
order by
    "valor" desc;