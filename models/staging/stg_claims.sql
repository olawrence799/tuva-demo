{{ config(
    materialized='view',
    tags=['staging', 'claims']
    )
}}

WITH cancer_persons AS (
    SELECT DISTINCT person_id
    FROM {{ ref('stg_conditions') }}
)

SELECT
    medical_claim_id,
    claim_id,
    claim_line_number,
    encounter_id,
    c.person_id,
    encounter_type,
    encounter_group,
    claim_start_date,
    claim_end_date,
    file_date,
    service_category_1,
    COALESCE(paid_amount, 0) AS insurer_paid_amount,
    COALESCE(allowed_amount, paid_amount, 0) AS total_paid_amount,
    COALESCE(allowed_amount, paid_amount, 0) - COALESCE(paid_amount, 0) AS patient_paid_amount
    -- coinsurance_amount,
    -- copayment_amount,
    -- deductible_amount,
    -- total_cost_amount
FROM {{ ref('core__medical_claim') }} c
INNER JOIN cancer_persons
ON cancer_persons.person_id = c.person_id