# -*- coding: utf-8 -*-
"""
Created on Mon Mar 27 11:37:26 2023

@author: daniel.hatchell
"""


import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from legend_update import legend_update
from h2price_diesel_ng_ref_tax import h2price_diesel_ng_ref_tax

def variable_by_tech_averaged_over_region_by_year_line_plot(tech,years,yearplot,values,savepng,pngaddress,ylim_set,compare_diesel_ng):
    
    diesel_ref,diesel_tax,natgas_ref,natgas_tax,year_diesel_natgas = h2price_diesel_ng_ref_tax()
    
    tech_number = len(np.unique(np.concatenate(tech)))
    variable_number = 3 #len(variable_description)
    yearindex = 2050 - np.min(years[0:3])

    values_converted = values/0.13455
    
    totalvalues = np.sum(values_converted[:,:,0:variable_number,:],2)
    totalvalues = np.mean(np.sum(values_converted[:,:,0:variable_number,:],2),0) # Check this for averaging over zeros

    tech_order = np.argsort(-totalvalues[:,yearindex])
    tech_list = np.unique(np.concatenate(tech))[tech_order]

    # Some plot settings
    matplotlib.rcParams.update({'font.size': 16})
    fig = plt.figure(figsize=[14,10])
    lines = ["-","--","-.",":"]
        
    for j in range(0,tech_number):
        plt.plot(years[0][0:(yearindex+1)],totalvalues[tech_order[j],0:(yearindex+1)],linestyle = lines[np.mod(j,4)], linewidth=5)
    
    if compare_diesel_ng == 'ref':
        plt.plot(year_diesel_natgas,diesel_ref, 'k-', linewidth=8)
        plt.plot(year_diesel_natgas,natgas_ref, 'k--', linewidth=8)
        tech_list = np.append(tech_list,['Diesel','Natural Gas'])
    elif compare_diesel_ng == 'tax':
        plt.plot(year_diesel_natgas,diesel_tax, 'k-', linewidth=8)
        plt.plot(year_diesel_natgas,natgas_tax, 'k--', linewidth=8)
        tech_list = np.append(tech_list,['Diesel','Natural Gas'])
    
    # More settings for the first plot
    plt.title('All Tech Compared',fontsize=40)
    plt.xlabel('Year',fontsize = 32)
    plt.ylabel('Mean H2 Prod. Cost (2022 $/MMBtu)',fontsize = 32)
    plt.xlim([np.min(years[0:3]),2050])
    plt.ylim(ylim_set[0:2])
    plt.xticks(fontsize=32)
    plt.yticks(fontsize=32)
            
    guidelines = plt.yticks()  # y-axis values for the guidelines
    for guideline in guidelines[0]:
        plt.axhline(guideline, color='grey', linestyle='--',label='_nolegend_')
    
    updated_legend = legend_update(tech_list)
    plt.legend(updated_legend,loc='lower center', bbox_to_anchor=(0.35, -1.05),fontsize=24,frameon=False)

    if savepng == True:
        fig.savefig(pngaddress, bbox_inches='tight')    

    return