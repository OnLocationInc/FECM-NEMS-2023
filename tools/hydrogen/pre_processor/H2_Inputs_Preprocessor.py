# -*- coding: utf-8 -*-
"""
Spyder Editor

Script to produce HMM database. This script takes a set of csv files (or json files from csv) 
and creates a sqlite dbase. Note it will add merge with an existing database or create a new one.
We use pandas for data manipulation and sqlalchemy to place pandas dataframes into tables.

"""

import pandas as pd
import json as jn
from sqlalchemy import create_engine
import shutil
import os
from datetime import datetime

import H2_Inputs
import H2_Inputs_Filenames

# All of the default files are listed here. These are used when the user does not update
# a field in the interface tool, or when the user's chosen file is not compatible.
filenames_default = [r'Hydrogen Production Inputs.csv',r'Hydrogen Pipeline Inputs.csv',
                     r'Hydrogen Storage Inputs.csv',r'Hydrogen Compressor Inputs.csv',
                     r'Ammonia Production Inputs.csv',r'Depreciation MACRS Inputs.csv',
                     r'Depreciation Straightline Inputs.csv',r'Depreciation Straightline Inputs.csv',
                     r'Depreciation Straightline Inputs.csv',r'Index_tables.csv',
                     r'Ammonia Export.csv',r'HMM_Mappings.csv',r'HMM_Policies.csv',
                     r'hmm_production_capacity.csv',r'Nh3_production_capacity.csv',r'hmm_storage_capacity.csv',
                     r'hmm_transportation_capacity.csv',r'h2_inputs_database.db']

filenames_default[-1] = r'h2_inputs_database' + datetime.today().strftime('_%Y_%m_%d') + '.db'

# Check to see if default files (listed above) are missing. Prompt user.
default_flag = False
for i in range(0,17):
    if not(os.path.exists(filenames_default[i])):
        default_flag = True
        print('The default file '+filenames_default[i]+' is missing.')

if default_flag == True:
    input('\nScript will crash if missing filenames are not changed to a valid new file. Press enter to continue.')

# Run interface tool
filenames, dbname = H2_Inputs_Filenames.assign_filenames(filenames_default)
print('\nCreating database...\n')

#Create database
db_name ='sqlite:///' + dbname + '.db'
engine = create_engine(db_name, echo=False)


#declare name of default database so it will be updated each time
#a new database is created
dbname_orig = "h2_inputs.db"

# Create json files
H2_Inputs.h2_json(filenames,filenames_default)

# Read json input file and create database tables
# To be used to update the preprocessor database
with  open('H2_Prod_Inputs.json') as f_prod:
    data_prod = jn.load(f_prod)
    data_prod_df=pd.DataFrame.from_dict(data_prod)

with open('H2_Stor_Inputs.json') as f_stor:
    data_stor = jn.load(f_stor)
    data_stor_df=pd.DataFrame.from_dict(data_stor)

with open('H2_Comp_Inputs.json') as f_comp:
    data_comp = jn.load(f_comp)
    data_comp_df=pd.DataFrame.from_dict(data_comp)

with open('H2_Pipe_Inputs.json') as f_pipe:
    data_pipe = jn.load(f_pipe)
    data_pipe_df=pd.DataFrame.from_dict(data_pipe)

with  open('NH3_Prod_Inputs.json') as f_prod:
    data_prod_NH3 = jn.load(f_prod)
    data_prod_NH3_df=pd.DataFrame.from_dict(data_prod_NH3)

with open('Dep_MACRS_Inputs.json') as f_macrs:
    data_macrs = jn.load(f_macrs)
    data_macrs_df=pd.DataFrame.from_dict(data_macrs)

with open('Dep_150_Inputs.json') as f_d150:
    data_d150 = jn.load(f_d150)
    data_d150_df=pd.DataFrame.from_dict(data_d150)
    
with open('Dep_SL_Inputs.json') as f_sl:
    data_sl = jn.load(f_sl)
    data_sl_df=pd.DataFrame.from_dict(data_sl)
    
with open('NH3_Prod_Inputs.json') as f_NH3:
    data_NH3 = jn.load(f_NH3)
    data_NH3_df=pd.DataFrame.from_dict(data_NH3)


