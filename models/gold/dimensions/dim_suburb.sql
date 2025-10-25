{{
    config(
        materialized='table',
        schema='gold'
    )
}}

-- =============================================================================
-- Gold Layer: Suburb Dimension
-- =============================================================================

WITH lga AS (
    SELECT * FROM {{ ref('silver_lga') }}
),

dim_suburb AS (
    SELECT DISTINCT
        {{dbt_utils.generate_surrogate_key(['suburb_name', 'lga_code'])}} AS suburb_key,
        suburb_name,
        lga_code,
        lga_name
    FROM lga
    WHERE suburb_name IS NOT NULL
)

SELECT * FROM dim_suburb

