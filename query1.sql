-- Query1.sql
-- imputes the missing data in the `age` field 
-- of a hospital with the median of all entries
-- from the same hospital, given schema:
-- Data(patientID, hospitalID, age, cholesterol, tomography).
-- For example, given relation instance:
-- {(0,0,15,0,0), (1,0,NULL,42,12), (2,1,NULL,NULL,100), (3,1,20,10,NULL)}
-- this query should transform it into the following instance:
--  {(0,0,15,0,0), (1,0,15,42,12), (2,1,20,NULL,100), (3,1,20,10,NULL)}

WITH MedianCTE AS (
  SELECT
    hospitalID,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY age) OVER (PARTITION BY hospitalID) AS median_age
  FROM
    Data where age is NOT NULL
)
UPDATE Data
SET Data.age = mc.median_age
FROM MedianCTE AS mc
WHERE Data.hospitalID = mc.hospitalID
  AND Data.age IS NULL;