{% macro get_run_result_dict(run_result, flags, invocation_id, run_started_at) -%}
    {% set is_full_refresh = run_result.node.config.full_refresh %}
    {% if is_full_refresh is none %}
        {% set is_full_refresh = flags.FULL_REFRESH %}
    {% endif %}

    {% set compile_timing = none %}
    {% set execute_timing = none %}
    {% if run_result.timing %}
        {% set compile_timing = run_result.timing | selectattr('name', 'eq', 'compile') | first %}
        {% set execute_timing = run_result.timing | selectattr('name', 'eq', 'execute') | first %}
    {% endif %}

    {% set compile_timing_dict = dbt_audit.get_timing_dict(compile_timing) %}
    {% set execute_timing_dict = dbt_audit.get_timing_dict(execute_timing) %}

    {% set rows_affected = run_result.adapter_response.get('rows_affected') %}
    {% set status = run_result.status.value if run_result.status else none %}

    {% do return({
        'invocation_id': invocation_id,
        'node_id': run_result.node.unique_id,
        'thread_id': run_result.thread_id,
        'resource_type': run_result.node.resource_type.value,
        'schema': run_result.node.schema,
        'name': run_result.node.name,
        'alias': run_result.node.alias,
        'materialization': run_result.node.config.materialized,
        'is_full_refresh': is_full_refresh,
        'run_start_at': run_started_at.replace(tzinfo=None),
        'compile_start_at': compile_timing_dict['start_at'],
        'compile_end_at': compile_timing_dict['end_at'],
        'compile_duration': compile_timing_dict['duration'],
        'execute_start_at': execute_timing_dict['start_at'],
        'execute_end_at': execute_timing_dict['end_at'],
        'execute_duration': execute_timing_dict['duration'],
        'status': status,
        'message': run_result.message,
        'rows_affected': rows_affected,
        'adapter_response': tojson(run_result.adapter_response),
    }) %}
{%- endmacro %}
