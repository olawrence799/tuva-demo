{{ config(
    materialized='view',
    tags=['staging', 'conditions']
    )
}}

WITH include_conditions AS (
    SELECT
        condition_id,
        person_id,
        encounter_id,
        claim_id,
        recorded_date,
        normalized_code_type,
        normalized_code,
        normalized_description,
        CASE
            WHEN normalized_code BETWEEN 'C00' AND 'C14'
                OR normalized_code BETWEEN 'C30' AND 'C32'
                THEN 'Head & Neck'
            WHEN normalized_code BETWEEN 'C15' AND 'C16'
                THEN 'Esophageal & Gastric'
            WHEN normalized_code BETWEEN 'C17' AND 'C21'
                THEN 'Colorectal & Anal'
            WHEN normalized_code BETWEEN 'C22' AND 'C25'
                THEN 'Hepatobiliary & Pancreatic'
            WHEN normalized_code BETWEEN 'C33' AND 'C34'
                OR normalized_code BETWEEN 'C37' AND 'C39'
                THEN 'Lung & Thoracic'
            WHEN normalized_code = 'C50'
                THEN 'Breast'
            WHEN normalized_code BETWEEN 'C51' AND 'C58'
                THEN 'Gynecologic'
            WHEN normalized_code = 'C61'
                THEN 'Prostate'
            WHEN normalized_code IN ('C60') OR normalized_code BETWEEN 'C62' AND 'C68'
                THEN 'Other Genitourinary'
            WHEN normalized_code = 'C43'
                THEN 'Melanoma'
            WHEN normalized_code BETWEEN 'C70' AND 'C72'
                OR normalized_code IN ('C751','C752','C753')
                THEN 'CNS'
            WHEN normalized_code BETWEEN 'C81' AND 'C91'
                OR normalized_code IN ('C88','C90')
                THEN 'Hematologic - Lymphoid'
            WHEN normalized_code BETWEEN 'C92' AND 'C96'
                THEN 'Hematologic - Myeloid'
            WHEN normalized_code BETWEEN 'C77' AND 'C80'
                THEN 'Metastatic / Unknown Primary'
            ELSE 'Other / Unclassified'
        END AS cancer_type
    FROM {{ ref('core__condition') }}
    WHERE LOWER(TRIM(normalized_code_type)) = 'icd-10-cm'
    AND UPPER(TRIM(normalized_code)) LIKE 'C%'
    -- AND LEN(normalized_code) = 3
),

exclude_conditions AS (
    SELECT DISTINCT
        person_id
    FROM {{ ref('core__condition') }}
    WHERE LOWER(TRIM(normalized_code_type)) = 'icd-10-cm'
    AND UPPER(TRIM(normalized_code)) LIKE 'Z85%'
)

SELECT
    ic.*
FROM include_conditions ic
LEFT JOIN exclude_conditions ec
ON ic.person_id = ec.person_id
WHERE ec.person_id IS NULL