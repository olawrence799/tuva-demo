{{ config(
    materialized='view',
    tags=['staging', 'encounters']
    )
}}

WITH cancer_persons AS (
    SELECT DISTINCT person_id
    FROM {{ ref('stg_conditions') }}
)

SELECT
    encounter_id,
    c.person_id,
    encounter_type,
    encounter_group,
    encounter_start_date,
    encounter_end_date,
    facility_type,
    observation_flag,
    lab_flag,
    ed_flag,
    primary_diagnosis_code_type,
    primary_diagnosis_code,
    primary_diagnosis_description,
    paid_amount AS insurer_paid_amount,
    allowed_amount AS total_paid_amount,
    allowed_amount - paid_amount AS patient_paid_amount,
    claim_count
FROM {{ ref('core__encounter') }} c
INNER JOIN cancer_persons
ON cancer_persons.person_id = c.person_id
-- WHERE LOWER(TRIM(primary_diagnosis_code_type)) = 'icd-10-cm'
-- AND UPPER(TRIM(primary_diagnosis_code)) LIKE 'C%'
-- AND LEN(primary_diagnosis_code) = 3