{% macro database_timezone() %}
    {{ adapter.dispatch('database_timezone', 'dbt_audit')() }}
{% endmacro %}


{% macro clickhouse__database_timezone() %}
    {% set sql %}
        select timezone()
    {% endset %}
    {% set value = dbt_utils.get_single_value(sql) %}
    {{ return(value) }}
{% endmacro %}


{% macro postgres__database_timezone() %}
    {% set sql %}
        select current_setting('timezone')
    {% endset %}
    {% set value = dbt_utils.get_single_value(sql) %}
    {{ return(value) }}
{% endmacro %}
