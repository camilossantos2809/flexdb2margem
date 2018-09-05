/*
    Retorna o total vendido do dia
*/

with prun as (
    select
        prun_prod_codigo,
        prun_ctmedio,
        prun_ctvenda
    from erp.dbo.produn
    where prun_unid_codigo='001' --right('000'+cast(numeroLoja as varchar(3)), 3)
        and (
            prun_ctmedio > 0
            or prun_ctvenda > 0
        )
), total_venda as (
    SELECT
        cast(sum(coalesce(vopr_valor - vopr_desconto, 0)) as numeric(10,2)) as valor,
        cast((max(coalesce(prun_ctmedio,0)) + max(coalesce(prun_ctvenda,0)))*sum(vopr_qtde) as numeric(10,2)) as custo
    FROM
        erp.dbo.vdonlineprod
            left join prun
                on (vopr_prod_codigo=prun_prod_codigo)
    where 
        vopr_datamvto=cast(CURRENT_TIMESTAMP as date)
        and vopr_unid_codigo = '001'--right('000'+cast(numeroLoja as varchar(3)), 3)
    group by
        vopr_prod_codigo
)
select
    cast(sum(valor) as numeric(10,2)) as valor,
    cast(sum(custo) as numeric(10,2)) as custo,
    cast(sum(valor) - sum(custo) as numeric(10,2)) as lucro
from total_venda;