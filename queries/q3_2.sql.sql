-- 3.2A (i) The broken filter: viewings whose no-show reason is anything
--    other than "Renter cancelled." Intended to return every viewing
--    except those 8, but it silently drops every row where the reason
--    is NULL.
--    Requirement: negation/inequality predicate on a nullable column.

SELECT viewings.viewing_id, viewings.renter_id, viewings.viewing_status, no_show_reason
FROM viewings
WHERE no_show_reason != 'Renter cancelled'
ORDER BY viewing_status;

-- Finding: Returns only 26 rows, all cancelled. Every attended and
--    disputed viewing is missing, with no error or warning.


-- 3.2A (ii) How many rows the broken filter returned, how many it
--    silently dropped, and the table total, side by side.
--    Requirement: count of omitted rows; show the counts do not sum
--    to the total.

SELECT
    (SELECT COUNT(*) FROM viewings
     WHERE no_show_reason != 'Renter cancelled') AS returned_by_filter,
    (SELECT COUNT(*) FROM viewings
     WHERE no_show_reason IS NULL)              AS silently_dropped,
    (SELECT COUNT(*) FROM viewings)             AS table_total;

-- Finding: 26 returned, 166 silently dropped, 200 total. The 8 missing
--    from 26 + 166 are the "Renter cancelled" rows excluded on purpose.
--    The 166 dropped rows all have a NULL reason: comparing NULL with
--    != gives UNKNOWN, not TRUE, so WHERE discards them.


-- 3.2A (iii) The repair: every viewing except "Renter cancelled,"
--    explicitly keeping the rows where no reason was recorded.
--    Requirement: repair using IS NULL.

SELECT viewings.viewing_id, viewings.renter_id, viewings.viewing_status, no_show_reason
FROM viewings
WHERE no_show_reason != 'Renter cancelled'
   OR no_show_reason IS NULL
ORDER BY viewing_status;

-- Finding: Returns 192 rows (26 + 166), every viewing except the 8
-- "Renter cancelled" ones, which is what the filter was meant to do.



-- 3.2B (i) The failing query: viewings scheduled on a Monday, filtering
--    on the day_of_week alias defined in SELECT.
--    Requirement: alias referenced in WHERE (reproduce the error).
--    Commented out so this file runs without stopping; see the
--    screenshot for it running and failing.
--
 --SELECT
  -- renter_id, viewings.property_id, viewings.viewing_id, viewings.interest_score,
  --TO_CHAR(scheduled_at, 'Day') AS day_of_week
 --FROM viewings
--WHERE day_of_week = 'monday'
 --ORDER BY date_part('dow', scheduled_at), interest_score;
--
-- Error (verbatim): [42703] ERROR: column "day_of_week" does not exist
--    Position: 161
--
-- Finding: PostgreSQL evaluates WHERE before SELECT, so the alias
--    day_of_week does not exist yet when the filter runs.


-- 3.2B (ii) Rewrite 1: viewings scheduled on a Monday, repeating the
--    full expression in WHERE instead of using the alias.
--    Requirement: correct rewrite by repeating the expression.

SELECT
    renter_id, viewings.property_id, viewings.viewing_id, viewings.interest_score,
    trim(TO_CHAR(scheduled_at, 'Day')) AS day_of_week
FROM viewings
WHERE trim(TO_CHAR(scheduled_at, 'Day')) = 'Monday'
ORDER BY date_part('dow', scheduled_at), interest_score;

-- Finding: Returns 26 Monday viewings. trim() is needed because
--    TO_CHAR pads day names to 9 characters ('Monday   ').


-- 3.2B (iii) Rewrite 2: viewings scheduled on a Monday, computing
--    day_of_week inside a CTE so the outer query can filter on it
--    as a real column.
--    Requirement: correct rewrite using a CTE.

WITH check_for_monday AS (
    SELECT renter_id, viewings.property_id, viewings.viewing_id, viewings.interest_score,
           trim(TO_CHAR(scheduled_at, 'Day')) AS day_of_week
    FROM viewings
)
SELECT * FROM check_for_monday
WHERE day_of_week = 'Monday';

-- Finding: Returns the same 26 Monday viewings as rewrite 1.