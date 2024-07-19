-- Query2.sql
-- Given schema Data(patientID, hospitalID, age, cholesterol, tomography)
-- imputes the missing data in the `cholesterol` field 
-- of a hospital with the average of all entries
-- from the same hospital, where the age is the same as that of
-- the patient whose cholesterol is being imputed
-- For example, given relation instance:
-- {(0,0,15,0,0), (1,0,24,42,12), (2,0,24,NULL,100), (3,0,24,10,87)}
-- this query should transform it into the following instance:
-- {(0,0,15,0,0), (1,0,24,42,12), (2,0,24,26,100), (3,0,24,10,87)}

-- REPLACE THIS LINE WITH YOUR QUERY AND SUBMIT THIS FILE.
UPDATE PatientData
SET cholesterol = (
    SELECT AVG(p2.cholesterol)
    FROM (SELECT * FROM PatientData) p2
    WHERE p2.age = PatientData.age
      AND p2.hospitalID = PatientData.hospitalID
      AND p2.cholesterol IS NOT NULL
)
WHERE cholesterol IS NULL;