{{
  config(
    materialized='view',
    schema='staging'
  )
}}

with source as (
    select * from {{ source('calendar_source', 'raw_sa0100_csv') }}
),

typed as (
    select
        lpad(cast(boten as varchar),2,'0')
          || lpad(cast(bunten as varchar),2,'0') as ten,
        lpad(cast(nendo as varchar),2,'0')
          || cast(ki as varchar) as nen_ki,
        lpad(cast(yy as varchar),2,'0')
          || lpad(cast(mm as varchar),2,'0') as ym,
        cast(boten as number(2,0)) as boten,
        cast(bunten as number(2,0)) as bunten,
        cast(nendo as number(2,0)) as nendo,
        cast(ki as number(1,0)) as ki,
        cast(yy as number(2,0)) as yy,
        cast(mm as number(2,0)) as mm,
        cast(r_msd as number(2,0)) as r_msd,
        cast(r_med as number(2,0)) as r_med,
        cast(e1_msd as number(2,0)) as e1_msd,
        cast(e1_med as number(2,0)) as e1_med,
        cast(e2_msd as number(2,0)) as e2_msd,
        cast(e2_med as number(2,0)) as e2_med,
        cast(e3_msd as number(2,0)) as e3_msd,
        cast(e3_med as number(2,0)) as e3_med,
        cast(henko_kbn as number(1,0)) as henko_kbn,
        {% for d in range(1, 32) %}
        {% set dd = '%02d' % d %}
        cast(eigyo_1_{{ dd }} as number(1,0)) as eigyo_1_{{ dd }},
        cast(youbi_{{ dd }} as number(1,0)) as youbi_{{ dd }},
        cast(shuku_{{ dd }} as number(1,0)) as shuku_{{ dd }},
        cast(fs_1_{{ dd }} as number(2,0)) as fs_1_{{ dd }},
        cast(fe_1_{{ dd }} as number(2,0)) as fe_1_{{ dd }}
        {% if not loop.last %},{% endif %}
        {% endfor %}
    from source
)

select * from typed
