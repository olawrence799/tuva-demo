### Methodology
I chose to define "Cancer", and more specifically "active Cancer", by referencing the ICD-10-CM codes.

I first found the persons identified as having cancer conditions from 'core.condition', filtering for ICD-10-CM codes like 'C%' to capture codes C00.* - C96.*.

I then excluded persons identified with codes like 'Z85%'.

The persons list is further refined to only include patients who are still alive.

This list of persons served as the foundation for then finding all encounters and claims for these patients.

Note that this methodology choice includes claims and encounters for all active cancer patients, not just those with cancer-related encounters and not just those cancer-coded claims.

Also note that a more precise "active" definition would look for recency of claims and/or encounters, but the synthetic data is too old for that implementation.

Various data ambiguitites are handled with a common sense approach. Further refinement performed with coalescing , upper/lower and trim formatting on strings, and filtering/join types in the model architecture.

### Key Findings
When we look at the health costs of those individuals with active cancer, we see that 97% of their claims and 92% of their healthcare costs come from those claims that are not cancer-specific.
This suggests that having cancer increases overall healthcare costs, in addition to the cancer-specific costs.

The largest amount of money was spent on the cancer_type 'Other / Unclassified' and this was also the largets cohort in the dataset at 103 persons (169 persons in the entire dataset).

The 2nd most prevalent type of active cancer found was Prostate, with 52 persons affected. This group was the 3rd most costly active cancer overall (2nd most costly was 'Metastatic / Unknown Primary' with the most costly average claim amount, only 8 persons affected).

The most costly encounter_type in terms of average claim amount was outpatient hospice at $2,775.

The most costly encounter_type in terms of total spend was acute inpatient. Note this includes encounters for active cancer patients that are not necessarily cancer-specific. Patients in this group make up 35% of the entire dataset cohort and account for 32% of total spend.

The 2nd most costly encounter_type by total spend was office visit, but merely due to prevalence with 97% of patients affected. The average cost per person for office visits was only 13.9% of the average for acute inpatient encounters.

Emergeny department costs only came in at the 3rd most costly type overall due to the combination of prevalence (65% of persons) and cost per person (12% of that of acute inpatient).

The complete breakout is shown here (SELECT * FROM fct_spend_by_cancer_type):

