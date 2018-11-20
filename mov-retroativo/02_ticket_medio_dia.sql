/*
    Ticket médio

    Comando a ser executado no database erp
*/

with valor_dia as (
    select 
        sum(mprc_totaldcto) as valor
    from movprodc
    where mprc_datamvto = '2018-11-19'
        and mprc_dcto_tipo = 'EVP'
        and mprc_unid_codigo = '001' --lpad(cast(numeroLoja as varchar),3,'0') 
        and mprc_status = 'N'
),
qtde_dia as (
    select
        sum(mfpd_ncl) as qtd_cupons
    from
        movfechpdv
    where
        mfpd_data = '2018-11-19'
        and mfpd_unid_codigo = '001' --lpad(cast(1 as varchar),3,'0')
        and mfpd_status = 'N'
)
select round(valor/qtd_cupons,2)
from valor_dia, qtde_dia;
