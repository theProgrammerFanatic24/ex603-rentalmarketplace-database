actor (renters)
- renter_id — INTEGER (auto-increment, whole positive numbers), primary key
- renter_full_name — VARCHAR(255) (text, up to 255 characters)

producer (properties)
- property_id — INTEGER (auto-increment, whole positive numbers), primary key
- property_address — VARCHAR(255) (text, up to 255 characters)
- is_available — BOOLEAN (true/false)
- per_month_cost — FLOAT (positive decimal numbers)
- num_bedrooms — INTEGER (whole non-negative numbers)
- num_bathrooms — INTEGER (whole non-negative numbers)
- size — INTEGER (whole positive numbers, square feet)
- floors — INTEGER (whole positive numbers)
- property_type — VARCHAR (text, e.g. "Apartment", "House", "Studio", "Condo")

event (viewings)
- renter_id — INTEGER, foreign key → renters
- property_id — INTEGER, foreign key → properties
- viewed_at — TIMESTAMP (valid calendar date and time)
- duration_min — FLOAT (positive decimal numbers, minutes)
- Primary key: composite (renter_id, property_id, viewed_at)

catalog (amenities)
- amenity_id — INTEGER (auto-increment, whole positive numbers), primary key
- amenity_name — VARCHAR(100) (text, up to 100 characters)

junction (listing_amenities)
- property_id — INTEGER, foreign key → properties
- amenity_id — INTEGER, foreign key → amenities
- Primary key: composite (property_id, amenity_id)
