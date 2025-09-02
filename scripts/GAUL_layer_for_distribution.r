####################################################################################################
# EFSA Koppen-Geiger climate suitability tool
# This script load relevant administrative boundary layers from different sources and at 
# different administrative resolution
####################################################################################################
# -------------------
# Clean environment
# -------------------
rm(list=ls())
gc()
library(dplyr)

# set main directories
output_dir    <- "outputs\\FAO_GAUL\\"
input_dir     <- "data\\raw\\FAO_GAUL\\"
data_dir      <- "Data\\"

# set geometry simplification tolerance
i_tolerance=0.01

# set list of federated countries
fed_countries_list <- c("Canada", "United States of America", "Brazil", "Russian Federation", "India", "China", "Australia")

# set fields to keep for gaul attribute tables
colnames_to_keep <- c("iso3_code",
                      "continent",
                      "disp_en",
                      "fed_country",
                      "gaul0_code", "gaul0_name",
                      "gaul1_code", "gaul1_name", 
                      "gaul2_code", "gaul2_name",
                      "gaul_code", "gaul_name", "gaul_level")



# load functions
source("scripts\\fun_generate_EFSA_pest_distribution_layer.r")
source("scripts\\fun_standardise_fao_gaul_attribute_tables.r")

# Open raw datasets
# FAO GAUL
# open fao GAUL 1 and 2
gaul1_raw <- terra::vect(paste0(input_dir,"GAUL_2024_L1\\GAUL_2024_L1.shp"))
gaul2_raw <- terra::vect(paste0(input_dir,"GAUL_2024_L2\\GAUL_2024_L2.shp"))

# CREATE GAUL 0
# aggregate to create GAUL level 0
gaul0_raw <- terra::aggregate(gaul1_raw, by=c("iso3_code", "map_code", "gaul0_code"))

# clone data in order to not touch raw data
gaul0 <- gaul0_raw
gaul1 <- gaul1_raw
gaul2 <- gaul2_raw
rm(gaul0_raw, gaul1_raw, gaul2_raw)
# add common columns for admin codes and names
gaul0$gaul_code <- gaul0$gaul0_code
gaul0$gaul_name <- gaul0$gaul0_name
gaul0$gaul_level <- 0
gaul1$gaul_code <- gaul1$gaul1_code
gaul1$gaul_name <- gaul1$gaul1_name
gaul1$gaul_level <- 1
gaul2$gaul_code <- gaul2$gaul2_code
gaul2$gaul_name <- gaul2$gaul2_name
gaul2$gaul_level <- 2

# add missing columns
gaul0 <- standardise_attribute_table(colnames_to_keep, gaul0)
gaul1 <- standardise_attribute_table(colnames_to_keep, gaul1)
gaul2 <- standardise_attribute_table(colnames_to_keep, gaul2)

# specify in dedicated field if admin unit is in a federated country or not
gaul0$fed_country <- gaul0$gaul0_name %in% fed_countries_list
gaul1$fed_country <- gaul1$gaul0_name %in% fed_countries_list
gaul2$fed_country <- gaul2$gaul0_name %in% fed_countries_list

# Create one single layer including all administrative levels
fao_gaul_all_levels <- rbind(gaul0, gaul1, gaul2)

# Create a field inclduing gaul1 for federated countries or gaul0 for not federated countries
# this field is a service field to be used when mapping pest distribution
fao_gaul_all_levels$gaul_distribution_code <- NA

# Add gaul_distribution_code to attribute table
# terra::values(fao_gaul_all_levels)$gaul_distribution_code <- ifelse(terra::values(fao_gaul_all_levels)$fed_country,
#                                                                     terra::values(fao_gaul_all_levels)$gaul1_code, # when TRUE
#                                                                     terra::values(fao_gaul_all_levels)$gaul0_code)   # when FALSE
# 
# add gaul_distribution_code and gaul_distribution_name
attr_table <- terra::values(fao_gaul_all_levels)

attr_table <- attr_table %>%
  mutate(gaul_distribution_code = case_when(
    fed_country & !is.na(gaul1_code) ~ gaul1_code,
    TRUE                             ~ gaul0_code
  )) %>%
  mutate(gaul_distribution_name = case_when(
    fed_country & !is.na(gaul1_name) ~ gaul1_name,
    TRUE                             ~ gaul0_name
  ))

terra::values(fao_gaul_all_levels) <- attr_table

# # Add gaul_distribution_code
# fao_gaul_all_levels$gaul_distribution_name <- ifelse(fao_gaul_all_levels$fed_country,
#                                       fao_gaul_all_levels$gaul1_name,   # when TRUE
#                                       fao_gaul_all_levels$gaul0_name)   # when FALSE

# create EFSA pest distribution base layer
efsa_pest_distribution_layer <- 
  generate_efsa_pest_distribution_layer(fed_countries_list, gaul1, gaul0)

# simplify layers using user defined tolerance
efsa_pest_distribution_layer_simpl <- terra::simplifyGeom(efsa_pest_distribution_layer, tolerance=i_tolerance, preserveTopology=TRUE, makeValid=TRUE)
gaul0_simpl                        <- terra::simplifyGeom(gaul0, tolerance=i_tolerance, preserveTopology=TRUE, makeValid=TRUE)
gaul1_simpl                        <- terra::simplifyGeom(gaul1, tolerance=i_tolerance, preserveTopology=TRUE, makeValid=TRUE)
gaul2_simpl                        <- terra::simplifyGeom(gaul2, tolerance=i_tolerance, preserveTopology=TRUE, makeValid=TRUE)
fao_gaul_all_levels_simpl          <- terra::simplifyGeom(fao_gaul_all_levels, tolerance=i_tolerance, preserveTopology=TRUE, makeValid=TRUE)

# write layers in geojson
terra::writeVector(gaul0_simpl , paste0(output_dir, "GAUL_2024_L0_simpl",i_tolerance,".geojson") , filetype = "GeoJSON", overwrite = TRUE)
terra::writeVector(gaul1_simpl , paste0(output_dir, "GAUL_2024_L1_simpl",i_tolerance,".geojson") , filetype = "GeoJSON", overwrite = TRUE)
terra::writeVector(gaul2_simpl , paste0(output_dir, "GAUL_2024_L2_simpl",i_tolerance,".geojson") , filetype = "GeoJSON", overwrite = TRUE)
terra::writeVector(fao_gaul_all_levels_simpl , paste0(output_dir, "GAUL_FULL_simpl",i_tolerance,".geojson") , filetype = "GeoJSON", overwrite = TRUE)
terra::writeVector(efsa_pest_distribution_layer_simpl, paste0(output_dir, "EFSA_pest_distribution_layer_simpl005.geojson") , filetype = "GeoJSON", overwrite = TRUE)

# dataframe including all codes and names of all gaul administrative levels 
FAO_GAUL_full_table <- as.data.frame(fao_gaul_all_levels)

# replace "," with "_" to avoid reading file issues
FAO_GAUL_full_table <- FAO_GAUL_full_table %>%
  mutate(across(where(is.character), ~ gsub(",", "_", .)))

# write csv and xlsx
write.csv(FAO_GAUL_full_table, file = paste0(output_dir, "FAO_GAUL_admin_table.csv"), row.names = FALSE)
openxlsx::write.xlsx(FAO_GAUL_full_table, paste0(output_dir, "FAO_GAUL_admin_table.xlsx"))

