{% macro on_run_end() -%}
    {% do dbt_audit.upload_run_results() %}
{%- endmacro %}
