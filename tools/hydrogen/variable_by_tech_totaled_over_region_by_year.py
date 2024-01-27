# -*- coding: utf-8 -*-
"""
Created on Tue Mar 28 16:48:47 2023

@author: daniel.hatchell
"""

import numpy as np
import matplotlib.pyplot as plt
from legend_update import legend_update

def variable_by_tech_totaled_over_region_by_year(tech,years,values,savepng,pngaddress):
    # Plot to compare all of the tech together

    plt.figure(figsize=((14,10)))
    lines = ["-","--","-.",":"]
    tech_list = tech[3]
    yearindex = 2050 - np.min(years[3])
    # Iterate through each tech and add it to the plot. h goes through each tech,
    # and i goes through each division. By the way, the divisions aren't used for
    # this plot. They all get added together.

    
    totalvalues = np.sum(values[:,:,3,30:(yearindex+1)],0)/1000 # Conversion to MMT
    sumtotalvalues = np.sum(totalvalues,0)        
    
    for i in np.searchsorted(np.unique(np.concatenate(tech)),tech[3]):
        plt.plot(years[3][30:(yearindex+1)],totalvalues[i,:],linestyle = lines[np.mod(i,4)], linewidth=5)
    
    plt.plot(years[3][30:(yearindex+1)],sumtotalvalues,'k-', linewidth=5)
    
    # More settings for the first plot
    plt.title('All Tech Compared',fontsize=40)
    plt.xlabel('Year',fontsize = 32)
    plt.ylabel('H2 Production Capacity (MMT)',fontsize = 32)
    plt.xticks(fontsize=32)
    plt.yticks(fontsize=32)
    
    tech_list = np.append(tech_list,'Total')

    updated_legend = legend_update(tech_list)
    plt.legend(updated_legend,loc='lower center', bbox_to_anchor=(0.35, -0.65),fontsize=24,frameon=False)

    if savepng == True:
        plt.savefig(pngaddress, bbox_inches='tight')