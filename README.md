# Multiple-Imputation-for-Medical-Data

Today, it is commonplace that we want to use data that is distributed across multiple sources. A typical challenge in such cases is that everyone wants to collaborate and use everyone else's data, but they don't want to share their own—perhaps even they can't due to regulatory or privacy considerations. This is especially true of medical data, which is often collected by multiple hospitals. For example, the Georgia Coverdell Acute Stroke Registry (GCASR), maintains the acute stroke data for 68,287 patients across 75 hospitals, but each hospital stores data for only a subset of the patients'. This complicates analysing the data, as nobody has a complete view of everything in the registry. Further, the data is often incomplete—a piece of information, such as age or gender, is missing for some patients, which makes the downstream statistical analysis harder. A popular technique to enable statistical analysis on top of distributed, incomplete data is multiple imputation. Essentially, we try to estimate missing values in the data using correlations mined from the values that are available.

# Objective

This is a project to use a combination of SQL and python/pandas to probabilistically impute the missing data:

- SQL queries that can extract information from a relational database and modify the content of tables
- python/pandas code that can manipulate two-dimensional arrays of data
- wrangle data from an impure, realistic starting point into something suitable for machine learning and data analytics
