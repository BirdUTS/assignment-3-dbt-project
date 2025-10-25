{{
    config(
        materialized='view',
        schema='datamart'
    )
}}

-- =============================================================================
-- Datamart: Host Neighbourhood Analysis
-- =============================================================================
-- Provides data per host_neighbourhood_lga and month/year
-- Maps host_neighbourhood to LGA for analysis
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

suburb_dim AS (
    SELECT * FROM {{ ref('dim_suburb') }}
),

lga_dim AS (
    SELECT * FROM {{ ref('dim_lga') }}
),

-- Map host_neighbourhood to LGA via suburb mapping
host_with_lga AS (
    SELECT DISTINCT
        h.host_id,
        h.host_neighbourhood,
        COALESCE(l.lga_name, 'Unknown') AS host_neighbourhood_lga,
        h.host_key,
        h.valid_from,
        h.valid_to
    FROM host_dim h
    LEFT JOIN suburb_dim s 
        ON UPPER(h.host_neighbourhood) = s.suburb_name
    LEFT JOIN lga_dim l 
        ON s.lga_code = l.lga_code
),

-- Aggregate by host LGA and month
aggregated AS (
    SELECT
        hl.host_neighbourhood_lga,
        d.year_month,
        d.year,
        d.month,
        
        -- Number of distinct hosts
        COUNT(DISTINCT f.host_id) AS distinct_hosts,
        
        -- Total estimated revenue for active listings
        ROUND(SUM(CASE WHEN f.has_availability THEN f.estimated_revenue END), 2) AS total_revenue_active,
        
        -- Count of active listings
        COUNT(DISTINCT CASE WHEN f.has_availability THEN f.listing_id END) AS active_listings,
        
        -- Estimated revenue per active listing
        ROUND(
            SUM(CASE WHEN f.has_availability THEN f.estimated_revenue END) / 
            NULLIF(COUNT(DISTINCT CASE WHEN f.has_availability THEN f.listing_id END), 0),
            2
        ) AS revenue_per_active_listing,
        
        -- Estimated revenue per host
        ROUND(
            SUM(CASE WHEN f.has_availability THEN f.estimated_revenue END) / 
            NULLIF(COUNT(DISTINCT f.host_id), 0),
            2
        ) AS revenue_per_host
        
    FROM fact f
    INNER JOIN host_with_lga hl 
        ON f.host_key = hl.host_key
    INNER JOIN date_dim d 
        ON f.date_key = d.date_key
    GROUP BY hl.host_neighbourhood_lga, d.year_month, d.year, d.month
)

SELECT
    host_neighbourhood_lga,
    year_month,
    year,
    month,
    distinct_hosts,
    revenue_per_active_listing,
    revenue_per_host
FROM aggregated
ORDER BY host_neighbourhood_lga, year, month