# read indices files, create unique list of indices from column index_name
# Try to use the given filename. If not compatible, revert to the default filename.
try:
    data_index_set = pd.read_csv(filenames[9],index_col=False)
    index_types = data_index_set['Index_Name'].unique()
except ValueError:
    print('The file '+filenames[9]+' generated an error. Reverting to the default file, '+filenames_default[9])
    data_index_set = pd.read_csv(filenames_default[9],index_col=False)
    index_types = data_index_set['Index_Name'].unique()

# Read ammonia export curve, add export curve to database
# Try to use the given filename. If not compatible, revert to the default filename.
try:
    NH3_export_df = pd.read_csv(filenames[10],index_col=False)
    NH3_export_df.to_sql('NH3 Exports',con=engine, if_exists='replace', index=False)
except ValueError:
    print('The file '+filenames[10]+' generated an error. Reverting to the default file, '+filenames_default[10])
    NH3_export_df = pd.read_csv(filenames_default[10],index_col=False)
    NH3_export_df.to_sql('NH3 Exports',con=engine, if_exists='replace', index=False)


#At end copy to h2_inputs.db, the default so it is always the latest created


#indices

# loop over all indices, create dataframe 
for indx in index_types:
    set_index = data_index_set[data_index_set['Index_Name']== indx]
    #dont need first column
    set_index = set_index.iloc[: , 1:]
    set_index.to_sql(indx,con=engine, if_exists='replace', index=False)
    
#data_index_set.to_sql('index_data',con=engine, if_exists='replace', index=False)

# Extract index types from mapping file
# Try to use the given filename. If not compatible, revert to the default filename.
try:
    df_mappings = pd.read_csv (filenames[11])
    index_types = df_mappings['Component'].unique()
except ValueError:
    print('The file '+filenames[11]+' generated an error. Reverting to the default file, '+filenames_default[11])
    df_mappings = pd.read_csv (filenames_default[11])
    index_types = df_mappings['Component'].unique()


# loop over all indices, create dataframe 
for indx in index_types:
    df_set_index = df_mappings[df_mappings['Component']== indx]
    #dont need first column
    df_set_index = df_set_index.iloc[: , 1:]
#    df_set_index = df_set_index.rename(columns={0:"From_region",1:"To_Region"})
    df_set_index.to_sql(indx,con=engine, if_exists='replace', index=False)

# Read policies data into two tables
# Try to use the given filename. If not compatible, revert to the default filename.
try:
    HMM_policies_df = pd.read_csv(filenames[12],index_col=False)
    index_types = HMM_policies_df['Policy'].unique()
except ValueError:
    print('The file '+filenames[12]+' generated an error. Reverting to the default file, '+filenames_default[12])
    HMM_policies_df = pd.read_csv(filenames_default[12],index_col=False)
    index_types = HMM_policies_df['Policy'].unique()


# loop over all indices, create dataframe 
for indx in index_types:
    df_set_index = HMM_policies_df[HMM_policies_df['Policy']== indx]
    #dont need first column
    df_set_index = df_set_index.iloc[: , 1:]
#    df_set_index = df_set_index.rename(columns={0:"From_region",1:"To_Region"})
    df_set_index.to_sql(indx,con=engine, if_exists='replace', index=False)

# PRODUCTION
# Create table of production technologies
prodtechs=list(data_prod_df)
prodtechs=prodtechs[3:]
prodtechs_df=pd.DataFrame(prodtechs)
prodtechs_df=prodtechs_df.rename(columns={0:"tech"})
prodtech_rows=prodtechs_df.to_sql('prod_tech', con=engine, if_exists='replace', index=False)
#prodtech_write=engine.execute("SELECT * FROM prod_tech").fetchall()

# Create tables of production technology specifications and their units
prodtech_specs=data_prod_df.index
prodtech_specs_df=pd.DataFrame(prodtech_specs)
prodtech_specs_df=prodtech_specs_df.rename(columns={0:"spec"})
prodtech_specs_rows=prodtech_specs_df.to_sql('prodtechspecs', con=engine, if_exists='replace', index=False)
#prodtech_specs_write=engine.execute("SELECT * FROM prodtechspecs").fetchall()

