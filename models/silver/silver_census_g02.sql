{{
    config(
        materialized='table',
        schema='silver'
    )
}}

-- =============================================================================
-- Silver Layer: Cleaned Census G02 Data  
-- =============================================================================

WITH source AS (
    SELECT * FROM {{ source('bronze', 'raw_census_g02') }}
),

cleaned AS (
    SELECT
        -- Remove 'LGA' prefix from code
        REPLACE(lga_code_2016, 'LGA', '')::VARCHAR AS lga_code,
        
        -- Demographics
        median_age_persons::INTEGER AS median_age,
        average_household_size::DECIMAL(3,2) AS average_household_size,
        
        -- Financial medians
        median_mortgage_repay_monthly::INTEGER AS median_mortgage_monthly,
        median_rent_weekly::INTEGER AS median_rent_weekly,
        median_tot_prsnl_inc_weekly::INTEGER AS median_personal_income_weekly,
        median_tot_fam_inc_weekly::INTEGER AS median_family_income_weekly,
        median_tot_hhd_inc_weekly::INTEGER AS median_household_income_weekly,
        
        -- Dwelling density
        average_num_psns_per_bedroom::DECIMAL(3,2) AS average_persons_per_bedroom,
        
        CURRENT_TIMESTAMP AS dbt_loaded_at
        
    FROM source
)

SELECT * FROM cleaned

