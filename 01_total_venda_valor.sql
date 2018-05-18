-- Total vendido do dia 
SELECT
    cast(sum(
        case 
            when vdo_norm_canc='N'
            then vdo_valor else vdo_valor * (-1)
        end
    ) as numeric(10,2)) as valor
FROM
    vdonline
where 
    (
        vdo_data >= '2018-05-14'::date 
        and vdo_data < '2018-05-14'::date + interval '1 day'
    )
    and vdo_unidade = '001'--lpad(cast(numeroLoja as varchar),3,'0')
    and vdo_tipo in('V','v');
