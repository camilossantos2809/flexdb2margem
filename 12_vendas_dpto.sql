-- vendas por departamento/seção

with prod_dptos as (
    select 
        cast(ite_cod_interno as numeric) as prod_codigo,
        dpt_codigo,
        dpt_nome
    from tabitens
        inner join departamentos
            on (ite_cod_dpto=dpt_codigo)
)
select
    dpt_codigo as codigo,
    dpt_nome as descricao,
    sum(coalesce(vopr_qtde,0)) as quantidade,
    sum(coalesce(vopr_valor-vopr_desconto,0)) as valor
from
    erp.vdonlineprod vd
        left join prod_dptos
            on (vd.vopr_prod_codigo=prod_codigo)
where
    vd.vopr_datamvto = CURRENT_DATE
    and vd.vopr_unid_codigo = lpad(cast(numeroLoja as varchar),3,'0')
group by
    dpt_codigo,
    dpt_nome
order by
    "valor" desc;
