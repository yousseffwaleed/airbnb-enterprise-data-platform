select b.booking_id
from {{ ref('silver_bookings') }} as s
join {{ ref('bronze_booking') }} as b on s.booking_id = b.booking_id
where s.total_amount <> b.booking_amount
