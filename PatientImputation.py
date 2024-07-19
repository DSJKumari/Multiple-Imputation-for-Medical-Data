# Collection of methods to impute missing hospital data provided by file

import pandas as pd
import numpy as np
import math


# Class that imputes estimated values for cells of a pandas DataFrame
# that are unknown, i.e., that are set to np.nan
class Impute():
    # Constructs a new Impute class with a given DataFrame called input_data
    # The DataFrame should have five attributes:
    # patientID, hospitalID, age, cholesterol, tomography
    def __init__(self, input_data):
        self.input_data = input_data


    # Given a hospital id, imputes the age of all patients
    # at that hospital who currently have np.nan for age 
    # as the median of all patients at that hospital whose age is known.
    # Returns a DataFrame consisting of all patients whose age has changed.
    def impute_age(self, hospitalID):
        hospital_subset = self.input_data.loc[self.input_data['hospitalID'] == hospitalID].copy()
        median_age = hospital_subset['age'].median()
        age_changed_patients = hospital_subset[hospital_subset['age'].isna()].copy()
        age_changed_patients = age_changed_patients.drop('hospitalID',axis=1)
        hospital_subset['age'].fillna(median_age, inplace=True)
        if math.isnan(median_age):
            empty_df = pd.DataFrame({\
                'patientID':list(),\
                'age':list(),\
                'cholesterol':list(),\
                'tomography':list()\
                })
            return empty_df
        age_changed_patients = hospital_subset[hospital_subset.patientID.isin(age_changed_patients.patientID)].drop('hospitalID', axis=1)
        return age_changed_patients.reset_index(drop=True)


    # Given a hospital id, imputes the cholesterol level of all patients
    # at that hospital who currently have np.nan for cholesterol 
    # as the average of all patients at that hospital with the same age.
    # Returns a DataFrame consisting of all patients whose cholesterol has changed.
    def impute_cholesterol_single_hospital(self, hospitalID):
        hospital_subset = self.input_data.loc[self.input_data['hospitalID'] == hospitalID].copy()
        hospital_subset_changed = self.input_data.loc[self.input_data['hospitalID'] == hospitalID].copy()
        mean_cholesterol_by_age = hospital_subset.groupby('age')['cholesterol'].mean()
        mean_cholesterol_by_age = mean_cholesterol_by_age.dropna()
        change_index = []
        for index, row in hospital_subset.iterrows():
            if pd.isna(row['cholesterol']) & pd.notna(row['age']):
                age = row['age']
                if age in mean_cholesterol_by_age:
                    hospital_subset.at[index, 'cholesterol'] = mean_cholesterol_by_age[age]
                    change_index.append(index)
        hospital_subset_changed = hospital_subset.iloc[change_index].drop('hospitalID', axis=1)
        if hospital_subset_changed.empty:
            empty_df = pd.DataFrame({\
                'patientID':list(),\
                'age':list(),\
                'cholesterol':list(),\
                'tomography':list()\
                })
            return empty_df
        return hospital_subset_changed.reset_index(drop=True)


    # Imputes the cholesterol level of all patients at all hospitals
    # who currently have np.nan for cholesterol using as the lowest
    # known value of all patients whose age is in the same five-year bracket.
    # Returns a DataFrame consisting of all patients whose cholesterol has changed.
    def impute_cholesterol(self):
        age_notnan = self.input_data[~self.input_data['age'].isna()]
        age_bracket = (age_notnan['age'] // 5) * 5
        lowest_known_cholesterol_by_age = self.input_data.groupby(age_bracket)['cholesterol'].min()
        lowest_known_cholesterol_by_age = lowest_known_cholesterol_by_age.dropna()
        patientId_store = []
        for index, row in self.input_data.iterrows():
            if pd.isna(row['cholesterol']):
                bracket = (row['age'] // 5) * 5
                if bracket in lowest_known_cholesterol_by_age:
                    self.input_data.at[index, 'cholesterol'] = lowest_known_cholesterol_by_age[bracket]
                    patientId_store.append(self.input_data.at[index, 'patientID'])
        bracket_changed_cholesterol = self.input_data[self.input_data['patientID'].isin(patientId_store)]
        if bracket_changed_cholesterol.empty:
            empty_df = pd.DataFrame({\
                'patientID':list(),\
                'hospitalID':list(),\
                'age':list(),\
                'cholesterol':list(),\
                'tomography':list()\
                })
            return empty_df
        return bracket_changed_cholesterol.reset_index(drop=True)

    # Imputes the time to tomography of all patients at all hospitals
    # who currently have np.nan for tomography by interpolating the values
    # with linear regression trained over the cholesterol level as the independent variable.
    # Returns a DataFrame consisting of all patients whose tomography has changed.
    def impute_tomography(self):
        original_data = self.input_data.copy()
        duplicate_patientid = self.input_data[self.input_data.duplicated(subset=['patientID'], keep=False)].copy()
        for pid, group in duplicate_patientid.groupby('patientID'):
            majority_cholesterol = group['cholesterol'].mode().iloc[0]
            majority_tomography = group['tomography'].mode().iloc[0]
            self.input_data.loc[self.input_data['patientID'] == pid, 'cholesterol'] = majority_cholesterol
            self.input_data.loc[self.input_data['patientID'] == pid, 'tomography'] = majority_tomography
        hospital_subset = self.input_data.copy()
        X = hospital_subset[(hospital_subset['cholesterol'].notnull()) & (hospital_subset['cholesterol'] != 0) & (hospital_subset['tomography'].notnull()) & (hospital_subset['tomography'] != 0)]
        N = len(X)
        if N == 0:
            empty_df = pd.DataFrame({\
                'patientID':list(),\
                'hospitalID':list(),\
                'age':list(),\
                'cholesterol':list(),\
                'tomography':list()\
                })
            return empty_df
        m = X['tomography']/X['cholesterol']
        tomography_null = hospital_subset[hospital_subset['tomography'].isnull()].copy()
        for index, row in tomography_null.iterrows():
            if pd.isna(tomography_null.at[index, 'cholesterol']):
                tomography_null.at[index, 'tomography'] = 0
            else:
                tomography_null.at[index, 'tomography'] = tomography_null.at[index, 'cholesterol']*m
        different_rows = self.input_data[(self.input_data['cholesterol'] != original_data['cholesterol']) | (self.input_data['tomography'] != original_data['tomography'])]
        different_rows = different_rows.dropna()
        changed_tomography = pd.concat([different_rows, tomography_null], axis=0)
        print(changed_tomography)
        return changed_tomography.reset_index(drop=True)
