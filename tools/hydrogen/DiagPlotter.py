# -*- coding: utf-8 -*-
"""
Created on Wed Mar  1 15:18:28 2023

@author: daniel.hatchell
"""

# Import packages

from read_diag_into_list import read_diag_into_list
from variable_by_tech_by_region_by_year import variable_by_tech_by_region_by_year
from variable_by_tech_averaged_over_region_by_year import variable_by_tech_averaged_over_region_by_year
# from variable_by_tech_averaged_over_region_by_year_line_plot import variable_by_tech_averaged_over_region_by_year_line_plot
from variable_by_tech_totaled_over_region_by_year import variable_by_tech_totaled_over_region_by_year
from calculate_variable_array import calculate_variable_array

# Name of the diag file goes here

filename="GlobalDataToNEMS_Diag_2050_05.txt"

# Save png with these settings
savepng = True
# name = 'EMF_NZref_IRA_d032623a' # Part of filename for saved png files
name = 'ref'

# List of all of the variables you want to plot
variable_name = ['p_HydrogenProductionOpCost(i_PAT,i_CnDvOpt,i_calYear)',
                 'p_HydrogenFixedO_MCost(i_PAT,i_CnDvOpt,i_calYear)',
                 'p_HydrogenProductionCapCost(i_PAT,i_CnDvOpt,i_calYear)',
                 'p_PUC(i_PAT,i_CensusDivisionOpt,i_calYear)']

# Description of each variable (used in plot legend)
variable_description = ['Operating Cost','Fixed O+M Cost','Capital Cost', 'Production Capacity']

# Option to plot natural gas and diesel prices in line plot
compare_diesel_ng = 'tax'

# Set the plot year
yearplot = 2050

# Set the max of the y axis
ylim_set = [0,0]
ylim_set[0] = 0
ylim_set[1] = 8

# Set yticks (subplots only - the average plot works well with automatic ticks)
yticks = [0,2,4,6,8]
ylim_set += yticks



# First png address for the subplots figure
pngaddress1 = 'diagplots_'+name+'.png'
pngaddress2 = 'diagplots_averaged_'+name+'.png'
pngaddress3 = 'diagplots_averaged_line_plot_'+name+'.png'
pngaddress4 = 'diagplots_line_plot_'+name+'.png'


#
# Execute Plots
#


dflist, col1, col2, col3, col4, years, tech, divisions = read_diag_into_list(filename,variable_name)

values = calculate_variable_array(dflist,tech,divisions,variable_description,years,col1,col2,col3,col4)

variable_by_tech_by_region_by_year(tech,divisions,variable_description,years,yearplot,values,savepng,pngaddress1,ylim_set)
variable_by_tech_averaged_over_region_by_year(tech,divisions,variable_description,years,yearplot,values,savepng,pngaddress2,ylim_set)

ylim_set[1] = 80

# Warning - unverified plot - commented out for now
# The ng / diesel reference values may be out of date - pulled directly from FECM22

# variable_by_tech_averaged_over_region_by_year_line_plot(tech,years,yearplot,values,savepng,pngaddress3,ylim_set,compare_diesel_ng)
variable_by_tech_totaled_over_region_by_year(tech,years,values,savepng,pngaddress4)