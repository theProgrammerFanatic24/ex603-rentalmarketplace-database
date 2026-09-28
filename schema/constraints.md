Integrity Constraints (Unit 1, updated in Unit 2 to match schema.sql)

Primary keys

renters: renter_id
properties: property_id
amenities: amenity_id
viewings: composite (renter_id, property_id, viewed_at)
listing_amenities: composite (property_id, amenity_id)

Foreign keys and ON DELETE behavior

fk_viewings_renter: viewings.renter_id references renters.renter_id
ON DELETE RESTRICT
Justification: The duration_min metric is aggregated over time. Deleting a renter with CASCADE would silently remove their viewing history and shrink those statistics. RESTRICT blocks the deletion while viewings exist, forcing an explicit decision. SET NULL is not possible because renter_id is part of the primary key.

fk_viewings_properties: viewings.property_id references properties.property_id
ON DELETE CASCADE
Justification: Once a property is deleted, its viewing history no longer serves an ongoing purpose, so the viewings are removed with it.

fk_listings_property: listing_amenities.property_id references properties.property_id
ON DELETE CASCADE
Justification: A deleted property has no amenities to link, so only the link rows are removed, never the amenities themselves.

fk_listings_amenities: listing_amenities.amenity_id references amenities.amenity_id
ON DELETE CASCADE
Justification: A deleted amenity makes every link to it meaningless, so only the link rows are removed, never the properties.

NOT NULL

Every column in every table is NOT NULL. Primary key columns are NOT NULL automatically.

CHECK constraints

chk_properties_cost_nonnegative: per_month_cost >= 0
chk_properties_bedrooms_nonnegative: num_bedrooms >= 0
chk_properties_bathrooms_nonnegative: num_bathrooms >= 0
chk_properties_size_nonnegative: size >= 0
chk_properties_floors_nonnegative: floors >= 0
chk_properties_type_valid: property_type IN ('Apartment', 'House', 'Studio', 'Condo')
chk_duration_min: duration_min > 0
