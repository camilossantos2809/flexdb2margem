-- Venda por operador
SELECT
    vdo_operador || usu_nome as operador,
    cast(sum(
        case 
            when vdo_norm_canc='N'
            then vdo_valor else vdo_valor * (-1)
        end
    ) as numeric(10,2)) as valor,
    count(distinct vdo_cupom) filter (where vdo_tipo='V') as qtd_cupom
FROM
    vdonline
        inner join usuario
            on (vdo_operador=usu_codigo)
where 
    (
        vdo_data >= CURRENT_DATE 
        and vdo_data < CURRENT_DATE + interval '1 day'
    )
    and vdo_unidade = '001'
    and vdo_tipo in('V','v')
group by vdo_operador || usu_nome
order by 1;
