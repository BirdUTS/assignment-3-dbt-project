{{
    config(
        materialized='table',
        schema='gold'
    )
}}

-- =============================================================================
-- Gold Layer: Property Dimension (SCD Type 2)
-- =============================================================================

WITH snapshot AS (
    SELECT * FROM {{ ref('snapshot_property') }}
),

dim_property AS (
    SELECT
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['listing_id', 'dbt_valid_from']) }} AS property_key,
        
        -- Natural key
        listing_id,
        
        -- Attributes
        property_type,
        room_type,
        accommodates,
        
        -- SCD2 metadata
        dbt_valid_from AS valid_from,
        dbt_valid_to AS valid_to,
        CASE WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE END AS is_current
        
    FROM snapshot
)

SELECT * FROM dim_property

