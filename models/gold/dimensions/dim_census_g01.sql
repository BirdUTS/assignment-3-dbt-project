{{
    config(
        materialized='table',
        schema='gold'
    )
}}

-- =============================================================================
-- Gold Layer: Census G01 Reference Data
-- =============================================================================
-- Static reference table - no SCD2 needed (census data is point-in-time)
-- =============================================================================

WITH census AS (
    SELECT * FROM {{ ref('silver_census_g01') }}
),

dim_census_g01 AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['lga_code']) }} AS census_g01_key,
        lga_code,
        total_population_persons,
        total_population_male,
        total_population_female,
        age_0_4_years,
        age_5_14_years,
        age_15_19_years,
        age_20_24_years,
        age_25_34_years,
        age_35_44_years,
        age_45_54_years,
        age_55_64_years,
        age_65_74_years,
        age_75_84_years,
        age_85_over_years,
        indigenous_population,
        birthplace_australia,
        birthplace_elsewhere,
        language_english_only,
        language_other,
        australian_citizens,
        education_attendance_15_19,
        education_attendance_20_24,
        education_attendance_25_over,
        completed_year_12,
        completed_year_11,
        completed_year_10,
        persons_in_private_dwellings,
        persons_in_other_dwellings
    FROM census
)

SELECT * FROM dim_census_g01

