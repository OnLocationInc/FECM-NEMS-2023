# -*- coding: utf-8 -*-
"""
Spyder Editor

This script takes several files (as indicated by the interface tool) and converts them to json.
If the given file is not compatible, the script will use the default file and warn the user.

"""


def h2_json(filenames,filenames_default):
        
    import pandas as pd
    
    #H2 Production
    # Import CSV input file and convert to json
    # To be used when user updates input data
    # Try to use the given filename. If not compatible, revert to the default filename.
    try:
        df_prod = pd.read_csv (filenames[0])
        df_prod.set_index('L2').to_json (r'H2_Prod_Inputs.json',orient='columns', indent=2)
    except ValueError:
        print('The file '+filenames[0]+' generated an error. Reverting to the default file, '+filenames_default[0])
        df_prod = pd.read_csv (filenames_default[0])
        df_prod.set_index('L2').to_json (r'H2_Prod_Inputs.json',orient='columns', indent=2)
        
        
    #H2 Pipeline 
    # Import CSV input file and convert to json
    # To be used when user updates input data
    # Try to use the given filename. If not compatible, revert to the default filename.
    try:
        df_pipe = pd.read_csv (filenames[1])
        df_pipe.set_index('L2').to_json (r'H2_Pipe_Inputs.json',orient='columns', indent=2)
    except ValueError:
        print('The file '+filenames[1]+' generated an error. Reverting to the default file, '+filenames_default[1])
        df_prod = pd.read_csv (filenames_default[1])
        df_prod.set_index('L2').to_json (r'H2_Pipe_Inputs.json',orient='columns', indent=2)
    
    
    #H2 Storage
    # Import CSV input file and convert to json
    # To be used when user updates input data
    # Try to use the given filename. If not compatible, revert to the default filename.
    try:
        df_stor = pd.read_csv (filenames[2])
        df_stor.set_index('L2').to_json (r'H2_Stor_Inputs.json',orient='columns', indent=2)
    except ValueError:
        print('The file '+filenames[2]+' generated an error. Reverting to the default file, '+filenames_default[2])
        df_stor = pd.read_csv (filenames_default[2])
        df_stor.set_index('L2').to_json (r'H2_Stor_Inputs.json',orient='columns', indent=2)
    
    
    #H2 Compressor 
    # Import CSV input file and convert to json
    # To be used when user updates input data
    # Try to use the given filename. If not compatible, revert to the default filename.
    try:
        df_comp = pd.read_csv (filenames[3])
        df_comp.set_index('L2').to_json (r'H2_Comp_Inputs.json',orient='columns', indent=2)
    except ValueError:
        print('The file '+filenames[3]+' generated an error. Reverting to the default file, '+filenames_default[3])
        df_comp = pd.read_csv (filenames_default[3])
        df_comp.set_index('L2').to_json (r'H2_Comp_Inputs.json',orient='columns', indent=2)

        
    #Ammonia Production
    # Import CSV input file and convert to json
    # To be used when user updates input data
    # Try to use the given filename. If not compatible, revert to the default filename.
    try:
        df_prod = pd.read_csv (filenames[4])
        df_prod.set_index('L2').to_json (r'NH3_Prod_Inputs.json',orient='columns', indent=2)
    except ValueError:
        print('The file '+filenames[4]+' generated an error. Reverting to the default file, '+filenames_default[4])
        df_prod = pd.read_csv (filenames_default[4])
        df_prod.set_index('L2').to_json (r'NH3_Prod_Inputs.json',orient='columns', indent=2)
    
    
    #MACRS Depreciation
    # Import CSV input file and convert to json
    # To be used when user updates input data
    # Try to use the given filename. If not compatible, revert to the default filename.
    try:
        df_marcs = pd.read_csv (filenames[5])
        df_marcs.set_index('Depreciation Period').to_json (r'Dep_MACRS_Inputs.json',orient='columns', indent=2)
    except ValueError:
        print('The file '+filenames[5]+' generated an error. Reverting to the default file, '+filenames_default[5])
        df_marcs = pd.read_csv (filenames_default[5])
        df_marcs.set_index('Depreciation Period').to_json (r'Dep_MACRS_Inputs.json',orient='columns', indent=2)
    
    
    #Straightline Depreciation
    # Import CSV input file and convert to json
    # To be used when user updates input data
    # Try to use the given filename. If not compatible, revert to the default filename.
    try:
        df_strln = pd.read_csv (filenames[6])
        df_strln.set_index('Depreciation Period').to_json (r'Dep_SL_Inputs.json',orient='columns', indent=2)
    except ValueError:
        print('The file '+filenames[6]+' generated an error. Reverting to the default file, '+filenames_default[6])
        df_strln = pd.read_csv (filenames_default[6])
        df_strln.set_index('Depreciation Period').to_json (r'Dep_SL_Inputs.json',orient='columns', indent=2)
    
    
    #150% Depreciation
    # Import CSV input file and convert to json
    # To be used when user updates input data
    # Try to use the given filename. If not compatible, revert to the default filename.
    try:
        df_150 = pd.read_csv (filenames[7])
        df_150.set_index('Depreciation Period').to_json (r'Dep_150_Inputs.json',orient='columns', indent=2)
    except ValueError:
        print('The file '+filenames[7]+' generated an error. Reverting to the default file, '+filenames_default[7])
        df_150 = pd.read_csv (filenames_default[7])
        df_150.set_index('Depreciation Period').to_json (r'Dep_150_Inputs.json',orient='columns', indent=2)

    
    #Straightline Depreciation
    # Import CSV input file and convert to json
    # To be used when user updates input data
    # Try to use the given filename. If not compatible, revert to the default filename.
    try:
        df_150 = pd.read_csv (filenames[8])
        df_150.set_index('Depreciation Period').to_json (r'Dep_150_Inputs.json',orient='columns', indent=2)
    except ValueError:
        print('The file '+filenames[8]+' generated an error. Reverting to the default file, '+filenames_default[8])
        df_150 = pd.read_csv (filenames_default[8])
        df_150.set_index('Depreciation Period').to_json (r'Dep_150_Inputs.json',orient='columns', indent=2)