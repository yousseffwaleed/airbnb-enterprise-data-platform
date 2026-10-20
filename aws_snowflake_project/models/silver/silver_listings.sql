{{ config(materialized="incremental", unique_key="LISTING_ID") }}

SELECT
    LISTING_ID,
    HOST_ID,
    PROPERTY_TYPE,
    ROOM_TYPE,
    CITY,
    COUNTRY,
    ACCOMMODATES,
    BEDROOMS,
    BATHROOMS,
    PRICE_PER_NIGHT,
    {{ tag('CAST(PRICE_PER_NIGHT AS INT)') }} AS PRICE_PER_NIGHT_TAG,
    CREATED_AT
FROM {{ ref('bronze_listings') }}

{% if is_incremental() %}
WHERE CREATED_AT > (
    SELECT MAX(CREATED_AT)
    FROM {{ this }}
)
{% endif %}