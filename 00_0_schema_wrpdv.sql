-- Comandos a ser executados no database wrpdv

do $body$
declare
    -- Alterar as variáveis abaixo conforme o ambiente do cliente
    erp_ip_servidor varchar := '10.1.12.127';
    erp_porta_servidor varchar := '5432';
    erp_database_name varchar := 'erp_margem';
    senha_usuario_postgres varchar := 'rp1064';

    usuarios text[] := array['postgres', 'rpdv', 'erp', 'gestorrp'];
    usuario text;
    usuarios_map text[];
    foreing_tables text[];
    pg_fdw_name varchar;
    gestorrp_name varchar;
    server_options varchar;
begin

raise notice 'Script iniciado!';
set standard_conforming_strings to on;

-- A extensão postgres_fdw possibilita o uso de tabelas de diferentes databases
-- Na integração ela é utilizada para consultar as tabelas do database erp no database wrpdv

-- Verifica se extensão postgres_fdw está instalada no servidor do banco de dados antes de prosseguir
select name into pg_fdw_name from pg_available_extensions where name ='postgres_fdw';
if not found then
    raise exception 'Extensão postgres_fdw não está disponível. Solicitar instalação do pacote contrib no servidor';
else
    raise notice 'Extensão postgres_fdw disponível no servidor';
    -- Habilita a extensão postgres_fdw no database wrpdv caso ainda não esteja habilitada
    create extension if not exists postgres_fdw;
end if;

-- Cria o usuário que será utilizado pelo MROBOT.exe para conectar no banco de dados
-- Alterar a senha se necessário
-- Esse usuário e senha que devem ser preenchidos no arquivo de configuração
select rolname into gestorrp_name
from pg_roles
where rolname = 'gestorrp';
if not found then
    create user gestorrp with encrypted password 'merc123=';
else
    raise notice 'Usuário gestorrp já está criado no database';
end if;

-- Cria schema para manter os objetos criados para a integração separados dos utilizados no wrpdv
create schema if not exists gestorrp authorization gestorrp;
create schema if not exists erp;

-- Cria "link" com o database erp
-- Em options será necessário alterar o conteúdo para os dados de acesso ao database erp
select srvoptions into server_options
from pg_foreign_server
where srvname='erp';
if not found then
    execute format('CREATE SERVER erp 
        FOREIGN DATA WRAPPER postgres_fdw 
        OPTIONS (host %s,port %s,dbname %s)',
        quote_literal(erp_ip_servidor),
        quote_literal(erp_porta_servidor),
        quote_literal(erp_database_name));
else
    raise notice 'Foreign Server erp já existe no database';
end if;

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
select array_agg(rolname)
into usuarios_map
from pg_user_mapping map
    inner join pg_authid rol on (map.umuser=rol.oid);

foreach usuario in array usuarios
loop
    if usuarios_map @> array[usuario]::text[] then
        raise notice 'Usuário % já mapeado no foreign server erp', usuario;
    else
        if usuario = 'gestorrp' then
            raise notice 'Mapeando usuário gestorrp no foreign server erp';
            create user mapping for gestorrp server erp options(user 'gestorrp', password 'merc123=');
        else
            raise notice 'Mapeando usuário % no foreign server erp', usuario;
            execute format('create user mapping for %I server erp options(user %s, password %s);',
                usuario, quote_literal('postgres'), quote_literal(senha_usuario_postgres));
        end if;
    end if;
end loop;

/*
Se necessário alterar o usuário e/ou senha depois de criado pode ser realizada a alteração conforme o exemplo:

alter user mapping for postgres
    server erp options(set user 'outro_super_user', set password '654321');
*/

