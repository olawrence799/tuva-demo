{{ config(
    materialized='view',
    tags=['intermediate', 'active', 'claims']
    )
}}

WITH recent_encounters AS (
    SELECT DISTINCT person_id
    FROM {{ ref('stg_encounters') }}
    -- WHERE encounter_start_date >= CURRENT_DATE - INTERVAL '12 months'
),

active_patients AS (
    SELECT
        c.person_id,
        MAX(claim_start_date) AS last_claim_date
    FROM {{ ref('stg_claims') }} c
    INNER JOIN {{ ref('core__patient') }} p
    ON c.person_id = p.person_id
    INNER JOIN recent_encounters r
    ON c.person_id = r.person_id
    WHERE death_date IS NULL
    AND death_flag = 0
    GROUP BY 1
    -- HAVING last_claim_date >= CURRENT_DATE - INTERVAL '12 months'
),

active_patient_claims AS (
    SELECT
        ap.person_id,
        c.claim_id,
        COALESCE(t.cancer_type, 'Cancer Patient - Not Cancer Claim') AS cancer_type,
        encounter_type,
        encounter_group,
        service_category_1,
        insurer_paid_amount,
        patient_paid_amount,
        total_paid_amount
        -- coinsurance_amount,
        -- copayment_amount,
        -- deductible_amount,
        -- total_cost_amount
    FROM active_patients ap
    LEFT JOIN {{ ref('stg_claims') }} c
    ON ap.person_id = c.person_id
    LEFT JOIN {{ ref('stg_conditions') }} t
    ON ap.person_id = t.person_id AND c.claim_id = t.claim_id
)

SELECT * FROM active_patient_claims