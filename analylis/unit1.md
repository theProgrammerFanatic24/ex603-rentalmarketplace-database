# Modelling Justification

This schema models a rental marketplace with five roles: renters (actor), properties (producer), viewings (event), amenities (catalog), and listing_amenities (junction).

Primary key choices. Renters, properties, and amenities each use a surrogate auto-increment integer primary key (renter_id, property_id, amenity_id). Surrogate keys were chosen over natural keys because none of these entities have an attribute guaranteed to be both unique and stable — a property's address, for instance, could theoretically repeat (multiple units at one building), so an address is not a safe unique identifier. An auto-increment integer is simple, small, and fast to index and join on.

Viewings, the event table, uses a composite primary key of (renter_id, property_id, viewed_at) instead of a surrogate key. This was a deliberate choice: the event role's specification does not require a primary key, so a surrogate key was evaluated and rejected in favor of a composite key built from the columns already present. The composite key still enforces a reasonable invariant — the same renter cannot log two viewings of the same property at the exact same timestamp — without adding an extra column purely for identification.

Listing_amenities, the junction table, uses a composite primary key of (property_id, amenity_id), as required by the spec. This correctly allows one property to have many amenities and one amenity to belong to many properties, while preventing the same property-amenity pairing from being duplicated.

ON DELETE behaviors. The four foreign keys were each evaluated individually based on what should happen to dependent data when the referenced row disappears, rather than applying one rule uniformly:

viewings.renter_id → renters.renter_id uses RESTRICT. The event table's numeric metric (duration_min) is meant to be aggregated over time (e.g., total or average viewing duration). Cascading a renter's deletion would silently remove their viewing history and shrink these aggregate statistics, distorting analysis. RESTRICT forces an explicit decision (archiving or reassigning viewings) before a renter can be removed, protecting data integrity.

viewings.property_id → properties.property_id uses CASCADE. Once a property is gone, its viewing history no longer serves an ongoing analytical purpose, so removing it along with the property keeps the database clean without manual cleanup.

listing_amenities.property_id → properties.property_id and listing_amenities.amenity_id → amenities.amenity_id both use CASCADE. In both cases, deleting the parent (a property or an amenity) makes the corresponding link row meaningless — there is nothing left for it to associate. CASCADE only removes the link row itself, never the amenity or property record on the other side of the relationship.

Application-level vs. schema-level rules. Constraints enforceable by the schema (primary keys, foreign keys, NOT NULL, data types) were enforced there rather than left to the application, since database-level constraints apply universally regardless of which application code writes to the table, and catch errors earlier. Business rules that don't map to relational constraints (e.g., preventing a renter from viewing the same property twice within one hour) were intentionally left out of scope for this schema, as they depend on time-based logic better suited to the application layer.

# Reflection

One decision a different designer could reasonably have made differently is the primary key for the viewings table. The event role's specification does not require a primary key, so I chose a composite key over (renter_id, property_id, viewed_at) rather than adding a surrogate viewing_id column.

A different designer might prefer the surrogate key approach, since it is the more common convention for high-volume fact tables and would make it trivial to reference an individual viewing row from elsewhere in the system if a future feature required it (e.g., a "flag this viewing" feature).

I chose the composite key because this platform's read and write patterns center on aggregation, not individual-row lookups. Queries will ask "how many times was this property viewed" or "what is the average viewing duration," not "show me viewing #4529." A composite key avoids an unnecessary column while still preventing a narrow but real anomaly: duplicate identical viewing entries. If the platform later needed to reference individual viewings directly, migrating to a surrogate key remains straightforward, so the current choice does not close off that option permanently.
