# -*- coding: utf-8 -*-
"""
Created on Wed Mar  1 15:17:23 2023

@author: daniel.hatchell
"""

import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from legend_update import legend_update

def variable_by_tech_averaged_over_region_by_year(tech,divisions,variable_description,years,yearplot,values,savepng,pngaddress,ylim_set):
      
    tech_number = len(np.unique(np.concatenate(tech)))
    divisions_number = len(np.unique(np.concatenate(divisions)))
    variable_number = 3 #len(variable_description)
    yearindex = yearplot - np.min(years[0:3])
    
    tech_order = np.argsort(np.sum(np.sum(values[:,:,0:variable_number,yearindex],2),0)/divisions_number)
    tech_list = np.unique(np.concatenate(tech))[tech_order]
    
    average_costs = np.zeros([tech_number,variable_number])
    for j in range(0,tech_number):
        # k iterates through each variable:
        for k in range(0,variable_number):
            values_non_zero = values[:,j,k,yearindex][values[:,j,k,yearindex] != 0]
            average_costs[j,k] = np.mean(values_non_zero)
    
    average_costs[np.isnan(average_costs)] = 0

    # Some plot settings
    labelx = np.linspace(1,tech_number,tech_number,dtype='int')
    updated_table = legend_update(tech_list)
    table_data = np.array([labelx,updated_table]).transpose()    
    matplotlib.rcParams.update({'font.size': 16})
    width = 0.75

    fig = plt.figure(figsize=[6,8])
    plt.bar(labelx,average_costs[tech_order,0],width,label = variable_description[0])
    bottom = average_costs[:,0]*0
    bottom_pos = average_costs[:,0].clip(min=0)
    bottom_neg = average_costs[:,0].clip(max=0)
        
    # k iterates through variables again. 
    for k in range(1,variable_number):
        for j in range(0,tech_number):
            if average_costs[j,k] >= 0:
                bottom[j] = bottom_pos[j]
                bottom_pos[j] += average_costs[j,k]
            else:
                bottom[j] = bottom_neg[j]
                bottom_neg += average_costs[j,k]

        plt.bar(labelx,average_costs[tech_order,k],width,label = variable_description[k], bottom = bottom[tech_order])

            
    plt.title('Average Cost Over All Divisions, Year = ' + str(yearplot),fontsize=14)
    plt.ylabel('Levelized Cost (2022 $/kg)')
    plt.xlabel('Technology, by Number')
    plt.ylim([ylim_set[0],ylim_set[1]])
    plt.xticks(labelx)
            
    guidelines = plt.yticks()  # y-axis values for the guidelines
    for guideline in guidelines[0]:
        plt.axhline(guideline, color='grey', linestyle='--',label='_nolegend_')
    
    plt.legend(variable_description,loc='upper left',prop={'size': 16},bbox_to_anchor=(-1.2, 1),frameon=False)
    
    table = plt.table(cellText=table_data, bbox = [-1.4,0,1.2,0.7],edges = 'closed', colWidths=[0.1, 0.8], cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(12)
        
    plt.text(x=-1.04*tech_number,y=((ylim_set[1]-ylim_set[0])*.72+ylim_set[0]),s='List of Technologies', fontsize=16)
        
    if savepng == True:
        fig.savefig(pngaddress, bbox_inches='tight')

    return