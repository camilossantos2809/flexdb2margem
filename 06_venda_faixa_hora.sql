-- Venda por faixa de hora
SELECT
    to_char(vdo_data, 'HH24') as hora,
    cast(sum(
        case 
            when vdo_norm_canc='N'
            then vdo_valor else vdo_valor * (-1)
        end
    ) as numeric(10,2)) as valor,
    count(distinct vdo_cupom) filter (where vdo_tipo='V') as num_cupons,
    "valor"/"num_cupons"
FROM
    vdonline
where 
    (
        vdo_data >= CURRENT_DATE 
        and vdo_data < CURRENT_DATE + interval '1 day'
    )
    and vdo_unidade = '001'
    and vdo_tipo in('V','v')
group by to_char(vdo_data, 'HH24')
order by 1;
