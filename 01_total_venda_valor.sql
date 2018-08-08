/*
    Retorna o total vendido do dia
*/

with prun as (
    select prun_prod_codigo, prun_ctmedio, prun_ctvenda
    from erp.produn
    where prun_unid_codigo='001' --lpad(cast(numeroLoja as varchar),3,'0')
        and prun_ativo = 'S'
        and (
            prun_ctmedio > 0
            or prun_ctvenda > 0
        )
), total_venda as (
    SELECT
        cast(sum(coalesce(vopr_valor - vopr_desconto, 0)) as numeric(10,2)) as valor,
        cast(sum(coalesce(prun_ctmedio,0) + coalesce(prun_ctvenda,0)) as numeric(10,2)) as custo
    FROM
        erp.vdonlineprod
            left join prun
                on (
                    vopr_prod_codigo=prun_prod_codigo
                )
    where 
        vopr_datamvto=CURRENT_DATE
        and vopr_unid_codigo = '001'--lpad(cast(numeroLoja as varchar),3,'0')
)
select
    valor,
    custo,
    cast(valor - custo as numeric(10,2)) as lucro
from total_venda;