produnits=data_prod_df.iloc[:,[2,]]
produnits=produnits.rename(columns={"index":"spec"})
produnits_rows=produnits.to_sql('prodspecunits', con=engine, if_exists='replace', index_label='spec')
#produnits_write=engine.execute("SELECT * FROM prodspecunits").fetchall()

# Create table of all production data
prod_data=data_prod_df.loc[:,prodtechs]
prod_data_tb=pd.melt(prod_data.reset_index(),id_vars='index',var_name="tech")
prod_data_tb=prod_data_tb.rename(columns={"index":"spec"})
prod_data_rows=prod_data_tb.to_sql('prod_tech_props', con=engine, if_exists='replace')
#prod_data_write=engine.execute("SELECT * FROM prod_tech_props").fetchall()

# Create table of production capacity
# Try to use the given filename. If not compatible, revert to the default filename.
indx="Production Capacity"
try:
    prod_capacity = pd.read_csv(filenames[13],index_col=False)
    prod_capacity.to_sql(indx,con=engine, if_exists='replace', index=False)
except ValueError:
    print('The file '+filenames[13]+' generated an error. Reverting to the default file, '+filenames_default[13])
    prod_capacity = pd.read_csv(filenames_default[13],index_col=False)
    prod_capacity.to_sql(indx,con=engine, if_exists='replace', index=False)

# Create table of NH3 production capacity
# Try to use the given filename. If not compatible, revert to the default filename.
indx="NH3 Production Capacity"
try:
    prod_capacity = pd.read_csv(filenames[14],index_col=False)
    prod_capacity.to_sql(indx,con=engine, if_exists='replace', index=False)
except ValueError:
    print('The file '+filenames[14]+' generated an error. Reverting to the default file, '+filenames_default[14])
    prod_capacity = pd.read_csv(filenames_default[14],index_col=False)
    prod_capacity.to_sql(indx,con=engine, if_exists='replace', index=False)

# Create table of ammonia  production technologies
prodtechs_NH3=list(data_prod_NH3_df)
prodtechs_NH3=prodtechs_NH3[3:]
prodtechs_NH3_df=pd.DataFrame(prodtechs_NH3)
prodtechs_NH3_df=prodtechs_NH3_df.rename(columns={0:"tech"})
prodtech_rows=prodtechs_NH3_df.to_sql('NH3_prod_tech', con=engine, if_exists='replace', index=False)
#prodtech_write=engine.execute("SELECT * FROM NH3_prod_tech").fetchall()

#table of Ammonia production tech parameters
prod_data=data_prod_NH3_df.loc[:,prodtechs_NH3]
prod_data_tb=pd.melt(prod_data.reset_index(),id_vars='index',var_name="tech")
prod_data_tb=prod_data_tb.rename(columns={"index":"spec"})
prod_data_rows=prod_data_tb.to_sql('NH3_prod_tech_props', con=engine, if_exists='replace')
#prod_data_write=engine.execute("SELECT * FROM NH3_prod_tech_props").fetchall()

# STORAGE
# Create table of storage technologies
stortechs=list(data_stor_df)
stortechs=stortechs[3:]
stortechs_df=pd.DataFrame(stortechs)
stortechs_df=stortechs_df.rename(columns={0:"tech"})
stortech_rows=stortechs_df.to_sql('stor_tech', con=engine, if_exists='replace', index=False)
#stortech_write=engine.execute("SELECT * FROM stor_tech").fetchall()

# Create tables of storage technology specifications and their units
stortech_specs=data_stor_df.index
stortech_specs_df=pd.DataFrame(stortech_specs)
stortech_specs_df=stortech_specs_df.rename(columns={0:"spec"})
stortech_specs_rows=stortech_specs_df.to_sql('stortechspecs', con=engine, if_exists='replace', index=False)
#stortech_specs_write=engine.execute("SELECT * FROM stortechspecs").fetchall()

