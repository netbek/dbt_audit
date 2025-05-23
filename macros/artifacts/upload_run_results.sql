{% macro upload_run_results() %}
    {{ adapter.dispatch('upload_run_results', 'dbt_audit')() }}
{% endmacro %}


{% macro clickhouse__upload_run_results() -%}
    {% set package_database, package_schema = dbt_audit.get_package_database_and_schema('dbt_audit') %}
    {% set relation = adapter.get_relation(package_database, package_schema, 'dbt_run') %}

    {% set unquoted_types = [] %}
    {% for data_type in ['Float32', 'Float64', 'Int32', 'Int64', 'UInt32', 'UInt64'] %}
        {% do unquoted_types.extend([data_type, 'Nullable(' ~ data_type ~ ')']) %}
    {% endfor %}

    {% if execute and relation %}
        {% set columns = adapter.get_columns_in_relation(relation) %}
        {% set columns_dict = {} %}
        {% set column_names = [] %}
        {% for column in columns %}
            {% do columns_dict.update({column.name: column}) %}
            {% do column_names.append(column.name) %}
        {% endfor %}

        {% if columns | length %}
            {% for resource_type in ['model', 'seed'] %}
                {% set results_subset = results | rejectattr('node.unique_id', 'equalto', 'model.dbt_audit.dbt_run') | selectattr('node.resource_type', 'equalto', resource_type) | list %}

                {% if results_subset | length %}
                    {% set values -%}
                        {% for run_result in results_subset %}
                            {%- set run_result_dict = dbt_audit.get_run_result_dict(
                                run_result, flags, invocation_id, run_started_at
                            ) -%}
                            {%- set node_id = run_result_dict['node_id'] -%}

                            (
                                {% for column_name, column in columns_dict.items() %}
                                    {%- set data_type = column.data_type -%}
                                    {%- set value = run_result_dict.get(column_name) -%}

                                    {%- if column_name == 'id' -%}
                                        cityHash64('{{ invocation_id }}', '{{ node_id }}')
                                    {%- elif value is none -%}
                                        null
                                    {%- elif data_type == 'Bool' -%}
                                        {{ 'true' if value else 'false' }}
                                    {%- elif data_type in unquoted_types -%}
                                        {{ value }}
                                    {%- elif 'DateTime64' in data_type -%}
                                        toDateTime64('{{ value.isoformat() }}', 6)
                                    {%- elif 'DateTime' in data_type -%}
                                        toDateTime('{{ value.strftime("%Y-%m-%dT%H:%M:%S") }}')
                                    {%- else -%}
                                        '{{ value }}'
                                    {%- endif -%}

                                    {%- if not loop.last %},{% endif %}
                                {%- endfor %}
                            )
                            {%- if not loop.last %},{% endif %}
                        {% endfor %}
                    {%- endset %}

                    {% set sql -%}
                        insert into {{ relation }}
                        ({{ column_names | join(', ') }})
                        values
                        {{ values }}
                    {%- endset %}

                    {% do run_query(sql) %}
                {% endif %}
            {% endfor %}
        {% endif %}
    {% endif %}
{%- endmacro %}


{% macro postgres__upload_run_results() -%}
    {% set package_database, package_schema = dbt_audit.get_package_database_and_schema('dbt_audit') %}
    {% set relation = adapter.get_relation(package_database, package_schema, 'dbt_run') %}

    {% set unquoted_types = ['smallint', 'integer', 'bigint', 'decimal', 'numeric', 'real', 'double precision', 'smallserial', 'serial', 'bigserial'] %}

    {% if execute and relation %}
        {% set database_timezone = dbt_audit.database_timezone() %}
        {% set columns = adapter.get_columns_in_relation(relation) %}
        {% set columns_dict = {} %}
        {% set column_names = [] %}
        {% for column in columns %}
            {% do columns_dict.update({column.name: column}) %}
            {% do column_names.append(column.name) %}
        {% endfor %}

        {% if columns | length %}
            {% for resource_type in ['model', 'seed'] %}
                {% set results_subset = results | rejectattr('node.unique_id', 'equalto', 'model.dbt_audit.dbt_run') | selectattr('node.resource_type', 'equalto', resource_type) | list %}

                {% if results_subset | length %}
                    {% set values -%}
                        {% for run_result in results_subset %}
                            {%- set run_result_dict = dbt_audit.get_run_result_dict(
                                run_result, flags, invocation_id, run_started_at
                            ) -%}
                            {%- set node_id = run_result_dict['node_id'] -%}

                            (
                                {% for column_name, column in columns_dict.items() %}
                                    {%- set data_type = column.data_type -%}
                                    {%- set value = run_result_dict.get(column_name) -%}

                                    {%- if column_name == 'id' -%}
                                        md5('{{ invocation_id }}' || '{{ node_id }}')
                                    {%- elif value is none -%}
                                        null
                                    {%- elif data_type == 'boolean' -%}
                                        {{ 'true' if value else 'false' }}
                                    {%- elif data_type in unquoted_types -%}
                                        {{ value }}
                                    {%- elif data_type == 'timestamp with time zone' -%}
                                        cast((cast('{{ value }}' as timestamp without time zone) at time zone 'UTC' at time zone '{{ database_timezone }}') as timestamp with time zone)
                                    {%- else -%}
                                        '{{ value }}'
                                    {%- endif %}

                                    {%- if not loop.last %},{% endif %}
                                {%- endfor %}
                            )
                            {%- if not loop.last %},{% endif %}
                        {% endfor %}
                    {%- endset %}

                    {% set sql -%}
                        insert into {{ relation }}
                        ({{ column_names | join(', ') }})
                        values
                        {{ values }}
                    {%- endset %}

                    {% do run_query(sql) %}
                    {% do adapter.commit() %}
                {% endif %}
            {% endfor %}
        {% endif %}
    {% endif %}
{%- endmacro %}
