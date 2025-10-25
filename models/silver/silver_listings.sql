{{
    config(
        materialized='table',
        schema='silver'
    )
}}

-- ============================================================================= 
-- Silver Layer: Cleaned Airbnb Listings
-- =============================================================================
-- This model cleans and standardizes the raw Airbnb listings data from bronze
-- Transformations:
-- - Standardize column naming conventions
-- - Parse dates correctly
-- - Clean text fields (trim, proper case)
-- - Convert data types appropriately
-- - Handle nulls and missing values
-- =============================================================================

WITH source AS (
    SELECT * FROM {{ source('bronze', 'raw_airbnb_listings') }}
),

cleaned AS (
    SELECT
        -- IDs
        listing_id::BIGINT AS listing_id,
        scrape_id::BIGINT AS scrape_id,
        
        -- Dates
        TO_DATE(scraped_date, 'YYYY-MM-DD') AS scraped_date,
        
        -- Host information
        host_id::BIGINT AS host_id,
        TRIM(host_name) AS host_name,
        TO_DATE(host_since, 'YYYY-MM-DD') AS host_since,
        LOWER(TRIM(host_is_superhost)) = 't' AS host_is_superhost,
        TRIM(INITCAP(host_neighbourhood)) AS host_neighbourhood,
        
        -- Location
        TRIM(INITCAP(listing_neighbourhood)) AS listing_neighbourhood,
        
        -- Property details
        TRIM(property_type) AS property_type,
        TRIM(room_type) AS room_type,
        accommodates::INTEGER AS accommodates,
        
        -- Pricing
        CASE 
            WHEN price ~ '^[$]'  -- If starts with $
            THEN REPLACE(REPLACE(price, '$', ''), ',', '')::DECIMAL(10,2)
            ELSE price::DECIMAL(10,2)
        END AS price,
        
        -- Availability
        LOWER(TRIM(has_availability)) = 't' AS has_availability,
        availability_30::INTEGER AS availability_30,
        
        -- Reviews
        number_of_reviews::INTEGER AS number_of_reviews,
        CASE 
            WHEN review_scores_rating = '' THEN NULL
            ELSE review_scores_rating::DECIMAL(3,2)
        END AS review_scores_rating,
        CASE 
            WHEN review_scores_accuracy = '' THEN NULL
            ELSE review_scores_accuracy::DECIMAL(3,2)
        END AS review_scores_accuracy,
        CASE 
            WHEN review_scores_cleanliness = '' THEN NULL
            ELSE review_scores_cleanliness::DECIMAL(3,2)
        END AS review_scores_cleanliness,
        CASE 
            WHEN review_scores_checkin = '' THEN NULL
            ELSE review_scores_checkin::DECIMAL(3,2)
        END AS review_scores_checkin,
        CASE 
            WHEN review_scores_communication = '' THEN NULL
            ELSE review_scores_communication::DECIMAL(3,2)
        END AS review_scores_communication,
        CASE 
            WHEN review_scores_value = '' THEN NULL
            ELSE review_scores_value::DECIMAL(3,2)
        END AS review_scores_value,
        
        -- Metadata
        CURRENT_TIMESTAMP AS dbt_loaded_at
        
    FROM source
)

SELECT * FROM cleaned

