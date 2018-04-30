-- Executar comandos no database wrpdv

create extension if not exists postgres_fdw;

create schema if not exists erp;

CREATE SERVER erp 
    FOREIGN DATA WRAPPER postgres_fdw 
        OPTIONS (
            host 'localhost',
            port '5432',
            dbname 'erp_testes'
        );

create user mapping for postgres 
    server erp options(user 'postgres', password 'rp1064');

import foreign schema public limit to(
    departamentos,
    vdonlineprod
)
from server erp
into erp;
