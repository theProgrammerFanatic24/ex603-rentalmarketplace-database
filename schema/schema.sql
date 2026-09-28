-- =================================================================
-- EX 603 Assignment 2 — schema.sql
-- Theme: Rental Marketplace
-- Author: Intisar Ratul
-- Target: PostgreSQL 14+
-- =================================================================
-- Reset. Reverse creation order, so no dependency blocks a drop.

DROP TABLE IF EXISTS listing_amenities CASCADE;
DROP TABLE IF EXISTS viewings CASCADE;
DROP TABLE IF EXISTS amenities CASCADE;
DROP TABLE IF EXISTS properties CASCADE;
DROP TABLE IF EXISTS renters CASCADE;

-- ----------------------------------------------------------------
-- 1. renters — first, because it references no other table.
-- ----------------------------------------------------------------
CREATE TABLE renters(
    renter_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name varchar(25) NOT NULL,
    last_name varchar(25) NOT NULL
);
-- ----------------------------------------------------------------
-- 2. properties — second, because it references no other table.
-- ----------------------------------------------------------------
CREATE TABLE properties(
    property_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    street varchar(100) NOT NULL,
    city varchar(50) NOT NULL,
    state varchar(2) NOT NULL,
    zip varchar(10) NOT NULL,
    is_available BOOLEAN NOT NULL,
    per_month_cost NUMERIC(10,2) NOT NULL,
    num_bedrooms INTEGER NOT NULL,
    num_bathrooms INTEGER NOT NULL,
    size INTEGER NOT NULL,
    floors INTEGER NOT NULL,
    property_type VARCHAR(50) NOT NULL,
    CONSTRAINT chk_properties_cost_nonnegative
    CHECK (per_month_cost >= 0),
    CONSTRAINT chk_properties_bedrooms_nonnegative
    CHECK (num_bedrooms >= 0),
    CONSTRAINT chk_properties_bathrooms_nonnegative
    CHECK (num_bathrooms >= 0),
    CONSTRAINT chk_properties_size_nonnegative
    CHECK (size >= 0),
    CONSTRAINT chk_properties_floors_nonnegative
    CHECK (floors >= 0),
    CONSTRAINT chk_properties_type_valid
    CHECK (property_type IN ('Apartment', 'House', 'Studio', 'Condo'))
);
-- ----------------------------------------------------------------
-- 3. amenities — third, because it references no other table.
-- ----------------------------------------------------------------
CREATE TABLE amenities(
  amenity_id INTEGER GENERATED ALWAYS AS Identity PRIMARY KEY,
  amenity_name VARCHAR(100) NOT NULL
);
-- ----------------------------------------------------------------
-- 4. viewings — fourth, because it references renters and properties,
--    which must already exist.
-- ----------------------------------------------------------------

CREATE TABLE viewings(
    renter_id INTEGER NOT NULL,
    property_id INTEGER NOT NULL,
    viewed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    duration_min INTEGER NOT NULL,
    CONSTRAINT pk_viewings PRIMARY KEY (renter_id,property_id,viewed_at),
    CONSTRAINT fk_viewings_renter
    FOREIGN KEY (renter_id) references renters(renter_id) ON DELETE Restrict,
    CONSTRAINT fk_viewings_properties
    Foreign Key (property_id)references properties(property_id) ON DELETE CASCADE ,
    CONSTRAINT chk_duration_min
    CHECK (duration_min > 0)
);
-- ----------------------------------------------------------------
-- 5. listing_amenities — last, because it references properties and
--    amenities, which must already exist.
-- ----------------------------------------------------------------
CREATE TABLE listing_amenities
(
    property_id INTEGER NOT NULL,
    amenity_id INTEGER NOT NULL,
    CONSTRAINT pk_property_amenity PRIMARY KEY (property_id,amenity_id),
    CONSTRAINT fk_listings_property
    Foreign Key(property_id) references properties(property_id) ON DELETE CASCADE,
    CONSTRAINT fk_listings_amenities
    FOREIGN KEY(amenity_id) references amenities(amenity_id) ON DELETE CASCADE

);
