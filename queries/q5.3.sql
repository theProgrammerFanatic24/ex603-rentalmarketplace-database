-- =========================================================
-- Task 5.3: Understand Join Performance and Execution Plans
-- Theme: Rental Marketplace
-- =========================================================


-- =========================================================
-- Part A: Explore CROSS JOIN
-- =========================================================


-- Requirement 1: Count the rows in each source table.
-- Question: How many amenities and properties exist?
--
-- The amenities table contains 5 records.
-- The properties table contains 15 records.

SELECT COUNT(*) AS amenity_count
FROM amenities;


SELECT COUNT(*) AS property_count
FROM properties;


-- Requirement 2: Run a CROSS JOIN between two small tables.
-- Question: What combinations result when every amenity
-- is paired with every property?
--
-- CROSS JOIN generates every possible combination of
-- amenities and properties without requiring matching records.
--
-- The query returned 75 rows representing all possible
-- combinations of 5 amenities and 15 properties.

SELECT
    a.amenity_id,
    a.amenity_name,
    p.property_id,
    p.property_label
FROM amenities a
CROSS JOIN properties p
ORDER BY a.amenity_id, p.property_id;


-- Requirement 3: Count the resulting CROSS JOIN rows.
-- Question: How many combinations did the CROSS JOIN produce?
--
-- The query returned 75 combinations.

SELECT COUNT(*) AS cross_join_count
FROM amenities a
CROSS JOIN properties p;


-- Requirement 4: Verify that the CROSS JOIN row count
-- equals the multiplication of the two source table counts.
-- Question: Does the actual row count equal the expected count?
--
-- The amenities table contains 5 rows.
-- The properties table contains 15 rows.
--
-- Expected combinations: 5 * 15 = 75.
-- Actual combinations: 75.
--
-- Both counts match, confirming that the CROSS JOIN
-- generated the expected Cartesian product.

SELECT
    (SELECT COUNT(*) FROM amenities) AS amenity_count,
    (SELECT COUNT(*) FROM properties) AS property_count,
    (SELECT COUNT(*) FROM amenities)
        * (SELECT COUNT(*) FROM properties) AS expected_count,
    (SELECT COUNT(*)
     FROM amenities
     CROSS JOIN properties) AS actual_count;


-- Requirement 5: Explain when a Cartesian product might
-- be useful and when it could indicate a query error.
--
-- A Cartesian product can be useful in the Rental Marketplace
-- when generating every possible combination of properties
-- and amenities for testing or planning purposes.
--
-- However, these combinations do not prove that a property
-- actually offers an amenity. The listing_amenities junction
-- table is needed to establish those relationships.
--
-- A Cartesian product can indicate a query error when a
-- required JOIN condition is accidentally omitted.
--
-- This can generate unnecessary combinations, duplicate
-- information, and misleading results.


-- =========================================================
-- Part B: Examine a Query Execution Plan
-- =========================================================


-- Requirement 1: Return to the three-table join from Task 5.1.
-- Question: How does PostgreSQL plan to retrieve the renter,
-- property, and scheduled viewing information?
--
-- EXPLAIN displays PostgreSQL's planned operations without
-- executing the SELECT query.
--
-- This is the original three-table join from Task 5.1.
-- It connects viewings, renters, and properties.
--
-- The execution plan contains 13 lines and identifies
-- a Hash Join, Nested Loop, sequential scans, an index scan,
-- Memoize, and a Sort operation.

EXPLAIN
SELECT
    r.renter_name,
    p.property_label,
    viewings.scheduled_at
FROM viewings
INNER JOIN public.renters r
    ON r.renter_id = viewings.renter_id
INNER JOIN public.properties p
    ON p.property_id = viewings.property_id
ORDER BY renter_name;