storunits=data_stor_df.iloc[:,[2,]]
storunits=storunits.rename(columns={"index":"spec"})
storunits_rows=storunits.to_sql('storspecunits', con=engine, if_exists='replace', index_label='spec')
#storunits_write=engine.execute("SELECT * FROM storspecunits").fetchall()

# Create table of all storage data
stor_data=data_stor_df.loc[:,stortechs]
stor_data_tb=pd.melt(stor_data.reset_index(),id_vars='index',var_name="tech")
stor_data_tb=stor_data_tb.rename(columns={"index":"spec"})
stor_data_rows=stor_data_tb.to_sql('stor_tech_props', con=engine, if_exists='replace')
#stor_data_write=engine.execute("SELECT * FROM stor_tech_props").fetchall()

# Create table of storage capacity
# Try to use the given filename. If not compatible, revert to the default filename.
indx="Storage Capacity"
try:
    storage_capacity = pd.read_csv(filenames[15],index_col=False)
    storage_capacity.to_sql(indx,con=engine, if_exists='replace', index=False)
except ValueError:
    print('The file '+filenames[15]+' generated an error. Reverting to the default file, '+filenames_default[15])
    storage_capacity = pd.read_csv(filenames_default[15],index_col=False)
    storage_capacity.to_sql(indx,con=engine, if_exists='replace', index=False)

#COMPRESSOR
# Create table of compressor technologies
comptechs=list(data_comp_df)
comptechs=comptechs[3:]
comptechs_df=pd.DataFrame(comptechs)
comptechs_df=comptechs_df.rename(columns={0:"tech"})
comptech_rows=comptechs_df.to_sql('comp_tech', con=engine, if_exists='replace', index=False)
#comptech_write=engine.execute("SELECT * FROM comp_tech").fetchall()

# Create tables of compressor technology specifications and their units
comptech_specs=data_comp_df.index
comptech_specs_df=pd.DataFrame(comptech_specs)
comptech_specs_df=comptech_specs_df.rename(columns={0:"spec"})
comptech_specs_rows=comptech_specs_df.to_sql('comptechspecs', con=engine, if_exists='replace', index=False)
#comptech_specs_write=engine.execute("SELECT * FROM comptechspecs").fetchall()

compunits=data_comp_df.iloc[:,[2,]]
compunits=compunits.rename(columns={"index":"spec"})
compunits_rows=compunits.to_sql('compspecunits', con=engine, if_exists='replace', index_label='spec')
#comopunits_write=engine.execute("SELECT * FROM compspecunits").fetchall()

# Create table of all conpressor data
comp_data=data_comp_df.loc[:,comptechs]
comp_data_tb=pd.melt(comp_data.reset_index(),id_vars='index',var_name="tech")
comp_data_tb=comp_data_tb.rename(columns={"index":"spec"})
comp_data_rows=comp_data_tb.to_sql('comp_tech_props', con=engine, if_exists='replace')
#comp_data_write=engine.execute("SELECT * FROM comp_tech_props").fetchall()


#PIPELINES
# Organize pipeline data
pipetechs=list(data_pipe_df)
pipetechs=pipetechs[3:]
#pipetechs_df=pd.DataFrame(pipetechs)
#pipetechs_df=pipetechs_df.rename(columns={0:"tech"})
#pipetech_rows=pipetechs_df.to_sql('pipe_tech', con=engine, if_exists='replace', index=False)
#pipetech_write=engine.execute("SELECT * FROM pipe_tech").fetchall()

# Create tables of pipeline specifications and their units
pipetech_specs=data_pipe_df.index
pipetech_specs_df=pd.DataFrame(pipetech_specs)
pipetech_specs_df=pipetech_specs_df.rename(columns={0:"spec"})
pipetech_specs_rows=pipetech_specs_df.to_sql('pipetechspecs', con=engine, if_exists='replace', index=False)
#pipetech_specs_write=engine.execute("SELECT * FROM pipetechspecs").fetchall()

pipeunits=data_pipe_df.iloc[:,[2,]]
pipeunits=pipeunits.rename(columns={"index":"spec"})
pipeunits_rows=pipeunits.to_sql('pipespecunits', con=engine, if_exists='replace', index_label='spec')
#pipeunits_write=engine.execute("SELECT * FROM pipespecunits").fetchall()

