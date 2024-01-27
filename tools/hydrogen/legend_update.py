# -*- coding: utf-8 -*-
"""
Created on Mon Mar 27 15:41:37 2023

@author: daniel.hatchell
"""

def legend_update(tech_list):
    
    legend_update_dict = {'Autothermal reforming\u202f\xa0with CCUS': 'Autothermal reforming with CCUS',
                          'BM Gasification': 'Biomass gasification',
                          'BM Gasification with CCUS': 'Biomass gasification with CCUS',
                          'CL BM Gasification with CCUS': 'Coal biomass gasification with CCUS',
                          'CL Gasification': 'Coal gasification',
                          'CL Gasification\u202fwith CCUS': 'Coal gasification with CCUS',
                          'NG Steam methane reforming': 'Natural gas steam methane reforming',
                          'NG Steam methane reforming\u202fwith CCUS': 'Natural gas steam methane reforming with CCUS',
                          'PEM electrolysis': 'Proton exchange membrane electrolysis',
                          'PEM electrolysis\u202f\xa0Renewables': 'Proton exchange membrane electrolysis: renewables',
                          'Solid Oxide electrolysis': 'Solid oxide electrolysis',
                          'Solid Oxide electrolysis\u202f\xa0Nuc': 'Solid oxide electrolysis: nuclear',
                          'Total': 'Total'}
                          
    updated_legend = [legend_update_dict.get(tech,tech) for tech in tech_list]
    
    return updated_legend