/*
    Quantidade cupons válidos

    Comando a ser executado no database erp
*/

select
    sum(mfpd_ncl) as qtd_cupons
from
    movfechpdv
where
    mfpd_data = cast('2018-11-19' as date)
    and mfpd_unid_codigo = '001' --lpad(cast(1 as varchar),3,'0')
    and mfpd_status = 'N';
