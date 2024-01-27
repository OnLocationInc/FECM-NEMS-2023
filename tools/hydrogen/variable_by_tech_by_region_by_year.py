# -*- coding: utf-8 -*-
"""
Created on Wed Mar  1 15:15:12 2023

@author: daniel.hatchell
"""

import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from legend_update import legend_update

def variable_by_tech_by_region_by_year(tech,divisions,variable_description,years,yearplot,values,savepng,pngaddress,ylim_set):
      
    tech_number = len(np.unique(np.concatenate(tech)))
    divisions_number = len(np.unique(np.concatenate(divisions)))
    divisions_list = ['New England','Mid-Atlantic','East North Central','West North Central','South Atlantic','East South Central','West South Central','Mountain','Pacific']
    variable_number = 3 # len(variable_description)
    yearindex = yearplot - np.min(years[0:3])
    
    # Plot all subplots together
    tech_order = np.argsort(np.sum(np.sum(values[:,:,0:variable_number,yearindex],2),0)/divisions_number)
    tech_list = np.unique(np.concatenate(tech))[tech_order]
    labelx = np.linspace(1,tech_number,tech_number,dtype='int')
    updated_table = legend_update(tech_list)
    table_data = np.array([labelx,updated_table]).transpose()
    
    # plot settings
    guidelines = ylim_set[2:]  # y-axis values for the guidelines
    matplotlib.rcParams.update({'font.size': 48})
    plotrow = int(np.ceil(divisions_number/3))
    fig, axs = plt.subplots(plotrow, 3)
    fig.suptitle("Levelized Cost of all Technologies (2022 $/kg), by Census Division, year = " + str(yearplot), fontsize=80,x=3.25,y=5.5)
        
    plt.subplots_adjust(left=0.0, bottom=0.0, right=6.5, top=5, wspace=0.25, hspace=0.3)
    width = 0.75
    
    # i iterates through each division
    for i in range(0,divisions_number):             

        # Some plot settings
        plt.subplot(plotrow,3,i+1)
        plt.bar(labelx,values[i,tech_order,0,yearindex],width,label = variable_description[0])

        bottom = values[i,:,0,yearindex]*0

        bottom_pos = values[i,:,0,yearindex].clip(min=0)
        bottom_neg = values[i,:,0,yearindex].clip(max=0)
            
        # k and j iterate through variables and tech 
        for k in range(1,variable_number):
            for j in range(0,len(tech_list)):
                if values[i,j,k,yearindex] >= 0:
                    bottom[j] = bottom_pos[j]
                    bottom_pos[j] += values[i,j,k,yearindex]
                else:
                    bottom[j] = bottom_neg[j]
                    bottom_neg += values[i,j,k,yearindex]  

            plt.bar(labelx,values[i,tech_order,k,yearindex],width,label = variable_description[k], bottom = bottom[tech_order])
            
        plt.title(divisions_list[i],fontsize=48)
        plt.ylabel('Levelized Cost')
        plt.ylim([ylim_set[0],ylim_set[1]])
        plt.yticks(ylim_set[2:])
        plt.xticks(labelx)
            
        for j in range(0,len(guidelines)):
            plt.axhline(guidelines[j], color='grey', linestyle='--',label='_nolegend_')

    plt.subplot(plotrow,3,1)
    plt.legend(variable_description,loc='upper left',prop={'size': 64},bbox_to_anchor=(-1.65, 1.2),frameon=False)
    table = plt.table(cellText=table_data, bbox = [-1.85,-2.6,1.6,2.5],edges = 'closed', colWidths=[0.1, 1.2], cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(40)
    plt.text(x=-tech_number*1.47,y=ylim_set[0],s='List of Technologies', fontsize=64)
    
    if savepng == True:
        fig.savefig(pngaddress, bbox_inches='tight')
    
    return