{{
    config(
        materialized='table',
        schema='gold'
    )
}}

-- =============================================================================
-- Gold Layer: Census G02 Reference Data
-- =============================================================================
-- Static reference table - no SCD2 needed
-- =============================================================================

WITH census AS (
    SELECT * FROM {{ ref('silver_census_g02') }}
),

dim_census_g02 AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['lga_code']) }} AS census_g02_key,
        lga_code,
        median_age,
        average_household_size,
        median_mortgage_monthly,
        median_rent_weekly,
        median_personal_income_weekly,
        median_family_income_weekly,
        median_household_income_weekly,
        average_persons_per_bedroom
    FROM census
)

SELECT * FROM dim_census_g02