-- Cria a tabela vdonlineprod do database erp no database wrpdv através do postgres_fdw
create foreign table if not exists erp.vdonlineprod(
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

-- Cria a tabela produn do database erp no database wrpdv através do postgres_fdw
create foreign table if not exists erp.produn(
    prun_prod_codigo numeric(8,0) NOT NULL,
    prun_unid_codigo character varying(3) NOT NULL,
    prun_alterado character varying(1),
    prun_setor character varying(50),
    prun_setordep character varying(10),
    prun_etq numeric(5,0),
    prun_ctz numeric(5,0),
    prun_tecla character varying(3),
    prun_espaco numeric(5,0),
    prun_pzrepos numeric(5,0),
    prun_pzentrega numeric(5,0),
    prun_diasseg numeric(5,0),
    prun_estmin numeric(15,5),
    prun_estmax numeric(15,5),
    prun_validade numeric(5,0),
    prun_valminima numeric(5,0),
    prun_marcado character varying(1),
    prun_bloqueado character varying(1),
    prun_prvenda numeric(15,5),
    prun_prvendaant numeric(15,5),
    prun_dtprvenda date,
    prun_usualtpr numeric(5,0),
    prun_margem numeric(15,5),
    prun_margemmin numeric(15,5),
    prun_prlista numeric(15,5),
    prun_oferta character varying(1),
    prun_dtoferta date,
    prun_prnormal numeric(15,5),
    prun_estoque1 numeric(15,5),
    prun_estoque2 numeric(15,5),
    prun_estoque3 numeric(15,5),
    prun_estoque4 numeric(15,5),
    prun_estoque5 numeric(15,5),
    prun_dtultcomp date,
    prun_prultcomp numeric(15,5),
    prun_qultcomp numeric(15,5),
    prun_ultsimbcomp character varying(3),
    prun_redbcultcomp numeric(15,5),
    prun_ultforn numeric(8,0),
    prun_ctcompra numeric(15,5),
    prun_ctmedio numeric(15,5),
    prun_ctempresa numeric(15,5),
    prun_ctfiscal numeric(15,5),
    prun_cttransf numeric(15,5),
    prun_dtcustos date,
    prun_comissao numeric(15,5),
    prun_difcusto numeric(15,5),
    prun_difvenda numeric(15,5),
    prun_emb character varying(2),
    prun_qemb numeric(5,0),
    prun_etqmag character varying(1),
    prun_ativo character varying(1),
    prun_prpdv numeric(15,5),
    prun_pretq numeric(15,5),
    prun_prctz numeric(15,5),
    prun_qtdeabloja numeric(10,3),
    prun_dtabloja date,
    prun_dataofant date,
    prun_precoofertaant numeric(15,5),
    prun_preconormalant numeric(15,5),
    prun_tpaltprvenda character varying(1),
    prun_difcusto1 numeric(7,3),
    prun_difcusto2 numeric(7,3),
    prun_difcusto3 numeric(7,3),
    prun_difcusto4 numeric(7,3),
    prun_difcusto5 numeric(7,3),
    prun_difvenda1 numeric(7,3),
    prun_difvenda2 numeric(7,3),
    prun_difvenda3 numeric(7,3),
    prun_difvenda4 numeric(7,3),
    prun_difvenda5 numeric(7,3),
    prun_ctcompraant numeric(15,5),
    prun_ctmedioant numeric(15,5),
    prun_ctfiscalant numeric(15,5),
    prun_ctempresaant numeric(15,5),
    prun_cttransfant numeric(15,5),
    prun_prultcompant numeric(15,5),
    prun_transctmedio character varying(18),
    prun_faquisicao character varying(2),
    prun_extra1 character varying(50),
    prun_extra2 character varying(50),
    prun_extra3 character varying(50),
    prun_extra4 numeric(15,5),
    prun_extra5 numeric(15,5),
    prun_extra6 numeric(15,5),
    prun_extra7 numeric(15,5),
    prun_extra8 numeric(15,5),
    prun_extra9 numeric(15,5),
    prun_codestoque numeric(8,0),
    prun_fatorestoque numeric(15,5),
    prun_dataalt date,
    prun_usualt numeric(5,0),
    prun_frentes numeric(5,0),
    prun_orig_codigo numeric(5,0),
    prun_prtabela numeric(15,5),
    prun_prvenda2 numeric(15,5),
    prun_creditost numeric(15,5),
    prun_vmd numeric(12,3),
    prun_codigosim character varying(20),
    prun_dataofant2 date,
    prun_precoofertaant2 numeric(15,5),
    prun_preconormalant2 numeric(15,5),
    prun_prvenda3 numeric(15,5),
    prun_prvenda4 numeric(15,5),
    prun_prvenda5 numeric(15,5),
    prun_prnormal3 numeric(15,5),
    prun_prnormal4 numeric(15,5),
    prun_prnormal5 numeric(15,5),
    prun_preconormalant3 numeric(15,5),
    prun_preconormalant4 numeric(15,5),
    prun_preconormalant5 numeric(15,5),
    prun_precoofertaant3 numeric(15,5),
    prun_precoofertaant4 numeric(15,5),
    prun_precoofertaant5 numeric(15,5),
    prun_margem3 numeric(15,5),
    prun_margem4 numeric(15,5),
    prun_margem5 numeric(15,5),
    prun_fatorpr3 numeric(5,0),
    prun_fatorpr4 numeric(5,0),
    prun_fatorpr5 numeric(5,0),
    prun_prpdv3 numeric(15,5),
    prun_prpdv4 numeric(15,5),
    prun_prpdv5 numeric(15,5),
    prun_tipoagof character varying(5),
    prun_tipoagofant character varying(5),
    prun_tipoagofant2 character varying(5),
    prun_tptrocas character varying(30),
    prun_prvdapadrao numeric(15,5),
    prun_curvasabc character varying(20),
    prun_qtdeoferta numeric(15,5),
    prun_dtinioferta date,
    prun_percimpostos numeric(15,5),
    prun_prvenda2ant numeric(15,5),
    prun_prvenda2ant2 numeric(15,5),
    prun_percimpostosfed numeric(15,5),
    prun_percimpostosest numeric(15,5),
    prun_percimpostosmun numeric(15,5),
    prun_percimpostoschave character varying(6),
    prun_percsugestao numeric(15,5),
    prun_etiquetas character varying(100),
    prun_ctcompraaltpr numeric(15,5),
    prun_sens_codigo numeric(5,0),
    prun_prnormal2 numeric(15,5),
    prun_dtprvenda2 date,
    prun_dtprvenda3 date,
    prun_dtprvenda4 date,
    prun_dtprvenda5 date,
    prun_qtdemaxcli numeric(8,0),
    prun_ctvenda numeric(15,5)
) server erp options (
    schema_name 'public',
    table_name 'produn'
);

raise notice 'Criando funções no schema gestorrp...';
-- Função necessária para retornar os dados da query 11 conforme layout da integração
create or replace function gestorrp.fn_itens_desconto(
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
create or replace function gestorrp.fn_vendas_vendedor(
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
raise notice 'Funções adicionadas ao schema gestorrp';

-- Atribuição de permissões aos usuários criados no banco de dados.
raise notice 'Atribuindo permissões ao usuário gestorrp';
grant usage on schema erp to gestorrp;
grant select on all tables in schema erp to gestorrp;
grant select on all tables in schema public to gestorrp;
alter default privileges in schema erp grant select on tables to gestorrp;
alter default privileges in schema public grant select on tables to gestorrp;

set standard_conforming_strings to off;
raise notice 'Script concluído!';
end
$body$ language plpgsql;