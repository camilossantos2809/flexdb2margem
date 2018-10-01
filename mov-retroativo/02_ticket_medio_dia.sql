/*
    Ticket médio

    Comando a ser executado no database erp
*/

with cupons as (
    SELECT
        cast(sum(coalesce(vopr_valor-vopr_desconto,0)) as numeric(10,2)) as valor
    FROM
        vdonlineprod
    where 
        vopr_datamvto = '2018-09-27'
        and vopr_unid_codigo = '001'--lpad(cast(numeroLoja as varchar),3,'0')
    group by vopr_cupom, vopr_pdvs_codigo
)
select round(avg(valor),2)
from cupons;