-- Requirement 2: Identify the join algorithms PostgreSQL uses.
-- Question: Which join algorithms did PostgreSQL select?
--
-- PostgreSQL selected two join algorithms:
-- Hash Join and Nested Loop.
--
-- The Hash Join connects viewings with renters using
-- their shared renter_id.
--
-- PostgreSQL builds a hash table from the renters records
-- and matches viewing records against that hash table.
--
-- The Nested Loop then connects the joined records with
-- properties using property_id.
--
-- PostgreSQL uses an index scan on properties_pkey
-- to locate matching property records.
--
-- The plan also includes Memoize, which caches property
-- lookups to avoid repeating the same index searches.


-- Requirement 3: Explain why PostgreSQL may have selected
-- these algorithms, considering table sizes and indexes.
-- Question: How do table sizes and available indexes affect
-- PostgreSQL's execution strategy?
--
-- PostgreSQL selected a Hash Join for viewings and renters
-- because both tables are relatively small.
--
-- The execution plan estimated 200 viewing records
-- and 100 renter records.
--
-- Sequential scans allow PostgreSQL to read these small
-- tables without requiring individual index lookups
-- for every record.
--
-- The Nested Loop uses the properties_pkey index to locate
-- matching properties by property_id.
--
-- This is efficient because the primary-key index allows
-- PostgreSQL to locate individual property records.
--
-- PostgreSQL also selected Memoize to cache repeated
-- property lookups.
--
-- EXPLAIN ANALYZE recorded 187 cache hits and 13 cache misses.
--
-- This means 187 property lookups were satisfied using
-- cached results, while 13 required index searches.
--
-- The execution plan also showed:
--
-- Estimated output rows: 200.
-- Actual output rows: 200.
-- Planning time: 0.152 milliseconds.
-- Execution time: 0.268 milliseconds.
-- Sort memory: 34 kB.
--
-- These observations indicate that PostgreSQL's estimates
-- were accurate for the final row count and that the
-- selected execution strategy performed efficiently
-- on the current dataset.


-- Requirement 4: Predict which part of the query might
-- become less efficient as the dataset grows.
-- Question: Which operations could become more expensive
-- as the number of viewing records increases?
--
-- As the number of viewings increases, the sequential scan
-- of the viewings table will need to process more records.
--
-- The Hash Join may require additional memory and processing
-- time to match a larger number of viewing records.
--
-- The final Sort operation could also become more expensive
-- because ORDER BY renter_name must organize the joined rows.
--
-- The Nested Loop may require additional property lookups
-- if the number of distinct properties increases.
--
-- Currently, Memoize reduces repeated property lookups.
-- The execution plan recorded 187 cache hits and only
-- 13 cache misses.
--
-- However, if the number of distinct properties increases,
-- the cache may become less effective and PostgreSQL may
-- perform additional index searches.
--
-- PostgreSQL may choose different execution strategies
-- as table sizes, available indexes, and the number
-- of matching records change.


-- Requirement 5: Use EXPLAIN ANALYZE to examine actual
-- execution behavior.
-- Question: How does the actual execution compare
-- with PostgreSQL's estimated execution plan?
--
-- EXPLAIN ANALYZE executes the SELECT query and reports
-- actual execution statistics.
--
-- The query returned 200 rows, matching the estimated
-- output of 200 rows.
--
-- The execution plan confirmed:
--
-- Hash Join between viewings and renters.
-- Nested Loop connecting the results with properties.
-- Sequential scans on viewings and renters.
-- Index Scan using properties_pkey.
-- Memoize with 187 hits and 13 misses.
-- Sort using 34 kB of memory.
--
-- Planning time: 0.152 milliseconds.
-- Execution time: 0.268 milliseconds.
--
-- The results confirm that PostgreSQL successfully executed
-- the three-table join and that the actual final row count
-- matched its estimate.

EXPLAIN ANALYZE
SELECT
    r.renter_name,
    p.property_label,
    viewings.scheduled_at
FROM viewings
INNER JOIN public.renters r
    ON r.renter_id = viewings.renter_id
INNER JOIN public.properties p
    ON p.property_id = viewings.property_id
ORDER BY renter_name;