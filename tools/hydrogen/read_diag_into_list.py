# -*- coding: utf-8 -*-
"""
Created on Wed Mar  1 15:19:32 2023

@author: daniel.hatchell
"""
import numpy as np
import pandas as pd

def read_diag_into_list(filename,variable_name):
    # Skip the header, dotted line, and footer. This will most likely be different 
    # for each data file.
    index3 = sum(1 for line in open(filename))
    index1 = index3
    
    dflist = []
    col1 = []
    col2 = []
    col3 = []
    col4 = []
    years = []
    tech = []
    divisions = []
    
    # Read data into a list, dflist
    for i in range(0,len(variable_name)):
        with open(filename,"r",encoding="utf-8") as file:
            index1 = index3
            for row_number, line in enumerate(file, start=1):
                if variable_name[i] in line:
                    index1 = row_number-1
                if (';' in line) & (row_number>index1+1):
                    index2 = row_number-1
                    break            
    
            skiprows = list(range(0,index1))+[index1+1]+list(range(index2,index3))
    
            # Load dataframe
            dflist.append(pd.read_table(filename, header = 0, delim_whitespace=True, skipinitialspace=True, skiprows = skiprows, quotechar='\''))
    
            # Define some arrays that will be helpful later
            # Note that these variables are specific to the data file
            col1.append(dflist[i].columns[0])
            col2.append(dflist[i].columns[1])
            col3.append(dflist[i].columns[2])
            col4.append(dflist[i].columns[3])
    
            years.append(np.sort(np.unique(dflist[i][col3].values)))

    
            tech.append(np.unique(dflist[i][col1].values))
            # maxcapacity = np.zeros(len(tech[i]))
    
            # Eliminate tricky characters
            #for j in range(0,len(tech[i])):
            #    tech[i][j] = tech[i][j].replace('\u202f',' ')
            #    tech[i][j] = tech[i][j].replace('\xa0',' ')
                
            divisions.append(np.sort(np.unique(dflist[i][col2[i]].values)))
            
    return dflist,col1,col2,col3,col4,years,tech,divisions