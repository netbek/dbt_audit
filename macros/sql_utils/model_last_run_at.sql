{% macro model_last_run_at(model, status=none) %}
    select max(run_start_at)
    from {{ adapter.get_relation(database=this.database, schema=var('dbt_audit_schema', this.schema), identifier='dbt_run') }}
    where
        node_id = '{{ model.unique_id }}'
        {% if status %}
            and status = '{{ status }}'
        {% endif %}
{% endmacro %}
