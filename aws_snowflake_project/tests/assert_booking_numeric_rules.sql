SELECT *
FROM {{ ref('bronze_booking') }}
WHERE nights_booked <= 0
   OR booking_amount < 0
   OR cleaning_fee < 0
   OR service_fee < 0
