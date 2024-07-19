-- Query3.sql
-- Given schema Data(patientID, hospitalID, age, cholesterol, tomography)
-- imputes the missing data in the `tomography` attribute using
-- one-dimensional linear regression on top of the `cholesterol` attribute 
-- For example, given relation instance:
-- {(0,0,19,0,0), (1,0,24,100,200), (2,1,24,NULL,100), (3,2,20,10,NULL)}
-- this query should transform it into the following instance:
-- {(0,0,19,0,0), (1,0,24,100,200), (2,1,24,NULL,100), (3,2,20,10,20)}

-- REPLACE THIS LINE WITH YOUR QUERY AND SUBMIT THIS FILE.
