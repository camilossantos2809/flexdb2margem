-- média de valores por produto
select
    round(avg(vopr_valor-vopr_desconto), 2) as media_itens
from erp.vdonlineprod
where
    vopr_datamvto=CURRENT_DATE
    and vopr_unid_codigo = lpad(cast(1 as varchar),3,'0');