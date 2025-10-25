{{
    config(
        materialized='table',
        schema='gold'
    )
}}

-- =============================================================================
-- Gold Layer: Date Dimension
-- =============================================================================
-- Generates a date dimension from May 2020 to April 2021 (assignment period)
-- =============================================================================

WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-05-01' as date)",
        end_date="cast('2021-05-01' as date)"
       )
    }}
),

dim_date AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['date_day']) }} AS date_key,
        date_day AS date,
        EXTRACT(YEAR FROM date_day) AS year,
        EXTRACT(MONTH FROM date_day) AS month,
        EXTRACT(DAY FROM date_day) AS day,
        TO_CHAR(date_day, 'Month') AS month_name,
        TO_CHAR(date_day, 'YYYY-MM') AS year_month,
        EXTRACT(QUARTER FROM date_day) AS quarter,
        EXTRACT(WEEK FROM date_day) AS week_of_year,
        EXTRACT(DOW FROM date_day) AS day_of_week,
        TO_CHAR(date_day, 'Day') AS day_name
    FROM date_spine
)

SELECT * FROM dim_date

