-- Função necessária para retornar os dados da query 11 conforme layout da integração

create or replace function margem.fn_itens_desconto (
    data_mvto date,
    unidade integer
)
returns table (
    dataproc date,
    hora time,
    operador text,
    supervisor text,
    valor numeric(15,3),
    nro_cupom varchar(6),
    item integer,
    codigo_ean varchar(13),
    desc_item text
)
language plpgsql strict as $$
    declare
        v_tabela text;
        v_unidade text;
        v_query text;
    begin
        v_tabela := format('tab_venda_%s', to_char(data_mvto, 'MMyy'));
        v_unidade := quote_literal(lpad(unidade::text, 3, '0'));
        v_query := format($sql$
            with vendas as (
                select
                    tvd_unidade,
                    tvd_data_hora,
                    tvd_pdv,
                    tvd_cupom,
                    tvd_operador,
                    tvd_cpseq,
                    string_to_array(tvd_registro, '|') as tvd_registro
                from %s
                where
                    (
                        tvd_data_hora >= $1 
                        and tvd_data_hora < $1 + interval '1 day'
                    )
                    and tvd_tipo_reg = 'VITN'
                    and tvd_unidade = %s
            )
            select
                cast(tvd_data_hora as date) as dataproc,
                cast(tvd_data_hora as time) as hora,
                op.usu_nome::text as operador,
                sup.usu_nome::text as supervisor,
                round(cast(tvd_registro[12] as numeric)/100,2) as valor,
                tvd_cupom as nro_cupom,
                cast(tvd_cpseq as integer)-1 as item,
                tvd_registro[1]::varchar(13) as codigo_ean,
                tvd_registro[2]::text as desc_item
            from vendas
                left join usuario op
                    on (tvd_operador=op.usu_codigo)
                left join usuario sup
                    on (tvd_registro[22]=sup.usu_codigo)
            where tvd_registro[12] <> '' -- valor desconto gerencial
            and tvd_registro[12]::numeric > 0
                and tvd_registro[25] = '' -- identificador do desconto aplicado automaticamente
        $sql$, v_tabela, v_unidade);

        return query execute v_query using(data_mvto);
        return;
    end
$$;
