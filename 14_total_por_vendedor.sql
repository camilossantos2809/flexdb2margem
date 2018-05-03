/*
    Vendas por vendedor

    Parâmetros:
        1 - Data de movimento
        2 - Integer correspondente ao código da unidade/loja
    
    Retorna:
        data date,
        vendedor text,
        valor numeric,
        num_cupons integer,
        num_itens integer,
        media_itens numeric,
        media_valor numeric
*/
select * from margem.fn_vendas_vendedor(current_date, 1);