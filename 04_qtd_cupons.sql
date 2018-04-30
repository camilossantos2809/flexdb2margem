-- Quantidade cupons válidos
SELECT
    cast(count(distinct vdo_cupom) as integer) as qtd_cupons
FROM
    vdonline
where 
    (
        vdo_data >= CURRENT_DATE 
        and vdo_data < CURRENT_DATE + interval '1 day'
    )
    and vdo_unidade = '001'
    and vdo_tipo in('V');
