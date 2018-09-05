-- média de valores por produto
select
    cast(round(avg(vopr_valor-vopr_desconto), 2) as numeric(10,2)) as media_itens
from erp.dbo.vdonlineprod
where
    vopr_datamvto = cast(CURRENT_TIMESTAMP as date)
    and vopr_unid_codigo = '001' --right('000'+cast(numeroLoja as varchar(3)), 3)
GO
