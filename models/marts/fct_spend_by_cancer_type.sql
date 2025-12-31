{{ config(
    materialized='table',
    tags=['marts']
    )
}}


WITH totals AS (
    SELECT
        'total' AS aggregation_level,
        NULL AS cancer_type,
        NULL AS encounter_type,
        COUNT(DISTINCT person_id) AS n_persons,
        COUNT(DISTINCT claim_id) AS n_claims,
        ROUND(SUM(insurer_paid_amount),0) AS insurer_paid_amount,
        ROUND(SUM(patient_paid_amount),0) AS patient_paid_amount,
        ROUND(SUM(total_paid_amount),0) AS total_paid_amount,
        ROUND(SUM(total_paid_amount)/COUNT(DISTINCT person_id),0) AS avg_total_per_person,
        ROUND(SUM(total_paid_amount)/COUNT(DISTINCT claim_id),0) AS avg_total_per_claim
    FROM {{ ref('int_active_condition_claims') }}
    GROUP BY ALL
),

cancer_types AS (
    SELECT
        'cancer_type' AS aggregation_level,
        cancer_type,
        NULL AS encounter_type,
        COUNT(DISTINCT person_id) AS n_persons,
        COUNT(DISTINCT claim_id) AS n_claims,
        ROUND(SUM(insurer_paid_amount),0) AS insurer_paid_amount,
        ROUND(SUM(patient_paid_amount),0) AS patient_paid_amount,
        ROUND(SUM(total_paid_amount),0) AS total_paid_amount,
        ROUND(SUM(total_paid_amount)/COUNT(DISTINCT person_id),0) AS avg_total_per_person,
        ROUND(SUM(total_paid_amount)/COUNT(DISTINCT claim_id),0) AS avg_total_per_claim
    FROM {{ ref('int_active_condition_claims') }}
    GROUP BY ALL
),

encounter_types AS (
    SELECT
        'encounter_type' AS aggregation_level,
        NULL AS cancer_type,
        encounter_type,
        COUNT(DISTINCT person_id) AS n_persons,
        COUNT(DISTINCT claim_id) AS n_claims,
        ROUND(SUM(insurer_paid_amount),0) AS insurer_paid_amount,
        ROUND(SUM(patient_paid_amount),0) AS patient_paid_amount,
        ROUND(SUM(total_paid_amount),0) AS total_paid_amount,
        ROUND(SUM(total_paid_amount)/COUNT(DISTINCT person_id),0) AS avg_total_per_person,
        ROUND(SUM(total_paid_amount)/COUNT(DISTINCT claim_id),0) AS avg_total_per_claim
    FROM {{ ref('int_active_condition_claims') }}
    GROUP BY ALL
)

SELECT * FROM totals
UNION ALL
SELECT * FROM cancer_types
UNION ALL
SELECT * FROM encounter_types
ORDER BY 8 DESC