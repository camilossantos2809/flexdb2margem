SELECT
    sum(vdo_valor)
FROM
    vdonline
where 
    vdo_data >= CURRENT_DATE and vdo_data < CURRENT_DATE + interval '1 day'
    and vdo_unidade = '001'
    and vdo_norm_canc = 'N';