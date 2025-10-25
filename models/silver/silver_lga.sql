{{
    config(
        materialized='table',
        schema='silver'
    )
}}

-- =============================================================================
-- Silver Layer: LGA (Local Government Area) Mapping
-- =============================================================================

WITH lga_codes AS (
    SELECT * FROM {{ source('bronze', 'raw_lga_code_mapping') }}
),

lga_suburbs AS (
    SELECT * FROM {{ source('bronze', 'raw_lga_suburb_mapping') }}
),

cleaned_lga AS (
    SELECT DISTINCT
        lga_code::VARCHAR AS lga_code,
        TRIM(UPPER(lga_name)) AS lga_name
    FROM lga_codes
),

cleaned_suburbs AS (
    SELECT DISTINCT
        TRIM(UPPER(lga_name)) AS lga_name,
        TRIM(INITCAP(suburb_name)) AS suburb_name
    FROM lga_suburbs
),

-- Join LGA codes with suburbs
lga_with_suburbs AS (
    SELECT
        l.lga_code,
        l.lga_name,
        s.suburb_name,
        CURRENT_TIMESTAMP AS dbt_loaded_at
    FROM cleaned_lga l
    LEFT JOIN cleaned_suburbs s ON l.lga_name = s.lga_name
)

SELECT * FROM lga_with_suburbs

