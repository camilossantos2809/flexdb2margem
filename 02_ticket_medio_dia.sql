-- Ticket médio (Total vendido / Quantidade de cupons)

with valor_dia as (
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
            vdo_data >= current_date --'2018-05-14'::date 
            and vdo_data < current_date + interval '1 day' --'2018-05-14'::date 
        )
        and vdo_unidade = '001'--lpad(cast(numeroLoja as varchar),3,'0')
        and vdo_tipo in('V','v')
),
qtde_dia as (
    SELECT
        cast(count(distinct (vdo_cupom,vdo_pdv)) filter (where vdo_norm_canc='N') as integer) 
        - cast(count(distinct (vdo_cupom,vdo_pdv)) filter (where vdo_norm_canc='C') as integer) 
        as qtd_cupons
    FROM
        vdonline
    where 
        (
            vdo_data >= CURRENT_DATE 
            and vdo_data < CURRENT_DATE::date + interval '1 day'
        )
        and vdo_unidade = '001'--lpad(cast(numeroLoja as varchar),3,'0')
        and vdo_tipo in('V','v','O','o')
        and vdo_final<>''
)
SELECT
    valor/qtde_dia as valor
FROM
    valor_dia,qtde_dia;