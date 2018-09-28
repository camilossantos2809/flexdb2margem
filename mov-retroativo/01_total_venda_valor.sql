/*
    Retorna o total vendido na data enviada na consulta

    Comando a ser executado no database erp
*/

select 
    sum(mprc_totaldcto) as valor,
    sum(mprc_ctmedio) + sum(mprc_ctvenda) as cmv,
    sum(mprc_totaldcto) - (sum(mprc_ctmedio) + sum(mprc_ctvenda)) as lucro
from movprodc
where mprc_datamvto = '2018-09-27'
    and mprc_dcto_tipo = 'EVP'
    and mprc_unid_codigo = '001' --lpad(cast(numeroLoja as varchar),3,'0') 
    and mprc_status = 'N';
