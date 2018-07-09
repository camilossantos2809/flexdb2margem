-- Comandos a ser executados no database wrpdv

-- Habilita a extensão postgres_fdw no database wrpdv
-- Essa extensão possibilita o uso de tabelas de diferentes databases
create extension if not exists postgres_fdw;

-- Cria o usuário que será utilizado pelo MROBOT.exe para conectar no banco de dados
-- Alterar a senha se necessário
-- Esse usuário e senha que devem ser preenchidos no arquivo de configuração
create user gestorrp with encrypted password 'merc123=';

-- Cria schema para manter os objetos criados para a integração separados dos utilizados no wrpdv
create schema if not exists margem authorization gestorrp;
create schema if not exists erp;

-- Cria "link" com o database erp
-- Em options será necessário alterar o conteúdo para os dados de acesso ao database erp
CREATE SERVER erp 
    FOREIGN DATA WRAPPER postgres_fdw 
        OPTIONS (
            host '10.1.12.127',
            port '5432',
            dbname 'erp'
        );

/*
Se for necessário alterar os dados de conexão do database erp utilizar o exemplo abaixo

ALTER SERVER erp OPTIONS (
    set host '10.1.12.123',
    set port '5433',
    set dbname 'erp_testes'
)
*/

-- Informar em user e password os dados de um superuser
-- Se database erp e wrpdv estiverem no mesmo servidor pode ser utilizado o mesmo usuário e senha correspondente
create user mapping for postgres 
    server erp options(user 'postgres', password '123456');
create user mapping for rpdv
    server erp options(user 'postgres', password '123456');
create user mapping for erp
    server erp options(user 'postgres', password '123456');

-- Utilizar mesma senha definida na criação do usuário margem
create user mapping for gestorrp
    server erp options(user 'gestorrp', password 'merc123=');

/*
Se necessário alterar o usuário e/ou senha depois de criado pode ser realizada a alteração conforme o exemplo:

alter user mapping for postgres
    server erp options(set user 'outro_super_user', set password '654321');
*/

-- Cria a tabela vdonlineprod do database erp no database wrpdv através do postgres_fdw
create foreign table erp.vdonlineprod(
    vopr_datamvto date,
    vopr_hora varchar(6),
    vopr_status varchar(1),
    vopr_unid_codigo varchar(3),
    vopr_pdvs_codigo varchar (3),
    vopr_cupom varchar(6),
    vopr_codbarras varchar(14),
    vopr_prod_codigo numeric(8,0),
    vopr_qtde numeric(10,3),
    vopr_valor numeric(12,2),
    vopr_desconto numeric(12,2),
    vopr_tiporeg varchar(2)
)
server erp
options (
    schema_name 'public',
    table_name 'vdonlineprod'
);

-- Função necessária para retornar os dados da query 11 conforme layout da integração
create or replace function margem.fn_itens_desconto(
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
                round(cast(tvd_registro[29] as numeric)/100,2) as valor,
                tvd_cupom as nro_cupom,
                cast(tvd_cpseq as integer)-1 as item,
                tvd_registro[1]::varchar(13) as codigo_ean,
                tvd_registro[2]::text as desc_item
            from vendas
                left join usuario op
                    on (tvd_operador=op.usu_codigo)
                left join usuario sup
                    on (tvd_registro[22]=sup.usu_codigo)
            where tvd_registro[29]<>''
        $sql$, v_tabela, v_unidade);

        return query execute v_query using(data_mvto);
        return;
    end
$$;

-- Função necessária para retornar os dados da query 14 conforme layout da integração
create or replace function margem.fn_vendas_vendedor(
    data_mvto date,
    unidade integer
)
returns table (
    data date,
    vendedor text,
    valor numeric,
    num_cupons integer,
    num_itens integer,
    media_itens numeric,
    media_valor numeric
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
                    tvd_data_hora,
                    tvd_cupom,
                    string_to_array(tvd_registro, '|') as tvd_registro
                from %s
                where
                    (
                        tvd_data_hora >= $1 
                        and tvd_data_hora < $1 + interval '1 day'
                    )
                    and tvd_tipo_reg = 'VITN'
                    and tvd_unidade = %s
            ),
            vendas_vendedor as (
                select
                    cast(tvd_data_hora as date) as data,
                    coalesce(vdr_nome::text,'NULL') as vendedor,
                    sum(
                        round(cast(nullif(tvd_registro[5],'') as numeric)/100,2) -
                        coalesce(round(cast(nullif(tvd_registro[29],'') as numeric)/100,2),0)
                    ) as valor,
                    count(distinct tvd_cupom)::integer as num_cupons,
                    count(distinct tvd_registro[1])::integer as num_itens
                from vendas
                    left join vendedores
                        on (tvd_registro[16]=vdr_codigo::text)
                group by
                    cast(tvd_data_hora as date),
                    vdr_nome
            )
            select
                *,
                round(num_itens::numeric / num_cupons::numeric,2) as media_itens,
                round((valor / num_cupons)::numeric,2) as media_valor
            from vendas_vendedor
        $sql$, v_tabela, v_unidade);

        return query execute v_query using(data_mvto);
        return;
    end
$$;

-- Atribuição de permissões aos usuários criados no banco de dados.
grant usage on schema erp to gestorrp;
grant select on all tables in schema erp to gestorrp;
grant select on all tables in schema public to gestorrp;
alter default privileges in schema erp grant select on tables to gestorrp;
alter default privileges in schema public grant select on tables to gestorrp;
