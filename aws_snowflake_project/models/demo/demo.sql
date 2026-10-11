{{ config(
    materialized='view'
) }}

SELECT * FROM AIRBNB.STAGING.LISTINGS