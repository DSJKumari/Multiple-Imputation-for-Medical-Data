-- Query3.sql
-- Given schema Data(patientID, hospitalID, age, cholesterol, tomography)
-- imputes the missing data in the `tomography` attribute using
-- one-dimensional linear regression on top of the `cholesterol` attribute 
-- For example, given relation instance:
-- {(0,0,19,0,0), (1,0,24,100,200), (2,1,24,NULL,100), (3,2,20,10,NULL)}
-- this query should transform it into the following instance:
-- {(0,0,19,0,0), (1,0,24,100,200), (2,1,24,NULL,100), (3,2,20,10,20)}

-- REPLACE THIS LINE WITH YOUR QUERY AND SUBMIT THIS FILE.

CREATE TEMPORARY TABLE IF NOT EXISTS TempModeData AS
    SELECT patientID,
           SUBSTRING_INDEX(GROUP_CONCAT(cholesterol ORDER BY freq DESC, cholesterol DESC SEPARATOR ','), ',', -1) AS mode_cholesterol,
           SUBSTRING_INDEX(GROUP_CONCAT(tomography ORDER BY freq DESC, tomography DESC SEPARATOR ','), ',', -1) AS mode_tomography
    FROM (
        SELECT patientID,
               cholesterol,
               tomography,
               COUNT(*) as freq
        FROM PatientData
        GROUP BY patientID, cholesterol, tomography
    ) AS sub
    GROUP BY patientID;

UPDATE PatientData pd
INNER JOIN TempModeData tmd ON pd.patientID = tmd.patientID
SET pd.cholesterol = tmd.mode_cholesterol,
    pd.tomography = tmd.mode_tomography
WHERE pd.cholesterol IS NOT NULL AND pd.tomography IS NOT NULL;

DROP TEMPORARY TABLE IF EXISTS TempModeData;


CREATE TEMPORARY TABLE IF NOT EXISTS TempModeData AS
    SELECT patientID,
           SUBSTRING_INDEX(GROUP_CONCAT(cholesterol ORDER BY freq DESC, cholesterol DESC SEPARATOR ','), ',', -1) AS mode_cholesterol,
           SUBSTRING_INDEX(GROUP_CONCAT(tomography ORDER BY freq DESC, tomography DESC SEPARATOR ','), ',', -1) AS mode_tomography
    FROM (
        SELECT patientID,
               cholesterol,
               tomography,
               COUNT(*) as freq
        FROM PatientData
        GROUP BY patientID, cholesterol, tomography
    ) AS sub
    GROUP BY patientID;

UPDATE PatientData pd
INNER JOIN TempModeData tmd ON pd.patientID = tmd.patientID
SET pd.cholesterol = tmd.mode_cholesterol,
    pd.tomography = tmd.mode_tomography
WHERE pd.cholesterol IS NOT NULL AND pd.tomography IS NOT NULL;

DROP TEMPORARY TABLE IF EXISTS TempModeData;


CREATE TEMPORARY TABLE IF NOT EXISTS TempStats AS
SELECT 
    AVG(cholesterol) AS cholesterol_mean,
    AVG(tomography) AS tomography_mean,
    SUM(cholesterol * cholesterol) / COUNT(*) AS mean_squared,
    SUM(cholesterol * tomography) / COUNT(*) AS product_mean,
    COUNT(*) AS data_count
FROM PatientData
WHERE cholesterol IS NOT NULL AND tomography IS NOT NULL;

CREATE TEMPORARY TABLE IF NOT EXISTS RegressionParams (
    slope FLOAT,
    intercept FLOAT
);


INSERT INTO RegressionParams (slope, intercept)
SELECT 
    (product_mean - cholesterol_mean * tomography_mean) / (mean_squared - cholesterol_mean * cholesterol_mean) AS slope,
    tomography_mean - ((product_mean - cholesterol_mean * tomography_mean) / (mean_squared - cholesterol_mean * cholesterol_mean)) * cholesterol_mean AS intercept
FROM TempStats;


UPDATE PatientData 
INNER JOIN RegressionParams
SET tomography = 
    CASE
        WHEN tomography IS NULL AND cholesterol IS NOT NULL THEN
            RegressionParams.slope * cholesterol + RegressionParams.intercept
        ELSE
            tomography
    END
WHERE tomography IS NULL AND cholesterol IS NOT NULL;
