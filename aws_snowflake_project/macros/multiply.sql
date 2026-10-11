{% macro multiply(a, b, precision) %}
  round({{a}} * {{b}},{{precision}})
{% endmacro %}