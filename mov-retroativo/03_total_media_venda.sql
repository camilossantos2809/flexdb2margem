-- média de valores por produto
select
    round(avg(vopr_valor-vopr_desconto), 2) as media_itens
from vdonlineprod
where
    vopr_datamvto='2018-09-27'
    and vopr_unid_codigo = '001' --lpad(cast(1 as varchar),3,'0');
