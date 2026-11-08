
Assignment 5: SQL Joins and Platform Analysis

Theme: Rental Marketplace


TASK 5.1: CONNECT PRODUCERS TO THEIR DATA

1. What feature or report on your platform could use the three-table join from Question 1? What information would it display?

A rental marketplace could use the three-table join to create a property viewing activity report. This report would display the renter's name, the property associated with each viewing, and the scheduled viewing date and time.

My query joined the renters, viewings, and properties tables and returned 200 viewing records. This information could help property managers monitor viewing activity and identify which properties are attracting renter interest.

2. Why is the junction table important for answering Question 2? What would make this analysis more difficult without it?

The listing_amenities junction table is important because properties and amenities have a many-to-many relationship. One property can have multiple amenities, and the same amenity can be associated with multiple properties.

By joining properties and amenities through listing_amenities, I identified nine properties associated with the Pool amenity.

Without the junction table, storing and retrieving multiple amenities for each property would be more difficult and could require duplicated information or additional processing.


TASK 5.2: FIND RECORDS THAT JOINS MAY EXCLUDE

1. Which producers were excluded by the inner join? Report their identifiers.

The INNER JOIN excluded Property_14 (property_id 14) and Property_15 (property_id 15). These properties had no recorded viewings, so they did not appear in the INNER JOIN results.

The LEFT JOIN returned all 15 properties, while the INNER JOIN returned 13. The difference confirms that two properties were excluded.

2. What does it mean when a producer has no events? What are some possible explanations?

In the Rental Marketplace dataset, a property without events has no recorded viewing activity.

Possible explanations include limited renter interest, a recently created listing, incorrect availability information, or a property that has not yet been promoted.

However, the absence of viewing records does not establish why the property has no activity. Additional investigation would be necessary to determine the actual reason.

3. How could a report based only on an inner join give leadership an incomplete picture of the platform?

A report based only on an INNER JOIN would exclude properties without matching viewing records.

In my results, the INNER JOIN returned 13 properties, while the LEFT JOIN returned all 15.

This could give leadership an incomplete understanding of platform activity because properties with zero viewings would not appear in the report.

4. Why might leadership want to identify producers who have never been active?

Leadership may want to identify properties without viewing activity because they could represent missed opportunities within the rental marketplace.

These properties may require additional attention to determine whether their listings are visible, whether their availability information is accurate, or whether renters are interested in their locations.

5. What action could leadership take based on these findings?

Leadership could investigate Property_14 and Property_15 by reviewing their listing information, availability, rental prices, and listing dates.

If these properties are available but attracting little interest, leadership could consider improving their descriptions or increasing their visibility.

These recommendations require further investigation because the database results show that the properties have no recorded viewings but do not explain why.


TASK 5.3: UNDERSTAND JOIN PERFORMANCE AND EXECUTION PLANS

1. Give an example of when a Cartesian product could be useful on your platform, or explain why you would not need one.

A Cartesian product could be useful when generating every possible property and amenity combination for testing or planning purposes.

My CROSS JOIN combined five amenities with 15 properties and returned 75 combinations. The expected result of 5 × 15 matched the actual result of 75.

However, these combinations do not establish which amenities a property actually offers. The listing_amenities junction table is needed to determine those relationships.

2. Which join algorithms did PostgreSQL choose for your query?

PostgreSQL selected Hash Join and Nested Loop.

The Hash Join connected the viewings and renters tables using renter_id. The Nested Loop then connected those records to the properties table using property_id.

The execution plan also included sequential scans, an index scan, Memoize, and a Sort operation.

3. What information in the execution plan helps explain those choices?

The execution plan estimated 200 viewing records and 100 renter records, making sequential scans and a Hash Join reasonable choices for the relatively small tables.

For properties, PostgreSQL used an index scan on properties_pkey and a Memoize operation to avoid repeated lookups.

EXPLAIN ANALYZE recorded 187 cache hits, 13 cache misses, and 13 index searches.

The query returned 200 rows, matching PostgreSQL's estimated final row count. Planning took 0.152 milliseconds, and execution took 0.268 milliseconds.

These results indicate that the chosen plan performed efficiently for the current dataset.

4. Why is it useful to understand the selected join algorithms?

Understanding join algorithms helps developers identify how PostgreSQL retrieves and combines records.

Different algorithms can have different memory and processing costs. Reviewing execution plans helps identify expensive operations, evaluate whether indexes are useful, and anticipate performance problems as the database grows.

It also prevents developers from assuming that a query is efficient simply because it executes successfully.

5. What changes to the data or database might make another join algorithm more appropriate?

Increasing the number of viewings, renters, or properties could change the relative costs of different join strategies.

For example, a larger viewing table may increase the cost of sequential scans and the Hash Join. More distinct properties could reduce the effectiveness of Memoize and require additional index lookups.

Additional indexes, changes in the number of matching records, or different data distributions could make other join algorithms more appropriate.

PostgreSQL evaluates these conditions when selecting an execution plan.


REFLECTION (150–250 WORDS)

In Task 5.3, I examined PostgreSQL's execution plan for a three-table join connecting renters, viewings, and properties. PostgreSQL selected a Hash Join and a Nested Loop, along with sequential scans, an index scan, and Memoize. The query returned 200 records in 0.268 milliseconds, demonstrating that the selected plan worked efficiently for the current dataset.

One factor that could change PostgreSQL's choice is table size. The current viewing table contains 200 records, making a sequential scan relatively inexpensive. If the table grew to millions of records, PostgreSQL would need to evaluate whether different scanning or joining strategies would reduce execution costs.

Indexes could also influence the selected algorithm. The current plan uses the properties_pkey index to retrieve matching properties. Additional indexes might become useful for more selective queries, although indexes do not automatically improve every join.

The number of matching records also matters. Memoize currently produces 187 cache hits and 13 misses because many viewings reference the same properties. If the marketplace expanded to thousands of distinct properties, fewer repeated lookups might reduce the benefit of caching.

Overall, PostgreSQL's selected join algorithm depends on the available data, indexes, and estimated execution costs. Understanding these factors helps developers anticipate performance changes rather than assuming that one join algorithm will always be the most efficient.
