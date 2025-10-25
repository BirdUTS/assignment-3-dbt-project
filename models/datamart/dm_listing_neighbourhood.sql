{{
    config(
        materialized='view',
        schema='datamart'
    )
}}

-- =============================================================================
-- Datamart: Listing Neighbourhood Analysis
-- =============================================================================
-- Provides insights per listing_neighbourhood and month/year
-- Uses SCD2 logic to show correct dimension values at the time
-- =============================================================================

WITH fact AS (
    SELECT * FROM {{ ref('fact_listings') }}
),

property_dim AS (
    SELECT * FROM {{ ref('dim_property') }}
),

host_dim AS (
    SELECT * FROM {{ ref('dim_host') }}
),

date_dim AS (
    SELECT * FROM {{ ref('dim_date') }}
),

-- Aggregate by neighbourhood and month
current_month AS (
    SELECT
        p.listing_neighbourhood,
        d.year_month,
        d.year,
        d.month,
        
        -- Total listings
        COUNT(DISTINCT f.listing_id) AS total_listings,
        
        -- Active listings (has_availability = true)
        COUNT(DISTINCT CASE WHEN f.has_availability THEN f.listing_id END) AS active_listings,
        
        -- Active listings rate
        ROUND(
            100.0 * COUNT(DISTINCT CASE WHEN f.has_availability THEN f.listing_id END) / 
            NULLIF(COUNT(DISTINCT f.listing_id), 0), 
            2
        ) AS active_listings_rate,
        
        -- Price metrics for active listings
        MIN(CASE WHEN f.has_availability THEN f.price END) AS min_price_active,
        MAX(CASE WHEN f.has_availability THEN f.price END) AS max_price_active,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CASE WHEN f.has_availability THEN f.price END) AS median_price_active,
        ROUND(AVG(CASE WHEN f.has_availability THEN f.price END), 2) AS avg_price_active,
        
        -- Distinct hosts
        COUNT(DISTINCT f.host_id) AS distinct_hosts,
        
        -- Superhost rate
        ROUND(
            100.0 * COUNT(DISTINCT CASE WHEN h.host_is_superhost THEN f.host_id END) / 
            NULLIF(COUNT(DISTINCT f.host_id), 0),
            2
        ) AS superhost_rate,
        
        -- Average review score for active listings
        ROUND(AVG(CASE WHEN f.has_availability THEN f.review_scores_rating END), 2) AS avg_review_score_active,
        
        -- Total stays and revenue
        SUM(f.number_of_stays) AS total_stays,
        ROUND(SUM(f.estimated_revenue), 2) AS total_revenue,
        ROUND(
            SUM(f.estimated_revenue) / 
            NULLIF(COUNT(DISTINCT CASE WHEN f.has_availability THEN f.listing_id END), 0),
            2
        ) AS avg_revenue_per_active_listing
        
    FROM fact f
    INNER JOIN property_dim p ON f.property_key = p.property_key
    INNER JOIN host_dim h ON f.host_key = h.host_key
    INNER JOIN date_dim d ON f.date_key = d.date_key
    GROUP BY p.listing_neighbourhood, d.year_month, d.year, d.month
),

-- Calculate percentage changes month-over-month
with_changes AS (
    SELECT
        *,
        -- Percentage change in active listings
        ROUND(
            100.0 * (active_listings - LAG(active_listings) OVER (
                PARTITION BY listing_neighbourhood 
                ORDER BY year, month
            )) / NULLIF(LAG(active_listings) OVER (
                PARTITION BY listing_neighbourhood 
                ORDER BY year, month
            ), 0),
            2
        ) AS pct_change_active_listings,
        
        -- Percentage change in inactive listings
        ROUND(
            100.0 * ((total_listings - active_listings) - LAG(total_listings - active_listings) OVER (
                PARTITION BY listing_neighbourhood 
                ORDER BY year, month
            )) / NULLIF(LAG(total_listings - active_listings) OVER (
                PARTITION BY listing_neighbourhood 
                ORDER BY year, month
            ), 0),
            2
        ) AS pct_change_inactive_listings
        
    FROM current_month
)

SELECT
    listing_neighbourhood,
    year_month,
    year,
    month,
    total_listings,
    active_listings,
    active_listings_rate,
    min_price_active,
    max_price_active,
    median_price_active,
    avg_price_active,
    distinct_hosts,
    superhost_rate,
    avg_review_score_active,
    pct_change_active_listings,
    pct_change_inactive_listings,
    total_stays,
    avg_revenue_per_active_listing
FROM with_changes
ORDER BY listing_neighbourhood, year, month

