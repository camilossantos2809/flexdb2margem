-- Venda por operador
SELECT
    concat(vdo_operador,' - ', usu_nome) as operador,
    cast(sum(
        case 
            when vdo_norm_canc='N'
            then vdo_valor else vdo_valor * (-1)
        end
    ) as numeric(10,2)) as valor,
    count(distinct 
        case
            when vdo_tipo = 'V' --CORRIGIR: mssql obriga que o campo esteja listado em group by
            then vdo_cupom
        end
    ) as qtd_cupom
FROM
    vdonline
        left join usuario
            on (vdo_operador=usu_codigo)
where 
    cast(vdo_data as date) = cast(CURRENT_TIMESTAMP as date)
    and vdo_unidade = '001' --right('000'+cast(numeroLoja as varchar(3)), 3)
    and vdo_norm_canc='N'
group by 
    concat(vdo_operador,' - ', usu_nome)
order by 1
GO
