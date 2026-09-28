Relation Schemas (Unit 1, updated in Unit 2 to match schema.sql)

actor (renters)

renter_id: INTEGER GENERATED ALWAYS AS IDENTITY (whole numbers, system-generated), primary key
first_name: VARCHAR(25) NOT NULL (text, up to 25 characters)
last_name: VARCHAR(25) NOT NULL (text, up to 25 characters)
Primary key: renter_id

producer (properties)

property_id: INTEGER GENERATED ALWAYS AS IDENTITY (whole numbers, system-generated), primary key
street: VARCHAR(100) NOT NULL (text, up to 100 characters)
city: VARCHAR(50) NOT NULL (text, up to 50 characters)
state: VARCHAR(2) NOT NULL (text, 2 characters)
zip: VARCHAR(10) NOT NULL (text, up to 10 characters)
is_available: BOOLEAN NOT NULL (true or false)
per_month_cost: NUMERIC(10,2) NOT NULL (decimal, 0 or greater)
num_bedrooms: INTEGER NOT NULL (whole number, 0 or greater)
num_bathrooms: INTEGER NOT NULL (whole number, 0 or greater)
size: INTEGER NOT NULL (whole number, 0 or greater)
floors: INTEGER NOT NULL (whole number, 0 or greater)
property_type: VARCHAR(50) NOT NULL (one of Apartment, House, Studio, Condo)
Primary key: property_id

event (viewings)

renter_id: INTEGER NOT NULL (foreign key to renters.renter_id)
property_id: INTEGER NOT NULL (foreign key to properties.property_id)
viewed_at: TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP (valid date and time)
duration_min: INTEGER NOT NULL (whole minutes, greater than 0)
Primary key: composite (renter_id, property_id, viewed_at)

catalog (amenities)

amenity_id: INTEGER GENERATED ALWAYS AS IDENTITY (whole numbers, system-generated), primary key
amenity_name: VARCHAR(100) NOT NULL (text, up to 100 characters)
Primary key: amenity_id

junction (listing_amenities)

property_id: INTEGER NOT NULL (foreign key to properties.property_id)
amenity_id: INTEGER NOT NULL (foreign key to amenities.amenity_id)
Primary key: composite (property_id, amenity_id)
