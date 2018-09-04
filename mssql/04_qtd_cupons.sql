-- Quantidade cupons válidos
SELECT
    cast(count(distinct vdo_cupom) as integer) as qtd_cupons
FROM
    vdonline
where 
    cast(vdo_data as date) = cast(CURRENT_TIMESTAMP as date)
    and vdo_unidade = '001' --right('000'+cast(numeroLoja as varchar(3)), 3)
    and vdo_norm_canc = 'N'
GO
