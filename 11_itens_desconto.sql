/*
    Relação de produtos que receberam desconto

    Parâmetros:
        1 - Data de movimento
        2 - Integer correspondente ao código da unidade/loja
        
    Retorna:
        dataproc date,
        hora time,
        operador text,
        supervisor text,
        valor numeric(15,3),
        nro_cupom varchar(6),
        item integer,
        codigo_ean varchar(13),
        desc_item text
*/
select * from margem.fn_itens_desconto(current_date, 1);