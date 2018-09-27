-- Quantidade cupons válidos

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
    and vdo_final<>'';
