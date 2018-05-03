-- Ticket médio
SELECT
    cast(avg(
        case 
            when vdo_norm_canc='N'
            then vdo_valor else vdo_valor * (-1)
        end
    ) as numeric(10,2)) as valor
FROM
    vdonline
where 
    (
        vdo_data >= CURRENT_DATE 
        and vdo_data < CURRENT_DATE + interval '1 day'
    )
    and vdo_unidade = lpad(cast(numeroLoja as varchar),3,'0')
    and vdo_tipo in('V','v');