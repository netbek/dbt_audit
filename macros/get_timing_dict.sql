{% macro get_timing_dict(timing) -%}
    {% set start_time = none %}
    {% set end_time = none %}
    {% set duration = none %}

    {% if timing %}
        {% set start_time = timing.started_at %}
        {% set end_time = timing.completed_at %}
    {% endif %}

    {% if start_time and end_time %}
        {% set duration = ((end_time - start_time).total_seconds() * 1000) | round %}
    {% endif %}

    {{ return({
        'start_time': start_time,
        'end_time': end_time,
        'duration': duration
    }) }}
{%- endmacro %}
