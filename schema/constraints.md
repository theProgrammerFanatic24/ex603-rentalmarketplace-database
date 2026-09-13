listing_amenities.property_id → properties.property_id
ON DELETE CASCADE
- Justification: when a property is deleted, it no longer has amenities to link, so the corresponding rows in listing_amenities are removed. This only deletes the link row, not the amenity itself in the amenities table.

listing_amenities.amenity_id → amenities.amenity_id
ON DELETE CASCADE
- Justification: when an amenity is deleted from the catalog, any property links to it become meaningless, so those link rows are removed. This only deletes the link row, not the property itself.

viewings.property_id → properties.property_id
ON DELETE CASCADE
- Justification: once a property is deleted, its viewing history no longer serves an ongoing analytical purpose, so its viewing records are removed along with it.

viewings.renter_id → renters.renter_id
ON DELETE RESTRICT
- Justification: the numeric metric duration_min is meant to be aggregated over time (total/average viewing duration). Cascading a renter's deletion would silently remove their viewing history and shrink these aggregate statistics. RESTRICT prevents deleting a renter while their viewing records still exist, forcing an explicit decision before removal and protecting the integrity of the aggregate stats.
