-- média de valores por produto
select
    round(avg(vopr_valor-vopr_desconto),2) as media_itens
from erp.vdonlineprod
where vopr_unid_codigo='001';