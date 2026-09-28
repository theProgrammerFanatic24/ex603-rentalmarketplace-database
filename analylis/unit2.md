Unit 2: From Diagram to Database

Constraints table

Foreign key: fk_viewings_renter (viewings.renter_id references renters.renter_id)
ON DELETE: RESTRICT
Reason: A renter with viewing history cannot be deleted, so the duration_min data used for aggregate statistics is never lost.

Foreign key: fk_viewings_properties (viewings.property_id references properties.property_id)
ON DELETE: CASCADE
Reason: Once a property is removed, its viewing history no longer serves any purpose, so it is removed with it.

Foreign key: fk_listings_property (listing_amenities.property_id references properties.property_id)
ON DELETE: CASCADE
Reason: A removed property has no amenities to link, so its link rows are deleted.

Foreign key: fk_listings_amenities (listing_amenities.amenity_id references amenities.amenity_id)
ON DELETE: CASCADE
Reason: A removed amenity makes every link to it meaningless, so those link rows are deleted.

ON DELETE choices

viewings.renter_id (RESTRICT). The event this governs is someone trying to delete a renter who has viewed properties. The platform's core metric is duration_min, which is aggregated into things like average viewing time per property. Under CASCADE, deleting one renter would silently delete all of their viewings and lower every total and average built on them, and nobody would be warned. RESTRICT makes the database refuse the deletion, so whoever is doing it must decide deliberately what to do with that history. SET NULL was not an option because renter_id is part of the composite primary key of viewings, and primary key columns cannot be null.

viewings.property_id (CASCADE). The event is a property being permanently removed from the platform. Its viewings describe interest in something that no longer exists, so they have no ongoing analytical value. The people affected are the platform's analysts, who lose nothing useful. Under RESTRICT, removing a property would first require manually deleting every viewing of it, which adds work and blocks routine cleanup for no benefit.

listing_amenities.property_id (CASCADE). The event is a property being removed. The link rows only say "this property has this amenity", so they mean nothing without the property. CASCADE deletes only the link rows. The amenities themselves stay in the catalog for other properties. Under RESTRICT, a property could not be removed until its amenity links were cleared by hand.

listing_amenities.amenity_id (CASCADE). The event is an amenity being retired from the catalog, for example Laundromat. Every link to it is deleted, and the properties themselves are untouched; they just no longer carry that tag. Under RESTRICT, an amenity could never be retired while any property still used it, so the catalog could only grow.

CHECK constraints

chk_properties_cost_nonnegative (per_month_cost >= 0). Prevents a negative monthly rent. It could otherwise arise from a typo, a sign error in an import, or a bug in the application.

chk_properties_bedrooms_nonnegative (num_bedrooms >= 0). Prevents a negative bedroom count, from the same causes. Zero is allowed because a studio has no separate bedroom.

chk_properties_bathrooms_nonnegative (num_bathrooms >= 0). Prevents a negative bathroom count, from the same causes.

chk_properties_size_nonnegative (size >= 0). Prevents a negative property size, from the same causes.

chk_properties_floors_nonnegative (floors >= 0). Prevents a negative floor count, from the same causes.

chk_properties_type_valid (property_type IN 'Apartment', 'House', 'Studio', 'Condo'). Prevents any value outside the four categories, including misspellings and case variants such as apartmnt or apartment. It could otherwise arise from free-text entry, and the variants would split one category into several and break filtering and grouping by type.

chk_duration_min (duration_min > 0). Prevents a viewing lasting zero or negative minutes. It could otherwise arise from a failed timer, a clock error, or a bad calculation, and a negative duration would drag down every average and total built on this metric.

These rules are enforced in the schema rather than the application because the database applies them regardless of which script, tool, or person writes to the table.

What changed from Unit 1

renter_full_name was split into first_name and last_name, both VARCHAR(25) NOT NULL. The full name is computed at query time with first_name || ' ' || last_name and is not stored.

property_address was split into street VARCHAR(100), city VARCHAR(50), state VARCHAR(2), and zip VARCHAR(10), so properties can be filtered by location.

per_month_cost changed from FLOAT to NUMERIC(10,2), because money must not use floating point.

duration_min changed from FLOAT to INTEGER, because viewings are recorded in whole minutes.

size is INTEGER.

viewed_at now has DEFAULT CURRENT_TIMESTAMP.

Seven CHECK constraints were added, as described above.

All columns are NOT NULL except where a primary key already enforces it.

The ERD image and its source were updated to match.

Recursive foreign key

There is none. Every relationship in this schema links two different tables (renters to viewings, properties to viewings, properties to amenities through listing_amenities). No entity in the rental domain refers to another row of its own table.

Derived value

duration_min is stored, not derived. The viewings table has only a start time (viewed_at) and no end time, so there is nothing to subtract to compute it, and it is the metric the platform aggregates. The full name of a renter is derived, and I chose not to store it: it is computed at query time, since there is no measured need to pre-compute it and storing it would create a second copy that must be kept in sync.
