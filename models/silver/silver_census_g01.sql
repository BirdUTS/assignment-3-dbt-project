{{
    config(
        materialized='table',
        schema='silver'
    )
}}

-- =============================================================================
-- Silver Layer: Cleaned Census G01 Data
-- =============================================================================

WITH source AS (
    SELECT * FROM {{ source('bronze', 'raw_census_g01') }}
),

cleaned AS (
    SELECT
        -- Remove 'LGA' prefix from code
        REPLACE(lga_code_2016, 'LGA', '')::VARCHAR AS lga_code,
        
        -- Population totals
        tot_p_m::INTEGER AS total_population_male,
        tot_p_f::INTEGER AS total_population_female,
        tot_p_p::INTEGER AS total_population_persons,
        
        -- Age groups - convert to integers
        age_0_4_yr_p::INTEGER AS age_0_4_years,
        age_5_14_yr_p::INTEGER AS age_5_14_years,
        age_15_19_yr_p::INTEGER AS age_15_19_years,
        age_20_24_yr_p::INTEGER AS age_20_24_years,
        age_25_34_yr_p::INTEGER AS age_25_34_years,
        age_35_44_yr_p::INTEGER AS age_35_44_years,
        age_45_54_yr_p::INTEGER AS age_45_54_years,
        age_55_64_yr_p::INTEGER AS age_55_64_years,
        age_65_74_yr_p::INTEGER AS age_65_74_years,
        age_75_84_yr_p::INTEGER AS age_75_84_years,
        age_85ov_p::INTEGER AS age_85_over_years,
        
        -- Indigenous population
        indigenous_p_tot_p::INTEGER AS indigenous_population,
        
        -- Birthplace
        birthplace_australia_p::INTEGER AS birthplace_australia,
        birthplace_elsewhere_p::INTEGER AS birthplace_elsewhere,
        
        -- Language
        lang_spoken_home_eng_only_p::INTEGER AS language_english_only,
        lang_spoken_home_oth_lang_p::INTEGER AS language_other,
        
        -- Citizenship
        australian_citizen_p::INTEGER AS australian_citizens,
        
        -- Education attendance
        age_psns_att_edu_inst_15_19_p::INTEGER AS education_attendance_15_19,
        age_psns_att_edu_inst_20_24_p::INTEGER AS education_attendance_20_24,
        age_psns_att_edu_inst_25_ov_p::INTEGER AS education_attendance_25_over,
        
        -- Education completion
        high_yr_schl_comp_yr_12_eq_p::INTEGER AS completed_year_12,
        high_yr_schl_comp_yr_11_eq_p::INTEGER AS completed_year_11,
        high_yr_schl_comp_yr_10_eq_p::INTEGER AS completed_year_10,
        
        -- Dwelling
        count_psns_occ_priv_dwgs_p::INTEGER AS persons_in_private_dwellings,
        count_persons_other_dwgs_p::INTEGER AS persons_in_other_dwellings,
        
        CURRENT_TIMESTAMP AS dbt_loaded_at
        
    FROM source
)

SELECT * FROM cleaned

