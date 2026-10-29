{{
    config(
        materialized='ephemeral'
    )
}} 

WITH hosts AS (
    SELECT 
        HOST_ID,
        HOST_NAME,
        HOST_SINCE,
        IS_SUPERHOST,
        RESPONSE_RATE_TAG,
        CREATED_AT AS HOST_CREATED_AT
    FROM {{ ref('silver_hosts') }}
) 

SELECT * FROM hosts