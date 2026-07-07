{{
  config(
    materialized='table',
    schema='mart'
  )
}}

{% set processing_date = var('processing_date') %}

with sa0100_days as (
    select * from {{ ref('stg_sa0100_unpivot') }}
),

honten_today as (
    select *
    from sa0100_days
    where ten = '0100'
      and day_date = '{{ processing_date }}'::date
      and eigyo_flag = 1
),

ki_info as (
    select
        nen_ki,
        min(case when cast(right(ym,2) as int) in (3,9)
            then try_to_date('20' || ym || lpad(e1_msd,2,'0'), 'YYYYMMDD')
        end) as ki_symd,
        max(case when cast(right(ym,2) as int) in (2,8)
            then try_to_date('20' || ym || lpad(e1_med,2,'0'), 'YYYYMMDD')
        end) as ki_eymd
    from (select distinct nen_ki, ym, e1_msd, e1_med
          from sa0100_days where ten = '0100')
    group by nen_ki
),

next_eigyo_batch as (
    select min(day_date) as yoku_ymd_batch
    from sa0100_days
    where day_date > '{{ processing_date }}'::date
      and eigyo_flag = 1
      and boten in (1,2,3,4,5,6,15,50)
),

next_eigyo_online as (
    select min(day_date) as yoku_ymd_online
    from sa0100_days
    where day_date > '{{ processing_date }}'::date
      and eigyo_flag = 1
      and boten in (1,2,3,4,5,6,50)
),

ten_eigyo as (
    select
        max(case when boten=1 then eigyo_flag end) as osaka,
        max(case when boten=2 then eigyo_flag end) as tokyo,
        max(case when boten=3 then eigyo_flag end) as kyoto,
        max(case when boten=4 then eigyo_flag end) as kobe,
        max(case when boten=5 then eigyo_flag end) as machida
    from sa0100_days
    where day_date = '{{ processing_date }}'::date
),

final as (
    select
        'BATCH' as record_type,
        to_char('{{ processing_date }}'::date, 'YYMMDD') as kicho_ymd,
        h.youbi_kbn as youbi,
        h.shuku_kbn as shuku_dd,
        h.eigyo_flag as eigyo,
        te.osaka, te.tokyo, te.kyoto, te.kobe, te.machida,
        coalesce(h.fs_1, 0) as f_s,
        coalesce(h.fe_1, 0) as f_e,
        '20' || h.ym || lpad(h.e1_msd, 2, '0') as m_symd,
        '20' || h.ym || lpad(h.e1_med, 2, '0') as m_eymd,
        h.nendo,
        h.ki,
        to_char(ki.ki_symd, 'YYMMDD') as ki_symd,
        to_char(ki.ki_eymd, 'YYMMDD') as ki_eymd,
        to_char(nb.yoku_ymd_batch, 'YYMMDD') as yoku_ymd
    from honten_today h
    cross join ten_eigyo te
    cross join next_eigyo_batch nb
    left join ki_info ki on h.nen_ki = ki.nen_ki

    union all

    select
        'ONLINE' as record_type,
        to_char('{{ processing_date }}'::date, 'YYMMDD') as kicho_ymd,
        h.youbi_kbn as youbi,
        h.shuku_kbn as shuku_dd,
        h.eigyo_flag as eigyo,
        te.osaka, te.tokyo, te.kyoto, te.kobe, te.machida,
        coalesce(h.fs_1, 0) as f_s,
        coalesce(h.fe_1, 0) as f_e,
        '20' || h.ym || lpad(h.e1_msd, 2, '0') as m_symd,
        '20' || h.ym || lpad(h.e1_med, 2, '0') as m_eymd,
        h.nendo,
        h.ki,
        to_char(ki.ki_symd, 'YYMMDD') as ki_symd,
        to_char(ki.ki_eymd, 'YYMMDD') as ki_eymd,
        to_char(no.yoku_ymd_online, 'YYMMDD') as yoku_ymd
    from honten_today h
    cross join ten_eigyo te
    cross join next_eigyo_online no
    left join ki_info ki on h.nen_ki = ki.nen_ki
)

select * from final
