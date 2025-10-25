{% snapshot snapshot_host %}

{{
    config(
      target_schema='silver',
      unique_key='host_id',
      strategy='timestamp',
      updated_at='scraped_date',
      invalidate_hard_deletes=True
    )
}}

-- =============================================================================
-- Snapshot: Host Dimension (SCD Type 2)
-- =============================================================================
-- Captures historical changes to host attributes over time
-- Uses scraped_date as the timestamp for tracking changes
-- =============================================================================

SELECT DISTINCT
    host_id,
    host_name,
    host_since,
    host_is_superhost,
    host_neighbourhood,
    scraped_date
FROM {{ ref('silver_listings') }}
WHERE host_id IS NOT NULL

{% endsnapshot %}

