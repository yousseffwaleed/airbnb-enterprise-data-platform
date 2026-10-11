{% macro tag(column_name) %}
    CASE
        WHEN {{ column_name }} < 100 THEN 'low'
        WHEN {{ column_name }} > 200 THEN 'medium'
        ELSE 'high'
    END
{% endmacro %}
