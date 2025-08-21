# setting download par
# URL del file .zip contenente il shapefile, 
#source: Global Administrative Unit Layers (GAUL 2015) - Global Administrative Unit Layers (GAUL 2015) - "FAO catalog"
import os

# URL dei file .zip contenenti i shapefiles
url_15 = "https://storage.googleapis.com/fao-maps-catalog-data/boundaries/g2015_2014_2.zip"
url_24 = "https://storage.googleapis.com/fao-maps-catalog-data/boundaries/GAUL_2024_L2.zip"

#set working directory
wk_path = "C:/Users/morench/EFSA/PLH GeoCLIM - Documents/GIS/administrative_units"
raw_data = "C:/Users/morench/EFSA/PLH GeoCLIM - Documents/GIS/administrative_units/data/raw/FAO_GAUL"
output = "C:/Users/morench/EFSA/PLH GeoCLIM - Documents/GIS/administrative_units/data/processed"

# File zip path
zip_path_24 = os.path.join(raw_data,"zip/GAUL_2024_L2.zip")
zip_path_15 = os.path.join(raw_data,"zip/g2015_2014_2.zip")

# destination path
zip_ref_24_folder = os.path.join(raw_data,"GAUL_2024_L2")
zip_ref_15_folder = os.path.join(raw_data,"g2015_2014_2")

# shapefile
shp_24 = os.path.join(zip_ref_24_folder,"GAUL_2024_L2.shp")
shp_15 = os.path.join(zip_ref_15_folder, "g2015_2014_2.shp")

# output folders
processed_folder = os.path.join(output, "C:/Users/morench/EFSA/PLH GeoCLIM - Documents/GIS/administrative_units/data/processed")
output_folder = os.path.join(output, "C:/Users/morench/EFSA/PLH GeoCLIM - Documents/GIS/administrative_units/outputs/FAO_GAUL")