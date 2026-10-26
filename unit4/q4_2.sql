-- 4.2A Total viewings and renter no-shows for each property, side by
--    side in one pass over the viewings table (with average duration),
--    so the properties with the most no-shows stand out.
--    Requirement: conditional aggregation (CASE inside an aggregate),
--    both totals as separate columns, no WHERE clause.

SELECT viewings.property_id, count(viewings.property_id) as total_viewings,COUNT(case when viewings.no_show_reason = 'Renter no show' THEN 1 END ) as unattendedRenters,Round(AVG(duration_min)) AS avg_viewing_duration
from viewings
GROUP BY viewings.property_id
ORDER BY unattendedRenters;

-- Finding: 12 no-shows in total, spread thinly across properties (at
--    most 3 per property). No-shows alone don't explain big drops in
--    the averages: they are only 12 of the 34 zero-minute (cancelled)
--    viewings. Outliers: property 2 has the most no-shows (3 of 16,
--    about 19%, average 17 min) and property 3 the next most (2 of 13,
--    about 15%) with the lowest average among them (13 min). Property
--    4 shows a high rate (1 of 6) but on too few viewings to rely on.
--    Property 11 has the lowest average overall (12 min) with only one
--    no-show, so other cancellations are dragging it down.


-- 4.2B Viewings and renter no-shows for each city (regional subtotals)
--    plus one platform-wide grand total, without the per-property
--    detail rows.
--    Requirement: GROUP BY ROLLUP.

SELECT properties.city,count(viewings.property_id) as total_viewings,COUNT(case when viewings.no_show_reason = 'Renter no show' THEN 1 END ) as unattendedRenters
from viewings
JOIN properties ON viewings.property_id = properties.property_id
GROUP BY Rollup (properties.city);

-- Finding: The row where city is NULL is the platform grand total
--    (200 viewings, 12 no-shows, about 6%). The five named city rows
--    are the regional subtotals, and they add up to the grand total.
--    No-show rate by city: Danang 3 of 16 (19%), Haiphong 4 of 50
--    (8%), Hue 2 of 36 (6%), Saigon 2 of 62 (3%), Hanoi 1 of 36 (3%).
--    Danang runs at about three times the platform rate despite having
--    the fewest viewings.


-- 4.2C Baseline no-show rate for high-volume properties — first
--    summarize each property's viewings and no-shows, then keep only
--    properties with more than 15 viewings and combine their rates.
--    Requirement: WITH clause producing an intermediate aggregate,
--    then a second aggregation and filter on that result.

with propertysummary as (
    SELECT viewings.property_id, count(viewings.property_id) as total_viewings,COUNT(case when viewings.no_show_reason = 'Renter no show' THEN 1 END ) as unattendedRenters
from viewings
GROUP BY viewings.property_id
)
SELECT ROUND(100.0 * SUM(unattendedRenters) / SUM(total_viewings), 1) AS highvolume_noshow_baseline
FROM propertysummary
WHERE total_viewings > 15;

-- Finding: The 8 high-volume properties have a combined no-show rate
--    of 4.8% (7 of 145 viewings), below the platform rate of 6%.
--    High-volume properties no-show less than the platform overall;
--    the low-volume properties push the overall rate up.
