-- Venda por operador
SELECT
    concat(vdo_operador,' - ', usu_nome) as operador,
    cast(sum(
        case 
            when vdo_norm_canc='N'
            then vdo_valor else vdo_valor * (-1)
        end
    ) as numeric(10,2)) as valor,
    count(distinct vdo_cupom) filter (where vdo_tipo='V') as qtd_cupom
FROM
    vdonline
        left join usuario
            on (vdo_operador=usu_codigo)
where 
    (
        vdo_data >= CURRENT_DATE 
        and vdo_data < CURRENT_DATE + interval '1 day'
    )
    and vdo_unidade = '001'--lpad(cast(numeroLoja as varchar),3,'0')
    and vdo_tipo in('V','v')
group by 
    concat(vdo_operador,' - ', usu_nome)
order by 1;
