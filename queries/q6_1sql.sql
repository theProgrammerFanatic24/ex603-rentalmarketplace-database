-- Task 6.1, Part 1a: Compare each event to its producer's average (window version)
-- Question: For every viewing, what was its duration, and what is the average
-- viewing duration for that same property, shown on the same row?
SELECT viewings.viewing_id, viewings.property_id, viewings.duration_min,
AVG(viewings.duration_min) OVER (PARTITION BY property_id) AS average_viewings
FROM viewings;

-- Task 6.1, Part 1b: Compare each event to its producer's average (GROUP BY version)
-- Question: What is the average viewing duration for each property?
-- (Returns 13 rows instead of 200; individual viewings are collapsed and lost.)
SELECT viewings.property_id,
AVG(viewings.duration_min)
FROM viewings
GROUP BY property_id
ORDER BY property_id;

-- Task 6.1, Part 2: Rank producers three ways
-- Question: How do properties rank by number of viewings, and how does each
-- ranking method treat properties that are tied?
SELECT property_id, COUNT(viewing_id) AS viewingsbyproperty,
row_number() OVER (ORDER BY COUNT(viewing_id) DESC),
rank() OVER (ORDER BY COUNT(viewing_id) DESC),
dense_rank() OVER (ORDER BY COUNT(viewing_id) DESC)
FROM viewings
GROUP BY property_id
ORDER BY viewingsbyproperty DESC;

-- Task 6.1, Part 3: Sort producers into four bands
-- Question: If properties are split into four equal-sized groups by number of
-- viewings, which group does each property land in, and are tied properties
-- kept together?
SELECT viewings.property_id, COUNT(viewings.viewing_id) AS viewingsbyproperty,
ntile(4) OVER (ORDER BY COUNT(viewings.viewing_id) DESC) AS propertyquartile
FROM viewings
GROUP BY property_id
ORDER BY propertyquartile;