┌───────────────────┬──────────────────────┬──────────────────────┬───────────┬──────────┬───┬─────────────────────┬───────────────────┬──────────────────────┬─────────────────────┐
│ aggregation_level │     cancer_type      │    encounter_type    │ n_persons │ n_claims │ … │ patient_paid_amount │ total_paid_amount │ avg_total_per_person │ avg_total_per_claim │
│      varchar      │       varchar        │       varchar        │   int64   │  int64   │   │    decimal(38,0)    │   decimal(38,0)   │        double        │       double        │
├───────────────────┼──────────────────────┼──────────────────────┼───────────┼──────────┼───┼─────────────────────┼───────────────────┼──────────────────────┼─────────────────────┤
│ total             │ NULL                 │ NULL                 │       169 │    19214 │ … │              411314 │           3352583 │              19838.0 │               174.0 │
│ cancer_type       │ Cancer Patient - N…  │ NULL                 │       168 │    18646 │ … │              382289 │           3087483 │              18378.0 │               166.0 │
│ encounter_type    │ NULL                 │ acute inpatient      │        59 │     1224 │ … │               45706 │           1075217 │              18224.0 │               878.0 │
│ encounter_type    │ NULL                 │ office visit         │       164 │     4172 │ … │              111012 │            415586 │               2534.0 │               100.0 │
│ encounter_type    │ NULL                 │ emergency department │       109 │     1389 │ … │               29119 │            239272 │               2195.0 │               172.0 │
│ encounter_type    │ NULL                 │ outpatient surgery   │       103 │      638 │ … │               22396 │            232260 │               2255.0 │               364.0 │
│ encounter_type    │ NULL                 │ office visit - other │       160 │     1833 │ … │               58774 │            230372 │               1440.0 │               126.0 │
│ encounter_type    │ NULL                 │ outpatient hospita…  │       152 │     1871 │ … │               12183 │            229175 │               1508.0 │               122.0 │
│ encounter_type    │ NULL                 │ ambulatory surgery…  │        62 │      500 │ … │               54746 │            188047 │               3033.0 │               376.0 │
│ cancer_type       │ Other / Unclassified │ NULL                 │       103 │      290 │ … │               29180 │            184763 │               1794.0 │               637.0 │
│ encounter_type    │ NULL                 │ lab - orphaned       │       164 │     4067 │ … │                3935 │            138892 │                847.0 │                34.0 │
│ encounter_type    │ NULL                 │ orphaned claim       │        61 │     1043 │ … │               27937 │            116122 │               1904.0 │               111.0 │
│ encounter_type    │ NULL                 │ outpatient injecti…  │        31 │      109 │ … │                3808 │            112756 │               3637.0 │              1034.0 │
│ encounter_type    │ NULL                 │ office visit radio…  │       139 │      811 │ … │               14841 │            112096 │                806.0 │               138.0 │
│ encounter_type    │ NULL                 │ office visit injec…  │        87 │      340 │ … │               -3050 │             82300 │                946.0 │               242.0 │
│ encounter_type    │ NULL                 │ outpatient radiology │       140 │     1094 │ … │                7069 │             76979 │                550.0 │                70.0 │
│ encounter_type    │ NULL                 │ dme - orphaned       │        55 │      302 │ … │               14591 │             32721 │                595.0 │               108.0 │
│ cancer_type       │ Metastatic / Unkno…  │ NULL                 │         8 │       19 │ … │                -486 │             25634 │               3204.0 │              1349.0 │
│ encounter_type    │ NULL                 │ office visit pt/ot…  │        43 │      254 │ … │                4730 │             24210 │                563.0 │                95.0 │
│ cancer_type       │ Prostate             │ NULL                 │        52 │      190 │ … │               -1155 │             23799 │                458.0 │               125.0 │
│ cancer_type       │ Hematologic - Lymp…  │ NULL                 │        11 │       16 │ … │                 196 │             18115 │               1647.0 │              1132.0 │
│ encounter_type    │ NULL                 │ ambulance - orphaned │        21 │       49 │ … │                2682 │             12291 │                585.0 │               251.0 │
│ encounter_type    │ NULL                 │ home health          │        16 │       22 │ … │                 318 │             11423 │                714.0 │               519.0 │
│ encounter_type    │ NULL                 │ outpatient pt/ot/st  │        21 │       36 │ … │                 107 │             10556 │                503.0 │               293.0 │
│ encounter_type    │ NULL                 │ outpatient hospice   │         3 │        3 │ … │                   0 │              8326 │               2775.0 │              2775.0 │
│ cancer_type       │ Other Genitourinary  │ NULL                 │        16 │       23 │ … │                 492 │              5291 │                331.0 │               230.0 │
│ cancer_type       │ Gynecologic          │ NULL                 │        10 │       15 │ … │                 268 │              3776 │                378.0 │               252.0 │
│ cancer_type       │ Colorectal & Anal    │ NULL                 │         9 │       22 │ … │                 366 │              2458 │                273.0 │               112.0 │
│ encounter_type    │ NULL                 │ urgent care          │        12 │       28 │ … │                 326 │              1535 │                128.0 │                55.0 │
│ encounter_type    │ NULL                 │ inpatient skilled …  │         1 │        2 │ … │                  19 │              1378 │               1378.0 │               689.0 │
│ cancer_type       │ Hepatobiliary & Pa…  │ NULL                 │         3 │        3 │ … │                  89 │               797 │                266.0 │               266.0 │
│ encounter_type    │ NULL                 │ outpatient rehabil…  │         2 │        3 │ … │                   0 │               793 │                396.0 │               264.0 │
│ cancer_type       │ Head & Neck          │ NULL                 │         2 │        2 │ … │                  73 │               325 │                163.0 │               163.0 │
│ encounter_type    │ NULL                 │ outpatient psych     │         2 │        3 │ … │                  65 │               276 │                138.0 │                92.0 │
│ cancer_type       │ Hematologic - Myel…  │ NULL                 │         2 │        2 │ … │                   0 │               131 │                 65.0 │                65.0 │
│ cancer_type       │ Esophageal & Gastric │ NULL                 │         1 │        1 │ … │                   2 │                11 │                 11.0 │                11.0 │
├───────────────────┴──────────────────────┴──────────────────────┴───────────┴──────────┴───┴─────────────────────┴───────────────────┴──────────────────────┴─────────────────────┤
│ 36 rows                                                                                                                                                      10 columns (9 shown) │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

### AI Usage Log
AI was used cautiously and sparingly in the development of this set of models.

It was primarily used for understanding the most common methods for identifying active cancer patients using ICD-10-CM codes, as well as grouping those codes into cancer type classifications. This is how the cancer types and set of persons with active cancer conditions were derived.

Multiple iterations and corrections/validations were necessary here, as the AI oversimplified the code selections.