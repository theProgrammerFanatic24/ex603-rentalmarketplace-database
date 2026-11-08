-- Task 5.2: Find Records That Joins May Exclude
-- Theme: Rental Marketplace


-- =========================================================
-- Part A: Compare INNER JOIN and LEFT JOIN
-- =========================================================

-- Requirement 1: Use LEFT JOIN to return all producers,
-- including those who have never had an event.
--
-- This query returns all 15 properties, including properties
-- 14 and 15, which have zero recorded viewings.
-- LEFT JOIN preserves every property even when no matching
-- viewing record exists.

SELECT
    p.property_id,
    p.property_label,
    COUNT(v.viewing_id) AS viewing_count
FROM properties p
LEFT JOIN viewings v
    ON p.property_id = v.property_id
GROUP BY p.property_id, p.property_label
ORDER BY viewing_count DESC;


-- Requirement 2: Write an equivalent query using INNER JOIN.
--
-- This query returns 13 properties because INNER JOIN only
-- includes properties that have matching records in viewings.
-- Properties 14 and 15 are excluded because neither property
-- has a recorded viewing.

SELECT
    p.property_id,
    p.property_label,
    COUNT(v.viewing_id) AS viewing_count
FROM properties p
INNER JOIN viewings v
    ON p.property_id = v.property_id
GROUP BY p.property_id, p.property_label
ORDER BY viewing_count DESC;


-- Requirement 3: Compare the results and determine how many
-- producers are excluded by the INNER JOIN.
--
-- The LEFT JOIN returned 15 properties, while the INNER JOIN
-- returned 13 properties. Therefore, the INNER JOIN excluded
-- two properties. The following query independently confirms
-- that two properties have no matching viewing records.

SELECT COUNT(*)
FROM properties p
LEFT JOIN viewings v
    ON p.property_id = v.property_id
WHERE v.viewing_id IS NULL;


-- Requirement 4: Explain which producers are missing and why.
--
-- Property_14 (property_id 14) and Property_15 (property_id 15)
-- are missing from the INNER JOIN results because neither has
-- a matching record in the viewings table. INNER JOIN requires
-- a matching record in both tables, so properties without
-- viewings are excluded. LEFT JOIN preserves these properties
-- and correctly reports zero viewings for each.


-- =========================================================
-- Part B: Explore RIGHT JOIN and FULL OUTER JOIN
-- =========================================================

-- Requirement 1: Write a RIGHT JOIN that returns the same
-- records as the LEFT JOIN from Part A.
--
-- This query places properties on the right side of the JOIN.
-- RIGHT JOIN preserves every property, including those without
-- viewing records.

SELECT
    p.property_id,
    p.property_label,
    COUNT(v.viewing_id) AS viewing_count
FROM viewings v
RIGHT JOIN properties p
    ON v.property_id = p.property_id
GROUP BY p.property_id, p.property_label
ORDER BY viewing_count DESC;


-- Requirement 2: Compare the results to confirm they match.
--
-- The RIGHT JOIN returned the same 15 properties and viewing
-- counts as the LEFT JOIN. Both queries included Property_14
-- and Property_15 with zero viewings. This confirms that
-- reversing the table order and changing LEFT JOIN to
-- RIGHT JOIN preserved the same records.


-- Requirement 3: Write a FULL OUTER JOIN that includes
-- matching and unmatched records from both tables.
--
-- FULL OUTER JOIN preserves all matching records and any
-- unmatched records from either table. This query returned
-- 15 property groups, including properties 14 and 15.

SELECT
    p.property_id,
    p.property_label,
    COUNT(v.viewing_id) AS viewing_count
FROM properties p
FULL OUTER JOIN viewings v
    ON p.property_id = v.property_id
GROUP BY p.property_id, p.property_label
ORDER BY viewing_count DESC;


-- Requirement 4: Explain what a FULL OUTER JOIN can reveal
-- that a LEFT JOIN or RIGHT JOIN alone may not show.
--
-- A FULL OUTER JOIN can reveal unmatched records from both
-- tables in a single query. In this marketplace, it can
-- identify properties without viewings and viewings without
-- matching properties. A LEFT JOIN preserves unmatched
-- properties when properties is the left table, while a
-- RIGHT JOIN preserves unmatched records from the right table.
-- The FULL OUTER JOIN returned the same 15 property groups
-- as the earlier queries, with no additional NULL property
-- group indicating unmatched viewings.


-- =========================================================
-- Part C: Find Producers with No Events Using Two Approaches
-- =========================================================

-- Requirement 1: Identify producers who have never had an
-- event using NOT EXISTS.
--
-- NOT EXISTS checks each property to determine whether a
-- matching viewing record exists. Properties without matching
-- records are included in the result.
-- This query returned Property_14 and Property_15.

SELECT
    p.property_id,
    p.property_label
FROM properties p
WHERE NOT EXISTS (
    SELECT 1
    FROM viewings v
    WHERE v.property_id = p.property_id
);


-- Requirement 2: Identify producers who have never had an
-- event using EXCEPT.
--
-- EXCEPT subtracts property identifiers appearing in viewings
-- from the complete set of property identifiers.
-- This query returned property IDs 14 and 15.

SELECT property_id
FROM properties

EXCEPT

SELECT viewings.property_id
FROM viewings;


-- Requirement 3: Run both queries and compare their results.
--
-- Both NOT EXISTS and EXCEPT returned the same two property
-- identifiers: 14 and 15. Therefore, both methods successfully
-- identified properties without recorded viewing activity.


-- Requirement 4: In one or two sentences, explain how the
-- approaches differ and confirm whether they identify the
-- same producers.
--
-- NOT EXISTS checks each property for the absence of matching
-- viewing records, while EXCEPT subtracts property IDs found
-- in viewings from the complete set of property IDs.
-- Both approaches identified the same properties, 14 and 15.