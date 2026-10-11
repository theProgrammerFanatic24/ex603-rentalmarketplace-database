-- 3.1a The 10 cheapest available properties renting at or under $2,000 —
--    the producers whose records anchor the audit.
--    Requirement: SELECT, WHERE, ORDER BY, LIMIT.

SELECT properties.property_id, properties.property_label,monthly_rent
from properties
WHERE is_available = TRUE
AND monthly_rent<=2000
ORDER BY monthly_rent
LIMIT 10;

-- Finding: Only 7 properties meet the filter, not 10. The cheapest
--    rent at $600.05 (Property_06 and Property_07); the most
--    expensive qualifying one is Property_08 at $1,954.33.


-- 3.1b Every distinct viewing status recorded — what outcomes the
--    events can actually have, and whether a no-show status exists.
--    Requirement: SELECT DISTINCT.

SELECT DISTINCT viewings.viewing_status
from viewings;

-- Finding: Only three statuses exist: attended, disputed, cancelled.
--    There is no "no-show" status, so any no-show rate must have been
--    derived from other columns or statuses.

-- 3.1c (i) Viewings lasting 0 to 360 minutes with more than 1 km of travel,
--    longest first — to see how far renters traveled and how long they stayed.
--    Requirement: WHERE with a numeric range (BETWEEN).

SELECT viewings.viewing_id, viewings.scheduled_at, viewings.viewing_status,viewings.duration_min,travel_km
from viewings
WHERE duration_min between 0 and 360
AND travel_km>1
ORDER BY viewings.duration_min DESC,scheduled_at,viewing_status;

-- Finding: Longer travel distances generally go with longer stays.
--    Disputed viewings show real visit durations (e.g. 37.84 and
--    30.11 minutes), suggesting the renter was present.


-- 3.1c (ii) Viewings that were disputed or cancelled — the statuses that
--    could be mistaken for a renter no-show.
--    Requirement: WHERE with an explicit list of values (IN).



SELECT viewings.viewing_id,viewings.viewing_status,viewings.renter_id,duration_min, viewings.interest_score
from viewings
WHERE viewing_status in ('cancelled','disputed')
ORDER BY duration_min,interest_score;

-- Finding: Every cancelled viewing has a duration of 0.00, yet most
--    still record a travel distance. Disputed viewings have non-zero
--    durations.



-- 3.1d (i) Properties whose names start with "Property_1" — a
--    text-pattern search on the producer name.
--    Requirement: LIKE.

SELECT property_id, property_label, city, monthly_rent
FROM properties
WHERE property_label LIKE 'Property_1%'
ORDER BY city,property_id;

-- Finding: 6 properties match (Property_10 to Property_15), spread
--    across Haiphong, Hanoi, Hue and Saigon, with rents from $651.07
--    to $3,095.58. The pattern has no business meaning here since
--    names are generated; it demonstrates LIKE matching.



-- 3.1d (ii) Non-attended viewings with no recorded no-show reason
--    (the disputed ones), shown with a readable label in place of
--    the missing value.
--    Requirement: IS NULL, COALESCE.


SELECT viewings.viewing_id, viewings.renter_id, viewings.viewing_status,
       COALESCE(no_show_reason, 'Reason Not Provided') AS no_show_reason_label
FROM viewings
WHERE viewing_status NOT LIKE 'attended%'
  AND no_show_reason IS NULL
ORDER BY viewing_status;

-- Finding: no_show_reason is filled in only for cancelled viewings.
--    Every disputed (and attended) viewing has no reason recorded.

-- 3.1e Each viewing with the weekday it was scheduled on and a
--    plain-language interest level, ordered Sunday to Saturday and
--    lowest to highest interest — so a non-technical reader can see
--    when viewings happen and how interested renters were.
--    Requirement: computed columns, CASE.
SELECT
    renter_id, viewings.property_id, viewings.viewing_id, viewings.interest_score,
    CASE
        WHEN interest_score = 1.00 THEN 'Low Interest'
        WHEN interest_score = 1.25 THEN 'Moderate Interest'
        WHEN interest_score = 1.50 THEN 'High Interest'
        WHEN interest_score = 2.00 THEN 'Very High Interest'
        ELSE 'Score Out of Range'
    END AS interest_level,
    TO_CHAR(scheduled_at, 'Day') AS day_of_week
FROM viewings
ORDER BY date_part('dow', scheduled_at), interest_score;
-- Finding: All 200 viewings returned. Low Interest is the most common
--    level on every day of the week. Wednesday has the most viewings
--    (36) and Sunday the fewest (21). Very High Interest appears most
--    often on Monday (6).