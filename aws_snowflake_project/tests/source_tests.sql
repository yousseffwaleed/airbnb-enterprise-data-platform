{{config(
    severity = "warn"
)}}

select 1 from {{ source("staging", "bookings") }} where booking_amount < 200
