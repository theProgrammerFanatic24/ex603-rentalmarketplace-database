-- 4.1a Platform baseline — how many viewings there are, their total,
--    average, shortest and longest duration, and how many different
--    renters booked them, across the whole viewings table.
--    Requirement: COUNT, SUM, AVG, MIN, MAX, COUNT(DISTINCT).

SELECT COUNT(*) as totalViewings,
SUM(duration_min) AS total_duration_min,
Round(AVG(duration_min)) AS avg_viewing_duration,
MIN(duration_min) AS shortest_viewing,
MAX(duration_min) AS longest_viewing,
COUNT(DISTINCT viewings.renter_id) as totalRenters
FROM viewings;

-- Finding: 200 viewings, 3,628.19 total minutes, about 18 minutes on
--    average, shortest 0, longest 70.86, from 30 distinct renters.
--    The minimum of 0 is a data-quality flag: every cancelled viewing
--    is recorded as 0 minutes, so cancellations and no-shows sit in
--    the same metric as real visits and pull the average down.


-- 4.1b Viewing count and average duration for each property, from the
--    property with the most viewings to the fewest — how activity and
--    performance differ across producers.
--    Requirement: GROUP BY, COUNT, AVG, ORDER BY.

SELECT viewings.property_id,count(viewings.property_id) as total_viewings, ROUND(AVG(duration_min)) as averageduration
from viewings
GROUP BY property_id
ORDER BY total_viewings DESC;

-- Finding: 13 properties, counts ranging from 21 down to 6 (they sum
--    to 200). The busiest property is not the best performer:
--    property 6 has the most viewings (21) but averages 18 minutes,
--    while properties 8 and 5 have the highest averages (23 minutes).
--    Cancellations count as 0 minutes, so a property with more
--    cancellations has its average artificially lowered.


-- 4.1c Properties with enough viewings for their numbers to mean
--    anything — only those with more than 15 viewings.
--    Requirement: GROUP BY with HAVING.

SELECT viewings.property_id,count(viewings.property_id) as total_viewings, ROUND(AVG(duration_min)) as averageduration
from viewings
GROUP BY property_id
HAVING count(viewings.property_id)>15
ORDER BY total_viewings DESC;

-- Finding: 8 of 13 properties remain (16 to 21 viewings each).
--    Threshold: more than 15 viewings, chosen as roughly the middle of
--    the 6 to 21 range. Properties below it have fewer data points, so
--    one or two cancellations swing their average a lot and their
--    numbers are less reliable. The kept properties cluster at 17 to
--    23 average minutes (property 11, at 12, is the exception), and
--    there is a slight upward trend: properties with more viewings
--    tend toward longer average durations.


-- 4.1d Viewing count and average duration for every combination of
--    city and viewing status — so each regional leader can review
--    their own city's results.
--    Requirement: GROUP BY on two dimensions, including region.

SELECT properties.city,viewings.viewing_status,count(viewings.property_id)as total_viewings,ROUND(AVG(duration_min)) as averageduration
from viewings
JOIN properties on viewings.property_id = properties.property_id
GROUP BY properties.city, viewings.viewing_status
ORDER BY city;

-- Finding: 14 rows across 5 cities (Danang has no disputed viewings),
--    summing to 200. In every city, attended viewings have both the
--    most viewings and the longest average duration, except Hanoi,
--    where a single disputed viewing at 38 minutes is a low-volume
--    outlier. Cancelled viewings average 0 everywhere. Cancellation
--    share varies by city: Danang 25%, Haiphong 24%, Hue 19%,
--    Saigon 15%, Hanoi 6%.
