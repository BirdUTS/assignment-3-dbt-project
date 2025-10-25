{{
    config(
        materialized='table',
        schema='gold'
    )
}}

-- =============================================================================
-- Gold Layer: Host Dimension (SCD Type 2)
-- =============================================================================
-- Builds dimension table from host snapshot with SCD2 validity periods
-- =============================================================================

WITH snapshot AS (
    SELECT * FROM {{ ref('snapshot_host') }}
),

dim_host AS (
    SELECT
        -- Surrogate key (dbt snapshot adds dbt_scd_id automatically)
        {{ dbt_utils.generate_surrogate_key(['host_id', 'dbt_valid_from']) }} AS host_key,
        
        -- Natural key
        host_id,
        
        -- Attributes
        host_name,
        host_since,
        host_is_superhost,
        host_neighbourhood,
        
        -- SCD2 metadata (added by dbt snapshot)
        dbt_valid_from AS valid_from,
        dbt_valid_to AS valid_to,
        CASE WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE END AS is_current
        
    FROM snapshot
)

SELECT * FROM dim_host

