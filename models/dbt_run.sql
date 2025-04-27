{% if target.type == 'clickhouse' %}
    {{ config(
        tags=['dbt_audit'],
        contract={'enforced': false},
        on_schema_change='fail',
        materialized='incremental',
        incremental_strategy='append',
        unique_key='id',
        columns={
            'id': {'data_type': 'UInt64'},
            'invocation_id': {'data_type': 'UUID'},
            'node_id': {'data_type': 'String'},
            'thread_id': {'data_type': 'String'},
            'resource_type': {'data_type': 'String'},
            'schema': {'data_type': 'String'},
            'name': {'data_type': 'String'},
            'alias': {'data_type': 'String'},
            'materialization': {'data_type': 'String'},
            'is_full_refresh': {'data_type': 'Bool'},
            'run_start_at': {'data_type': 'DateTime64(6)'},
            'compile_start_at': {'data_type': 'Nullable(DateTime64(6))'},
            'compile_duration': {'data_type': 'Nullable(UInt64)', 'description': 'Duration in milliseconds.'},
            'execute_start_at': {'data_type': 'Nullable(DateTime64(6))'},
            'execute_duration': {'data_type': 'Nullable(UInt64)', 'description': 'Duration in milliseconds.'},
            'status': {'data_type': 'String'},
            'message': {'data_type': 'String'},
            'rows_affected': {'data_type': 'Nullable(UInt64)'},
            'adapter_response': {'data_type': 'String'}
        }
    ) }}

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
        cast(false, 'Bool') as is_full_refresh,
        cast(now(), 'DateTime64(6)') as run_start_at,
        cast(null, 'Nullable(DateTime64(6))') as compile_start_at,
        cast(null, 'Nullable(UInt64)') as compile_duration,
        cast(null, 'Nullable(DateTime64(6))') as execute_start_at,
        cast(null, 'Nullable(UInt64)') as execute_duration,
        '' as status,
        '' as message,
        cast(null, 'Nullable(UInt64)') as rows_affected,
        '' as adapter_response
    where false

{% elif target.type == 'postgres' %}
    {{ config(
        tags=['dbt_audit'],
        contract={'enforced': false},
        on_schema_change='fail',
        materialized='incremental',
        incremental_strategy='append',
        unique_key='id',
        columns={
            'id': {'data_type': 'varchar(32)'},
            'invocation_id': {'data_type': 'uuid'},
            'node_id': {'data_type': 'text'},
            'thread_id': {'data_type': 'text'},
            'resource_type': {'data_type': 'text'},
            'schema': {'data_type': 'text'},
            'name': {'data_type': 'text'},
            'alias': {'data_type': 'text'},
            'materialization': {'data_type': 'text'},
            'is_full_refresh': {'data_type': 'boolean'},
            'run_start_at': {'data_type': 'timestamp with time zone'},
            'compile_start_at': {'data_type': 'timestamp with time zone'},
            'compile_duration': {'data_type': 'bigint', 'description': 'Duration in milliseconds.'},
            'execute_start_at': {'data_type': 'timestamp with time zone'},
            'execute_duration': {'data_type': 'bigint', 'description': 'Duration in milliseconds.'},
            'status': {'data_type': 'text'},
            'message': {'data_type': 'text'},
            'rows_affected': {'data_type': 'bigint'},
            'adapter_response': {'data_type': 'text'}
        }
    ) }}

    select
        md5('')::varchar(32) as id,
        gen_random_uuid()::uuid as invocation_id,
        ''::text as node_id,
        ''::text as thread_id,
        ''::text as resource_type,
        ''::text as schema,
        ''::text as name,
        ''::text as alias,
        ''::text as materialization,
        false::boolean as is_full_refresh,
        now()::timestamptz as run_start_at,
        null::timestamptz as compile_start_at,
        null::bigint as compile_duration,
        null::timestamptz as execute_start_at,
        null::bigint as execute_duration,
        ''::text as status,
        ''::text as message,
        null::bigint as rows_affected,
        ''::text as adapter_response
    where false

{% endif %}
