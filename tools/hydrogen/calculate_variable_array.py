# -*- coding: utf-8 -*-
"""
Created on Tue Mar 28 11:40:47 2023

@author: daniel.hatchell
"""

import numpy as np

def calculate_variable_array(dflist,tech,divisions,variable_description,years,col1,col2,col3,col4):
   
    tech_list = np.unique(np.concatenate(tech))
    divisions_number = len(np.unique(np.concatenate(divisions)))
    tech_number = len(np.unique(np.concatenate(tech)))
    variable_number = len(variable_description)
    year_number = len(np.unique(np.concatenate(years)))
    values = np.zeros([divisions_number,tech_number,variable_number,year_number])
    
    # i iterates through each division
    for i in range(0,divisions_number):
        # j iterates through each tech
        for j in range(0,tech_number):
            # k iterates through each variable:
            for k in range(0,variable_number):

                tempvalues = dflist[k].loc[(dflist[k][col1[k]] == tech_list[j]) & (dflist[k][col2[k]] == i+1)][col4[k]].values
                tempyears = dflist[k].loc[(dflist[k][col1[k]] == tech_list[j]) & (dflist[k][col2[k]] == i+1)][col3[k]].values
                index = tempyears*0
                
                # l goes through the years to make the x axis consistent
                for l in range(0,len(tempyears)):
                    index[l] = np.where(years[k]==tempyears[l])[0][0]
                
                # Array of all values by division, tech, variable, and year
                # All of the data is stored here in a 4d array
                values[i,j,k,index] += tempvalues
    
    return values