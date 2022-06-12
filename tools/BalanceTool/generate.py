import os
import json
import tempfile
import pandas as pd
import numpy as np


def generate_raw_file(path):
    os.system(f'sdmmparser.exe ../../tgmc.dme {path}')


def parse_file(path):
    normalized = {}
    with open(path, encoding='utf8') as fh:
        data = json.loads(fh.read())
        data_to_process = [data]
        while(data_to_process):
            current = data_to_process.pop()
            for child in current.get('children', []):
                data_to_process.append(child)

            normalized[current['path']] = {
                item['name']: item['value'] for item in current['vars']}

    return normalized


def generate_csv(data, typePath, filePathName):
    dataframe = pd.DataFrame(data)
    dataframe = dataframe.loc[:, dataframe.columns.str.startswith(typePath)]
    dataframe = dataframe.transpose()
    dataframe = dataframe.dropna(axis=1, how='all')
    dataframe.to_csv(filePathName)


if __name__ == '__main__':

    print("""
______  ___   _       ___   _   _ _____  _____   _____ _____  _____ _     
| ___ \/ _ \ | |     / _ \ | \ | /  __ \|  ___| |_   _|  _  ||  _  | |    
| |_/ / /_\ \| |    / /_\ \|  \| | /  \/| |__     | | | | | || | | | |    
| ___ \  _  || |    |  _  || . ` | |    |  __|    | | | | | || | | | |    
| |_/ / | | || |____| | | || |\  | \__/\| |___    | | \ \_/ /\ \_/ / |____
\____/\_| |_/\_____/\_| |_/\_| \_/\____/\____/    \_/  \___/  \___/\_____/
                                                                          
""")
    temp_path = 'raw.json'

    generate_raw_file(temp_path)
    data = parse_file(temp_path)

    valid_paths = data.keys()
    found = False
    while not found:
        type_path = input("Enter a type path to generate csv: ")
        if type_path in valid_paths and any([path for path in valid_paths if path.startswith(type_path)]):
            found = True
        print("Invalid type path, not found.\n")

    print(f"Generating CSV for {type_path}")
    generate_csv(data, type_path, 'output.csv')
    os.remove(temp_path)
