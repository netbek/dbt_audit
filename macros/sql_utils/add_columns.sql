{% macro add_columns(cte_ref) %}
    {{ adapter.dispatch('add_columns', 'dbt_audit')(cte_ref) }}
{% endmacro %}


{% macro clickhouse__add_columns(cte_ref) %}
    select
        *,
        cityHash64('{{ invocation_id }}', '{{ model.unique_id }}') as dbt_run_id
    from {{ cte_ref }}
{% endmacro %}


{% macro postgres__add_columns(cte_ref) %}
    select
        *,
        md5('{{ invocation_id }}' || '{{ model.unique_id }}') as dbt_run_id
    from {{ cte_ref }}
{% endmacro %}
