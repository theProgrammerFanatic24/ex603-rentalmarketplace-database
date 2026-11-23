-- Task 6.3, Part A: Top N per category
-- Question: What are the three longest viewings for each property, and how far
-- is each one from that property's single longest viewing?
-- Ties at third place: RANK() gives tied viewings the same rank, so if two
-- viewings tie for 3rd, both are kept (a property can return more than 3 rows).
-- This is deliberate: dropping one of two equal viewings would be arbitrary,
-- which is what ROW_NUMBER() would do.
WITH ranked AS (
    SELECT property_id, viewing_id, scheduled_at, duration_min,
           RANK() OVER (PARTITION BY property_id ORDER BY duration_min DESC) AS duration_rank,
           FIRST_VALUE(duration_min)
           OVER (PARTITION BY property_id ORDER BY duration_min DESC) AS longest_for_property
    FROM viewings
)
SELECT property_id, viewing_id, scheduled_at, duration_min, duration_rank,
       longest_for_property,
       longest_for_property - duration_min AS minutes_below_longest
FROM ranked
WHERE duration_rank <= 3
ORDER BY property_id, duration_rank;

-- Task 6.3, Part B: Period over period
-- Question: Is the platform getting better or worse each month? How do total
-- viewing minutes and cancellations change compared with the month before?
-- Missing-month check: LAG compares with the previous ROW, so if a month had no
-- viewings, LAG would compare against the wrong month. month_check flags any
-- row whose previous row is not exactly one calendar month earlier.
WITH monthly AS (
    SELECT DATE_TRUNC('month', scheduled_at) AS viewing_month,
           COUNT(*) AS viewings,
           COUNT(*) FILTER (WHERE viewing_status = 'cancelled') AS cancelled,
           SUM(duration_min) AS total_min
    FROM viewings
    GROUP BY DATE_TRUNC('month', scheduled_at)
)
SELECT viewing_month, viewings, cancelled, total_min,
       LAG(total_min) OVER (ORDER BY viewing_month) AS prev_month_min,
       ROUND((total_min - LAG(total_min) OVER (ORDER BY viewing_month))
             / NULLIF(LAG(total_min) OVER (ORDER BY viewing_month), 0) * 100, 1) AS pct_change,
       CASE
           WHEN LAG(viewing_month) OVER (ORDER BY viewing_month) IS NULL THEN 'first month'
           WHEN LAG(viewing_month) OVER (ORDER BY viewing_month)
                = viewing_month - INTERVAL '1 month' THEN 'ok'
           ELSE 'MISSING MONTH BEFORE THIS ROW'
       END AS month_check
FROM monthly
ORDER BY viewing_month;