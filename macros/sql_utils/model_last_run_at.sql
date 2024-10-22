{% macro model_last_run_at(model) %}
    select max(run_start_time)
    from {{ api.Relation.create(schema=var('dbt_audit_schema'), identifier='dbt_run') }}
    where node_id = '{{ model.unique_id }}'
{% endmacro %}
