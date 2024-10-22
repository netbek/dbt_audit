{% macro get_timing_dict(timing) -%}
    {% set start_at = none %}
    {% set end_at = none %}
    {% set duration = none %}

    {% if timing %}
        {% set start_at = timing.started_at %}
        {% set end_at = timing.completed_at %}
    {% endif %}

    {% if start_at and end_at %}
        {% set duration = ((end_at - start_at).total_seconds() * 1000) | round %}
    {% endif %}

    {{ return({
        'start_at': start_at,
        'end_at': end_at,
        'duration': duration
    }) }}
{%- endmacro %}
