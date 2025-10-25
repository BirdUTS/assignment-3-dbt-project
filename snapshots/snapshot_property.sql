{% snapshot snapshot_property %}

{{
    config(
      target_schema='silver',
      unique_key='listing_id',
      strategy='timestamp',
      updated_at='scraped_date',
      invalidate_hard_deletes=True
    )
}}

-- =============================================================================
-- Snapshot: Property Dimension (SCD Type 2)
-- =============================================================================
-- Captures historical changes to property attributes over time
-- Tracks property_type, room_type, and accommodates changes
-- =============================================================================

SELECT DISTINCT
    listing_id,
    property_type,
    room_type,
    accommodates,
    listing_neighbourhood,
    scraped_date
FROM {{ ref('silver_listings') }}
WHERE listing_id IS NOT NULL

{% endsnapshot %}

