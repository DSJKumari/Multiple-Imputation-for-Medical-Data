-- Query3.sql
-- Given schema Data(patientID, hospitalID, age, cholesterol, tomography)
-- imputes the missing data in the `cholesterol` field 
-- of a patient with with the smallest value of
-- patient's with an age in the same five year bracket, i.e., 0-4, 5-9, 10-14, etc.
-- For example, given relation instance:
-- {(0,0,19,0,0), (1,0,24,42,12), (2,1,24,NULL,100), (3,2,20,10,87)}
-- this query should transform it into the following instance:
-- {(0,0,19,0,0), (1,0,24,42,12), (2,1,24,10,100), (3,2,20,10,87)}

-- REPLACE THIS LINE WITH YOUR QUERY AND SUBMIT THIS FILE.

UPDATE PatientData AS PDATA
JOIN (
  SELECT
    patientID,
    FLOOR(age / 5) * 5 AS age_bracket,
    (
      SELECT MIN(cholesterol)
      FROM PatientData
      WHERE cholesterol IS NOT NULL
        AND FLOOR(age / 5) * 5 = age_bracket
    ) AS min_cholesterol
  FROM PatientData
) AS CHOL
ON PDATA.patientID = CHOL.patientID
SET PDATA.cholesterol = COALESCE(PDATA.cholesterol, CHOL.min_cholesterol)
WHERE PDATA.cholesterol IS NULL;
