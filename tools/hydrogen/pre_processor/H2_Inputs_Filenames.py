# -*- coding: utf-8 -*-
"""
Spyder Editor

This script handles the interface tool for selecting data files to include into the H2 inputs .db database.

"""


import numpy as np
import os

def assign_filenames(filenames_default):
    
    # Default filenames are copied to generate the list presented in the interface tool. This list will update with user prompts.
    filenames = filenames_default.copy()
    filenames_replace = np.full(18, False, dtype=bool)
    
    # Input list is the valid list of user entries. Complete is a flag to break the while loop.
    input_list = ['1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18']
    complete = 0
    
    # While loop controls the interface tool operation
    while complete == 0:
        # Formatting and printing of interface text table
        input_table = [['#','Description','Current Filename'],
                        ['1','H2 Production',filenames[0]],
                        ['2','H2 Pipeline',filenames[1]],
                        ['3','H2 Storage',filenames[2]],
                        ['4','H2 Compressor',filenames[3]],
                        ['5','Ammonia Production',filenames[4]],
                        ['6','MARCS Depreciation',filenames[5]],
                        ['7','Straightline Depreciation',filenames[6]],
                        ['8','150% Depreciation',filenames[7]],
                        ['9','Straightline Depreciation',filenames[8]],
                        ['10','Index Tables',filenames[9]],
                        ['11','Ammonia Export',filenames[10]],
                        ['12','Mappings',filenames[11]],
                        ['13','Policies',filenames[12]],
                        ['14','Production Capacity',filenames[13]],
                        ['15','NH3 Production Capacity',filenames[14]],
                        ['16','Storage Capacity',filenames[15]],
                        ['17','Transportation Capacity',filenames[16]],
                        ['18','Database',filenames[17]]]
        print('\nH2 Inputs Interface\n')
        print('You may change any of the filenames:\n\n')
        for row in input_table:
            print("{: <5} {: <30} {: <65}".format(*row))
        
        # Prompt user for number
        print('\nEnter a number from 1 to 18 to select your file. \nEnter 0 to finish and create the database. \nPress cntl-c to quit.')
        i = input('\nPlease type a number to select the variable ==>')
        
        # If the user enters 0, quit the interface tool
        if i == '0':
            input('\nYou are creating a database. Press enter to continue. Press cntl-c to quit.')
            complete= 1
            break
        # If user enters a valid number, continue
        elif i in input_list:
            # Prompt for filename
            newfile = input('\nYou have selected '+i+': '+input_table[int(i)][1]+
                            '. Please enter a corresponding filename (with extension) ==>')
            # If the user enters 0, quit the interface tool
            if newfile == '0':
                input('You are creating a database. Press enter to continue. Press cntl-c to quit.')
                complete= 1
                break
            # Invalid entry - prompt user and restart the while loop
            elif (i != '18') & (not(os.path.exists(newfile))):
                print(i)
                print(newfile)
                input('The file does not exist. Press enter to return to the main table.\n')
            # Valid entry: replace filename in the list. Flag that the file has been replaced.
            else:
                filenames[int(i)-1] = newfile
                filenames_replace[int(i)-1] = True
                input('Your new filename is '+newfile+'. Press enter to continue.\n')
        # Invalid entry - prompt user and restart the while loop
        else:
            input('\nInvalid entry - press enter to continue.\n')
    
    # Create database
    dbname = filenames[17][0:-3]
    
    # Write all updated filenames into a changelog appending as we go
    with open('H2_inputs_changelog.txt', 'a') as f:
        # If no changes from the default files, then indicate it in the change log
        if np.sum(filenames_replace) == 0:
            f.write('No Changes\n')
        # If there are changes, then set up a formatted data table in the changelog
        else:
            output_table = [['#','Original Filename','Updated Filename']]
            f.write("{: <5} {: <65} {: <65}".format(*output_table[0]))
            # Iterate through each change and report in the changelog
            for i in np.where(filenames_replace)[0]:
                output_table.append([str(i+1),filenames_default[i],filenames[i]])
                f.write("\n{: <5} {: <65} {: <65}".format(*output_table[-1]))
    
    # Return the updated filenames and the name of the new database    
    return(filenames,dbname)
