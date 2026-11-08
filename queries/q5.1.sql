-- Task 5.1: Connect Producers to Their Data
-- Theme: Rental Marketplace


-- =========================================================
-- Question 1: Who are the people behind the events?
-- =========================================================

-- Requirement: Write a query that joins three tables to display
-- the actor who performed each event, the producer associated
-- with the event, and the event's date and time.
--
-- This query joins the viewings, renters, and properties tables
-- to identify which renter scheduled a viewing, which property
-- was involved, and when the viewing was scheduled.
--
-- The viewings table contains the renter and property identifiers.
-- The INNER JOIN operations retrieve the corresponding renter
-- names and property labels from their respective tables.
--
-- The query returned 200 viewing records, showing the renter,
-- property, and scheduled date and time for each viewing.

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


-- =========================================================
-- Question 2: Do the producers identified in Assignment 4
-- share certain catalog credentials or tags?
-- =========================================================

-- Requirement: Write a query that connects the producer table
-- to the catalog table through the junction table and returns
-- producers associated with the selected catalog tag.
--
-- This query identifies properties associated with the Pool
-- amenity by joining amenities, listing_amenities, and properties.
--
-- The listing_amenities table serves as a junction table that
-- connects properties with their amenities through identifiers.
-- This relationship allows multiple properties to share the
-- same amenity while also allowing each property to have
-- multiple amenities.
--
-- The WHERE condition restricts the results to properties
-- associated with the Pool amenity.
--
-- The query returned nine properties with the Pool amenity.
-- These properties were identified as sharing a common
-- catalog characteristic.

SELECT
    p.property_id,
    p.property_label,
    amenities.amenity_name
FROM amenities
JOIN public.listing_amenities la
    ON amenities.amenity_id = la.amenity_id
JOIN public.properties p
    ON p.property_id = la.property_id
WHERE amenities.amenity_name = 'Pool'
ORDER BY p.property_id;


-- =========================================================
-- Question 3: How do the producers compare with one another?
-- =========================================================

-- Requirement: Write a self join to compare records within
-- the producer table and explore characteristics shared
-- between producers.
--
-- This query compares properties located in the same city
-- by joining the properties table to itself.
--
-- The alias p represents a second reference to the properties
-- table, allowing different properties to be compared.
--
-- The ON condition matches properties that share the same city.
-- The WHERE condition compares their property identifiers
-- to prevent a property from matching itself and to eliminate
-- reversed duplicate pairs.
--
-- The query returned 20 unique property pairs located in
-- the same cities.
--
-- These results identify properties that share a geographic
-- characteristic. However, additional viewing activity data
-- would be necessary to determine whether those properties
-- also have similar performance.

SELECT
    properties.property_label AS allNames,
    properties.city AS allcities,
    p.property_label
FROM properties
JOIN public.properties p
    ON properties.city = p.city
WHERE p.property_id < properties.property_id;