# Create table of all pipeline data
pipe_data=data_pipe_df.loc[:,pipetechs]
pipe_data_tb=pd.melt(pipe_data.reset_index(),id_vars='index',var_name="tech")
pipe_data_tb=pipe_data_tb.rename(columns={"index":"spec"})
pipe_data_rows=pipe_data_tb.to_sql('pipe_tech_props', con=engine, if_exists='replace')
#pipe_data_write=engine.execute("SELECT * FROM pipe_tech_props").fetchall()
    
# Create table of transportation capacity
# Try to use the given filename. If not compatible, revert to the default filename.
indx="Transportation Capacity"
try:
    pipe_capacity = pd.read_csv(filenames[16],index_col=False)
    pipe_capacity.to_sql(indx,con=engine, if_exists='replace', index=False)
except ValueError:
    print('The file '+filenames[16]+' generated an error. Reverting to the default file, '+filenames_default[16])
    pipe_capacity = pd.read_csv(filenames_default[16],index_col=False)
    pipe_capacity.to_sql(indx,con=engine, if_exists='replace', index=False)


#MACRS DEPRECIATION
# Organize MACRS Dep Periods
macrs=list(data_macrs_df)
macrs=macrs[0:]
#macrs_df =pd.DataFrame(macrs)
#macrs=macrs_df.rename(columns={0:"tech"})
#macrs_rows=macrs_df.to_sql('macrs', con=engine, if_exists='replace', index=False)
#macrs_write=engine.execute("SELECT * FROM macrs").fetchall()

# Create table of all MACRS data
macrs_data=data_macrs_df.loc[:,macrs]
macrs_data_tb=pd.melt(macrs_data.reset_index(),id_vars='index',var_name="MACRS Depreciation Period")
macrs_data_tb=macrs_data_tb.rename(columns={"index":"Year"})
macrs_data_rows=macrs_data_tb.to_sql('dep_macrs_props', con=engine, if_exists='replace')
#macrs_data_write=engine.execute("SELECT * FROM dep_macrs_props").fetchall()


##150% DECLINING DEPRECIATION
# Organize 150% Dep Periods
d150=list(data_d150_df)
d150=d150[0:]
#d150_df =pd.DataFrame(d150)
#d150=d150_df.rename(columns={0:"tech"})
#d150_rows=d150_df.to_sql('d150', con=engine, if_exists='replace', index=False)
#d150_write=engine.execute("SELECT * FROM d150").fetchall()

# Create table of all d150 data
d150_data=data_d150_df.loc[:,d150]
d150_data_tb=pd.melt(d150_data.reset_index(),id_vars='index',var_name="150% Depreciation Period")
d150_data_tb=d150_data_tb.rename(columns={"index":"Year"})
d150_data_rows=d150_data_tb.to_sql('dep_150_props', con=engine, if_exists='replace')
#d150_data_write=engine.execute("SELECT * FROM dep_150_props").fetchall()


#STRAIGHTLINE DEPRECIATION
# Organize Straightline Dep Periods
sl=list(data_sl_df)
sl=sl[0:]
#sl_df =pd.DataFrame(sl)
#sl=sl_df.rename(columns={0:"tech"})
#sl_rows=sl_df.to_sql('sl', con=engine, if_exists='replace', index=False)
#sl_write=engine.execute("SELECT * FROM sl").fetchall()

# Create table of all Straightline data
sl_data=data_sl_df.loc[:,sl]
sl_data_tb=pd.melt(sl_data.reset_index(),id_vars='index',var_name="Straightline Depreciation Period")
sl_data_tb=sl_data_tb.rename(columns={"index":"Year"})
sl_data_rows=sl_data_tb.to_sql('dep_sl_props', con=engine, if_exists='replace')
#sl_data_write=engine.execute("SELECT * FROM dep_sl_props").fetchall()

engine.dispose()

#copy to file h2_inputs.db so always using latest even if not using
# NEMS scedes
shutil.copy2(dbname + '.db', dbname_orig)

# Announce creation of database
print('\nDatabase has been created as '+filenames[17])