-- Quantidade cupons válidos
SELECT
    count(*) as qtd_cupons
from vdonlineprod
where
    vopr_datamvto='2018-09-27'
    and vopr_unid_codigo = '001' --lpad(cast(1 as varchar),3,'0')
    and vopr_valor > 0;
