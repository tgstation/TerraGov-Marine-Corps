import json
import pandas as pd
import numpy as np

#this code is based on Python 3.7.4
#this code works with Pandas 1.0.3
#as such this may not work with newer/older versions.

#where the json data file is.
path = r"D:\Documents\GitHub\TerraGov-Marine-Corps\tools\Balance Tool\peanuts.json"

normal_data = {}

#hey PsyKzz you a cool dude who figured this part out.
#this loads the entire JSON datafile, properly.
with open(path) as fh:
    data = json.loads(fh.read())
    data_to_process = [data]
    while(data_to_process):
            current = data_to_process.pop()
            for child in current.get('children', []):
                data_to_process.append(child)

            normal_data[current['path']] = { item['name']: item['value'] for item in current['vars']}

    #print(len(normal_data))

#all the json data goes into a dataframe.
#at this point columns are typepaths
#vars are rows.
#since not all typepaths use ALL vars. we might need to do some filtering.
df = pd.DataFrame(normal_data)

def generateCSV(typePath, filePathName, dataframe):

	#here's where you can reduce the number of typepaths
	#perhaps you want certain sections vs other sections
	#weapon vs mob comes to mind.
	dataframe = dataframe.loc[:, dataframe.columns.str.startswith(typePath)]

	#I prefer to have the typepaths as rows rather than columns.
	dataframe = dataframe.transpose()

	#since we've got PLENTY of null columns, might as well drop them.
	#drop them only if they are completely empty.
	dataframe = dataframe.dropna(axis = 1, how = 'all')

	#lastly, output to csv for data visualization and manipulation.
	dataframe.to_csv(filePathName)


#you can copy this set of variables multiple times if you want to output multiple csv
#change this to be the group you desire
typePath = r'/obj/item/clothing/suit'
#change this to at least be a different filename otherwise it will just keep overwriting.
filePathName = r"D:\Downloads\exo_suit.csv"
generateCSV(typePath, filePathName, df)
