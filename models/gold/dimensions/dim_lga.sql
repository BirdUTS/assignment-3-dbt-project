{{
    config(
        materialized='table',
        schema='gold'
    )
}}

-- =============================================================================
-- Gold Layer: LGA (Local Government Area) Dimension
-- =============================================================================

WITH lga AS (
    SELECT * FROM {{ ref('silver_lga') }}
),

dim_lga AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['lga_code']) }} AS lga_key,
        lga_code,
        lga_name
    FROM lga
    WHERE lga_code IS NOT NULL
)

SELECT * FROM dim_lga

