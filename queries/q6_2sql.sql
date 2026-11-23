select viewings.property_id,viewings.viewing_id,
viewings.duration_min,(duration_min - (LAG(duration_min)
OVER(PARTITION BY viewings.property_id ORDER BY scheduled_at)))
as delta,
LAG(duration_min)
OVER(PARTITION BY viewings.property_id ORDER BY scheduled_at)
as previousduration,
LEAD(duration_min)
OVER(PARTITION BY viewings.property_id ORDER BY scheduled_at)
as nextduration
FROM viewings
WHERE property_id = 4
ORDER BY scheduled_at;



WITH daily AS (
    SELECT date_trunc('Day', scheduled_at) AS viewing_day,
           SUM(duration_min) AS total_min
    FROM viewings
    GROUP BY date_trunc('Day', scheduled_at)
)
SELECT viewing_day, total_min,
SUM(total_min)
OVER (ORDER BY viewing_day rows between unbounded preceding and current row)
as running_total,avg(total_min)
OVER (ORDER BY viewing_day rows between 7 preceding and current row)
as moving_average
FROM daily
ORDER BY viewing_day;

-- Task 6.2, Part A: Compare each row to its neighbors (row to row)
-- Question: For property 4, is each viewing longer or shorter than the one
-- before it, and what were the previous and next viewing durations?
SELECT viewings.property_id, viewings.viewing_id,
viewings.duration_min,
(duration_min - (LAG(duration_min)
OVER (PARTITION BY viewings.property_id ORDER BY scheduled_at)))
AS delta,
LAG(duration_min)
OVER (PARTITION BY viewings.property_id ORDER BY scheduled_at)
AS previousduration,
LEAD(duration_min)
OVER (PARTITION BY viewings.property_id ORDER BY scheduled_at)
AS nextduration
FROM viewings
WHERE property_id = 4
ORDER BY scheduled_at;

-- Task 6.2, Part B: Cumulative and smoothed
-- Question: How many viewing minutes has the platform accumulated day by day,
-- and what is the recent (8-row) moving average of daily minutes?
-- Target: 80 minutes per week = 1,040 minutes per quarter (13 weeks),
-- 4,160 minutes per year. The running total ends 2023 at 3,628.19 minutes
-- (87.2% of the yearly target). Best quarter: Q3 at 1,004.11 (96.5%).
-- Note: ROWS counts rows, not days. Days with no viewings are skipped, so an
-- 8-row window can cover more than 8 calendar days.
WITH daily AS (
    SELECT date_trunc('Day', scheduled_at) AS viewing_day,
           SUM(duration_min) AS total_min
    FROM viewings
    GROUP BY date_trunc('Day', scheduled_at)
)
SELECT viewing_day, total_min,
SUM(total_min)
OVER (ORDER BY viewing_day ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
AS running_total,
AVG(total_min)
OVER (ORDER BY viewing_day ROWS BETWEEN 7 PRECEDING AND CURRENT ROW)
AS moving_average
FROM daily
ORDER BY viewing_day;

-- Task 6.2, Part C: Where the series stops
-- Question: Which properties went more than 60 days between one viewing and
-- the next, and how long was each gap?
WITH something AS (
    SELECT property_id, viewing_id, scheduled_at,
           scheduled_at - LAG(scheduled_at)
           OVER (PARTITION BY property_id ORDER BY scheduled_at) AS gap
    FROM viewings
)
SELECT *
FROM something
WHERE gap > INTERVAL '60 days'
ORDER BY gap DESC;