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
library(yaml)

## Configuration
source("scripts/config_FAO_GAUL_admin_units.r")

## LOAD FUNCTIONS
source("scripts\\fun_generate_EFSA_pest_distribution_layer.r")
source("scripts\\fun_standardise_fao_gaul_attribute_tables.r")
source("scripts\\fun_rearrange_disputed_territories.r")
source("scripts\\fun_standardize_coding_system.r")

# Open raw datasets
# FAO GAUL
# open fao GAUL 1 and 2
gaul1 <- terra::vect(paste0(input_dir,"GAUL_2024_L1\\GAUL_2024_L1.shp"))
gaul2 <- terra::vect(paste0(input_dir,"GAUL_2024_L2\\GAUL_2024_L2.shp"))

# CREATE GAUL 0
# aggregate to create GAUL level 0
gaul0 <- terra::aggregate(gaul1, by=c("iso3_code", "map_code", "gaul0_code"))

gaul0 <- standardize_coding_system(gaul0, 0)
gaul1 <- standardize_coding_system(gaul1, 1)
gaul2 <- standardize_coding_system(gaul2, 2)

# add missing columns
gaul0 <- standardise_attribute_table(colnames_to_keep, gaul0)
gaul1 <- standardise_attribute_table(colnames_to_keep, gaul1)
gaul2 <- standardise_attribute_table(colnames_to_keep, gaul2)

# specify in fed_country field if admin unit is in a federated country or not
gaul0$fed_country <- gaul0$gaul0_name %in% fed_countries_list
gaul1$fed_country <- gaul1$gaul0_name %in% fed_countries_list
gaul2$fed_country <- gaul2$gaul0_name %in% fed_countries_list

# Create one single layer including all administrative levels
fao_gaul_all_levels <- rbind(gaul0, gaul1, gaul2)

# Create a field including gaul1 for federated countries or gaul0 for not federated countries
# this field is a service field to be used when mapping pest distribution
fao_gaul_all_levels$gaul_distribution_code <- NA

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

# create EFSA pest distribution base layer
efsa_pest_distribution_layer <- 
  generate_efsa_pest_distribution_layer(fed_countries_list, gaul1, gaul0)

# layer including disputed territories
disputed_territories <- terra::subset(efsa_pest_distribution_layer, efsa_pest_distribution_layer$gaul_name %in%
                                        list_disputed_territories)

efsa_pest_distribution_layer <- terra::makeValid(efsa_pest_distribution_layer)

# simplify layers using user defined tolerance
efsa_pest_distribution_layer_simpl <- terra::simplifyGeom(efsa_pest_distribution_layer, tolerance=i_tolerance, preserveTopology=TRUE, makeValid=TRUE)
gaul0_simpl                        <- terra::simplifyGeom(gaul0, tolerance=i_tolerance, preserveTopology=TRUE, makeValid=TRUE)
gaul1_simpl                        <- terra::simplifyGeom(gaul1, tolerance=i_tolerance, preserveTopology=TRUE, makeValid=TRUE)
gaul2_simpl                        <- terra::simplifyGeom(gaul2, tolerance=i_tolerance, preserveTopology=TRUE, makeValid=TRUE)
fao_gaul_all_levels_simpl          <- terra::simplifyGeom(fao_gaul_all_levels, tolerance=i_tolerance, preserveTopology=TRUE, makeValid=TRUE)


# aggregate (dissolve) disputed territories and related countries 
# This is done so that when the two layer are overlayed, the disputed territory can be shown with 
# dotted border
efsa_pest_distribution_layer_rearranged <- efsa_pest_distribution_layer_simpl
for(n_disputed_territories in 1:length(disputed_territories))
{# TEST: n_disputed_territories = 2
  disputed_territory <- list_disputed_territories[n_disputed_territories]
  related_disputed_country    <- list_related_countries[n_disputed_territories]
  
  efsa_pest_distribution_layer_rearranged <- rearrange_disputed_territories(disputed_territory, related_disputed_country, efsa_pest_distribution_layer_rearranged)
}

# write layers in geojson
terra::writeVector(gaul0_simpl , paste0(output_dir, "GAUL_2024_L0_simpl",i_tolerance,".geojson") , filetype = "GeoJSON", overwrite = TRUE)
terra::writeVector(gaul1_simpl , paste0(output_dir, "GAUL_2024_L1_simpl",i_tolerance,".geojson") , filetype = "GeoJSON", overwrite = TRUE)
terra::writeVector(gaul2_simpl , paste0(output_dir, "GAUL_2024_L2_simpl",i_tolerance,".geojson") , filetype = "GeoJSON", overwrite = TRUE)
terra::writeVector(fao_gaul_all_levels_simpl , paste0(output_dir, "GAUL_FULL_simpl",i_tolerance,".geojson") , filetype = "GeoJSON", overwrite = TRUE)
terra::writeVector(efsa_pest_distribution_layer_rearranged, paste0(output_dir, "EFSA_pest_distribution_dissolved_disputed_terr", i_tolerance,".geojson") , filetype = "GeoJSON", overwrite = TRUE)
terra::writeVector(disputed_territories, paste0(output_dir, "disputed_territories", i_tolerance,".geojson") , filetype = "GeoJSON", overwrite = TRUE)

# dataframe including all codes and names of all gaul administrative levels 
FAO_GAUL_full_table <- as.data.frame(fao_gaul_all_levels)

# replace "," with "_" to avoid reading file issues
FAO_GAUL_full_table <- FAO_GAUL_full_table %>%
  mutate(across(where(is.character), ~ gsub(",", "_", .)))

# write csv and xlsx
write.csv(FAO_GAUL_full_table, file = paste0(output_dir, "FAO_GAUL_admin_table.csv"), row.names = FALSE)
openxlsx::write.xlsx(FAO_GAUL_full_table, paste0(output_dir, "FAO_GAUL_admin_table.xlsx"))

