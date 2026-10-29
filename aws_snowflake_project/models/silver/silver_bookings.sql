{{ config(materialized="incremental", unique_key="booking_id") }}


select
    BOOKING_ID,
    LISTING_ID,
    BOOKING_DATE,
    BOOKING_AMOUNT as TOTAL_AMOUNT,
    CLEANING_FEE,
    SERVICE_FEE,
    BOOKING_STATUS,
    CREATED_AT
from {{ ref('bronze_booking') }}

{% if is_incremental() %}
WHERE CREATED_AT > (
    SELECT MAX(CREATED_AT)
    FROM {{ this }}
)
{% endif %}