{% macro model_last_run_at(model, status=none) %}
    select max(run_start_at)
    from {{ api.Relation.create(schema=var('dbt_audit_schema'), identifier='dbt_run') }}
    where
        node_id = '{{ model.unique_id }}'
        {% if status %}
            and status = '{{ status }}'
        {% endif %}
{% endmacro %}
