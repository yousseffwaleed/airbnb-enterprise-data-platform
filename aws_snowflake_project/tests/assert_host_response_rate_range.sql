SELECT *
FROM {{ ref('silver_hosts') }}
WHERE response_rate < 0
   OR response_rate > 100
