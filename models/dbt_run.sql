{% if target.type == 'clickhouse' %}
    {{ config(
        tags=['dbt_audit'],
        contract={'enforced': true},
        on_schema_change='fail',
        materialized='incremental',
        incremental_strategy='append',
        unique_key='id'
    ) }}

    with final as (
        select 1
    )

    select
        cityHash64('') as id,
        generateUUIDv4() as invocation_id,
        '' as node_id,
        '' as thread_id,
        '' as resource_type,
        '' as schema,
        '' as name,
        '' as alias,
        '' as materialization,
        false as is_full_refresh,
        cast(now(), 'DateTime64(6)') as run_start_time,
        cast(null, 'Nullable(DateTime64(6))') as compile_start_time,
        cast(null, 'Nullable(UInt64)') as compile_duration,
        cast(null, 'Nullable(DateTime64(6))') as execute_start_time,
        cast(null, 'Nullable(UInt64)') as execute_duration,
        '' as status,
        '' as message,
        cast(null, 'Nullable(UInt64)') as rows_affected,
        '' as adapter_response
    from final
    where 1 = 0

{% elif target.type == 'postgres' %}
    {{ config(
        tags=['dbt_audit'],
        contract={'enforced': false},
        on_schema_change='fail',
        materialized='incremental',
        incremental_strategy='append',
        unique_key='id'
    ) }}

    with final as (
        select 1
    )

    select
        md5('')::char(32) as id,
        gen_random_uuid()::uuid as invocation_id,
        ''::text as node_id,
        ''::text as thread_id,
        ''::text as resource_type,
        ''::text as schema,
        ''::text as name,
        ''::text as alias,
        ''::text as materialization,
        false::boolean as is_full_refresh,
        now()::timestamp as run_start_time,
        null::timestamp as compile_start_time,
        null::bigint as compile_duration,
        null::timestamp as execute_start_time,
        null::bigint as execute_duration,
        ''::text as status,
        ''::text as message,
        null::bigint as rows_affected,
        ''::text as adapter_response
    from final
    where 1 = 0

{% endif %}
