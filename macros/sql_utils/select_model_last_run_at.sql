{% macro select_model_last_run_at(model, status=none) -%}
    {% set sql %}
        {{ dbt_audit.model_last_run_at(model, status=status) }}
    {% endset %}
    {{ return(dbt_utils.get_single_value(sql)) }}
{%- endmacro %}
