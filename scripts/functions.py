# Import Python packages

import requests
import pandas as pd
import geopandas as gpd
import zipfile
import os
import re
import unicodedata
import numpy as np

# Define a function to download and extract shapefile

def GaulDownload(url, zip_path, zip_ref_folder, shp):
    """
    Download from an url, extract and create a GeoDataFrame from a .shp
    """
    gdf = None
    response = requests.get(url)
    #check if the request was successful
    if response.status_code == 200:
        with open(zip_path, 'wb') as file:
            file.write(response.content)
    # Extract the zip file
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            if not os.path.exists(zip_ref_folder):
                os.makedirs(zip_ref_folder)
            zip_ref.extractall(zip_ref_folder)
        # Read the shapefile into a GeoDataFrame
        shapefile_path = shp
        gdf = gpd.read_file(shapefile_path)
    
    return gdf

#Define e function to aggregate the Dataframe

def aggregate_DataFrame(df):
    #split the dataframe in 3 levels
    gaul0 = df[["gaul0_code", "gaul0_name"]]
    gaul1 = df[["gaul0_code", "gaul0_name", "gaul1_code", "gaul1_name"]] 
    gaul2 = df[["gaul0_code", "gaul0_name", "gaul1_code", "gaul1_name", "gaul2_code", "gaul2_name"]]
    #merge levels
    df_new = pd.concat([gaul0, gaul1, gaul2], ignore_index=True, sort=False).drop_duplicates()
    # fil out empty values
    df_new.replace("", np.nan, inplace=True)
    
    return df_new

# Define a function to eliminate special characters from a strings

def normalize_str(s):
    """
    remove special carachters and uppercase
    """
    #Remove accents and special characters
    s = unicodedata.normalize('NFKD', str(s)).encode('ASCII', 'ignore').decode('utf-8')
    # Remove non-alphanumeric characters
    s = re.sub(r'[^a-zA-Z0-9]', '', s)
    #Convert to lowercase
    return s.lower()

# Define a function to normalize GAUL levels

def norm_gaul_levels(df):
    """
    merge all levels
    """
    # Split the DataFrame into three levels and normalize
    gaul0 = pd.DataFrame({
        "gaul_code": df["gaul0_code"],
        "gaul_name": df["gaul0_name"],
        "ADM_CODE": df["ADM0_CODE"] if "ADM0_CODE" in df.columns else None,
        "ADM_NAME": df["ADM0_NAME"] if "ADM0_NAME" in df.columns else None,
        "livello": 0
    })

    gaul1 = pd.DataFrame({
        "gaul_code": df["gaul1_code"],
        "gaul_name": df["gaul1_name"],
        "ADM_CODE": df["ADM1_CODE"] if "ADM1_CODE" in df.columns else None,
        "ADM_NAME": df["ADM1_NAME"] if "ADM1_NAME" in df.columns else None,
        "livello": 1
    })

    gaul2 = pd.DataFrame({
        "gaul_code": df["gaul2_code"],
        "gaul_name": df["gaul2_name"],
        "ADM_CODE": df["ADM2_CODE"] if "ADM2_CODE" in df.columns else None,
        "ADM_NAME": df["ADM2_NAME"] if "ADM2_NAME" in df.columns else None,
        "livello": 2,
        "distance": df["distance"] if "distance" in df.columns else None
    })
    
    df_all = pd.concat([gaul0, gaul1, gaul2], ignore_index=True).drop_duplicates()
    df_all["join_col"] = df_all["gaul_name"].apply(normalize_str)
    df_all["JOIN_COL)"] = df_all["ADM_NAME"].apply(normalize_str) if "ADM_NAME" in df_all.columns else None

    return df_all
