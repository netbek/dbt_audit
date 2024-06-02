{% macro upload_run_results() -%}
    {% set package_database, package_schema = dbt_audit.get_package_database_and_schema('dbt_audit') %}
    {% set relation = adapter.get_relation(package_database, package_schema, 'dbt_run') %}

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
                {% set results_subset = results | selectattr('node.resource_type', 'equalto', resource_type) | list %}

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
                                    {%- elif 'Float32' in data_type or 'Float64' in data_type -%}
                                        {{ value }}
                                    {%- elif 'Int32' in data_type or 'Int64' in data_type -%}
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
