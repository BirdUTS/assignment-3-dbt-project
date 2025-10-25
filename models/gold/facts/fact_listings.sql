{{
    config(
        materialized='table',
        schema='gold'
    )
}}

-- =============================================================================
-- Gold Layer: Fact Listings Table
-- =============================================================================
-- Fact table containing only IDs (foreign keys) and metrics
-- Uses SCD2 logic to join with dimension snapshots based on valid_from/valid_to
-- =============================================================================

WITH listings AS (
    SELECT * FROM {{ ref('silver_listings') }}
),

-- Get the correct version of host dimension for each listing date
host_dim AS (
    SELECT * FROM {{ ref('dim_host') }}
),

-- Get the correct version of property dimension for each listing date
property_dim AS (
    SELECT * FROM {{ ref('dim_property') }}
),

-- Get suburb and LGA dimensions
suburb_dim AS (
    SELECT * FROM {{ ref('dim_suburb') }}
),

date_dim AS (
    SELECT * FROM {{ ref('dim_date') }}
),

-- Join fact with dimensions using SCD2 logic
fact_listings AS (
    SELECT
        -- Surrogate key for fact table
        {{ dbt_utils.generate_surrogate_key(['l.listing_id', 'l.scraped_date']) }} AS fact_key,
        
        -- Foreign keys to dimensions (using SCD2 logic)
        h.host_key,
        p.property_key,
        s.suburb_key,
        d.date_key,
        
        -- Degenerate dimensions (IDs kept in fact for reference)
        l.listing_id,
        l.host_id,
        
        -- Metrics (measures)
        l.price,
        l.has_availability,
        l.availability_30,
        l.number_of_reviews,
        l.review_scores_rating,
        l.review_scores_accuracy,
        l.review_scores_cleanliness,
        l.review_scores_checkin,
        l.review_scores_communication,
        l.review_scores_value,
        
        -- Calculated metrics
        CASE 
            WHEN l.has_availability THEN (30 - l.availability_30) 
            ELSE 0 
        END AS number_of_stays,
        
        CASE 
            WHEN l.has_availability THEN (30 - l.availability_30) * l.price
            ELSE 0 
        END AS estimated_revenue,
        
        -- Date information
        l.scraped_date
        
    FROM listings l
    
    -- Join with host dimension using SCD2 logic (find valid version at scraped_date)
    INNER JOIN host_dim h 
        ON l.host_id = h.host_id
        AND l.scraped_date >= h.valid_from
        AND (l.scraped_date < h.valid_to OR h.valid_to IS NULL)
    
    -- Join with property dimension using SCD2 logic
    INNER JOIN property_dim p
        ON l.listing_id = p.listing_id
        AND l.scraped_date >= p.valid_from
        AND (l.scraped_date < p.valid_to OR p.valid_to IS NULL)
    
    -- Join with suburb dimension (non-SCD2)
    LEFT JOIN suburb_dim s
        ON UPPER(l.listing_neighbourhood) = s.suburb_name
    
    -- Join with date dimension
    INNER JOIN date_dim d
        ON l.scraped_date = d.date
)

SELECT * FROM fact_listings

