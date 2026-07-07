{{
  config(
    materialized='view',
    schema='staging'
  )
}}

with source as (
    select * from {{ ref('stg_sa0100') }}
),

days as (
    select seq4() + 1 as day_num
    from table(generator(rowcount => 31))
),

unpivoted as (
    select
        s.ten,
        s.boten,
        s.bunten,
        s.ym,
        s.nen_ki,
        s.nendo,
        s.ki,
        s.e1_msd,
        s.e1_med,
        s.r_med,
        d.day_num,
        try_to_date(
            '20' || s.ym || lpad(d.day_num, 2, '0'),
            'YYYYMMDD'
        ) as day_date,
        case d.day_num
            {% for d_num in range(1, 32) %}
            when {{ d_num }} then s.eigyo_1_{{ '%02d' % d_num }}
            {% endfor %}
        end as eigyo_flag,
        case d.day_num
            {% for d_num in range(1, 32) %}
            when {{ d_num }} then s.youbi_{{ '%02d' % d_num }}
            {% endfor %}
        end as youbi_kbn,
        case d.day_num
            {% for d_num in range(1, 32) %}
            when {{ d_num }} then s.shuku_{{ '%02d' % d_num }}
            {% endfor %}
        end as shuku_kbn,
        case d.day_num
            {% for d_num in range(1, 32) %}
            when {{ d_num }} then s.fs_1_{{ '%02d' % d_num }}
            {% endfor %}
        end as fs_1,
        case d.day_num
            {% for d_num in range(1, 32) %}
            when {{ d_num }} then s.fe_1_{{ '%02d' % d_num }}
            {% endfor %}
        end as fe_1
    from source s
    cross join days d
    where d.day_num <= s.r_med
)

select * from unpivoted
where day_date is not null
