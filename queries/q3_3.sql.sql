-- 3.3 Question: which renters had at least one disputed viewing?
--    Step 1: find the renter ids on disputed viewings.
--    Step 2: return those renters' details.
--    Answered three ways below; all three must return identical rows.


-- 3.3 (i) Form 1: subquery using IN.
--    Requirement: subquery with IN.

SELECT renter_id, renter_name, email
FROM renters
WHERE renter_id IN (
    SELECT DISTINCT renter_id
    FROM viewings
    WHERE viewing_status = 'disputed'
)
ORDER BY renters.renter_id;

-- Finding: 7 renters: ids 1, 3, 5, 9, 16, 24, 25.


-- 3.3 (ii) Form 2: Common Table Expression.
--    Requirement: CTE using WITH.

WITH disputed_renters AS (
    SELECT DISTINCT renter_id
    FROM viewings
    WHERE viewing_status = 'disputed'
)
SELECT renter_id, renter_name, email
FROM renters
WHERE renter_id IN (SELECT renter_id FROM disputed_renters)
ORDER BY renter_id;

-- Finding: Same 7 renters, same names and emails, same order.


-- 3.3 (iii) Form 3: correlated subquery using EXISTS — for each
--    renter, check whether at least one disputed viewing belongs
--    to them.
--    Requirement: a third, distinct form (different subquery form).

SELECT renter_id, renter_name, email
FROM renters
WHERE EXISTS (
    SELECT DISTINCT renter_id
    FROM viewings
    WHERE viewings.renter_id = renters.renter_id
      AND viewing_status = 'disputed'
)
ORDER BY renter_id;

-- Finding: Same 7 renters again. All three result sets match row
--    for row (ids, names and emails), as shown in the screenshots
--    q3_3_i_in_subquery.png, q3_3_ii_cte.png and q3_3_iii_exists.png.


-- 3.3 (iv) When these would NOT match:
--    NULLs. If I flipped the question to "renters with no disputed
--    viewing" and one disputed viewing had no renter_id (NULL),
--    NOT IN would return nothing, because comparing to NULL is
--    unknown, so every renter gets thrown out. NOT EXISTS would still
--    give the right renters, because the NULL row just never matches
--    anyone.