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

output.dir    <- "outputs\\FAO_GAUL\\"
input.dir     <- "data\\raw\\FAO_GAUL\\"
data.dir      <- "Data\\"

# vector simplification tolerance
i.tolerance=0.01

# Open raw datasets
# FAO GAUL
dir.fao.l1 <- paste0()
dir.fao.l2 <- paste0()
# open fao GAUL 1 and 2
FAO.GAUL1 <- terra::vect(paste0(input.dir,"GAUL_2024_L1\\GAUL_2024_L1.shp"))
FAO.GAUL2 <- terra::vect(paste0(input.dir,"GAUL_2024_L2\\GAUL_2024_L2.shp"))

# CREATE GAUL 0
# aggregate to create GAUL level 0
GAUL0 <- terra::aggregate(FAO.GAUL1, by=c("iso3_code", "map_code", "gaul0_code"))

# add common columns for admin codes and names
GAUL0$gaul_code <- GAUL0$gaul0_code
GAUL0$gaul_name <- GAUL0$gaul0_name
GAUL0$gaul_level <- 0
FAO.GAUL1$gaul_code <- FAO.GAUL1$gaul1_code
FAO.GAUL1$gaul_name <- FAO.GAUL1$gaul1_name
FAO.GAUL1$gaul_level <- 1
FAO.GAUL2$gaul_code <- FAO.GAUL2$gaul2_code
FAO.GAUL2$gaul_name <- FAO.GAUL2$gaul2_name
FAO.GAUL2$gaul_level <- 2

# FEDERATED COUNTRIES LAYER
#list of federated countries
fed.countries <- c("Canada", "United States of America", "Brazil", "Russian Federation", "India", "China", "Australia")
# layer with federated countries
GAUL1.fed <- FAO.GAUL1[FAO.GAUL1$gaul0_name %in% fed.countries,]

# BUILD EFSA PEST DISTRIBUTION LAYER
# from GAUL 0 remove fed countries
GAUL0.no.fed.countries <- GAUL0[!(GAUL0$gaul0_name %in% fed.countries),]
#add column for single admin code and name
GAUL0.no.fed.countries$gaul_code <- GAUL0.no.fed.countries$gaul0_code
GAUL0.no.fed.countries$gaul_name <- GAUL0.no.fed.countries$gaul0_name

EFSA.admin.distribution <- rbind(GAUL0.no.fed.countries, GAUL1.fed)

# Create one single file inlcuding all levels
FAO.GAUL.colnames.to.keep <- c("iso3_code",  "map_code","continent", "disp_en", "gaul_code", "gaul_name", "gaul_level")
GAUL0 <- GAUL0[,FAO.GAUL.colnames.to.keep]
FAO.GAUL1 <- FAO.GAUL1[,FAO.GAUL.colnames.to.keep]
FAO.GAUL2 <- FAO.GAUL2[,FAO.GAUL.colnames.to.keep]

FAO.GAUL.full <- rbind(GAUL0, FAO.GAUL1, FAO.GAUL2)

# SIMPLIFY GEOMETRIES
EFSA.distribution.simpl <- terra::simplifyGeom(EFSA.admin.distribution, tolerance=i.tolerance, preserveTopology=TRUE, makeValid=TRUE)
GAUL0.simpl         <- terra::simplifyGeom(GAUL0, tolerance=i.tolerance, preserveTopology=TRUE, makeValid=TRUE)
GAUL1.simpl         <- terra::simplifyGeom(GAUL0, tolerance=i.tolerance, preserveTopology=TRUE, makeValid=TRUE)
GAUL2.simpl         <- terra::simplifyGeom(FAO.GAUL2, tolerance=i.tolerance, preserveTopology=TRUE, makeValid=TRUE)
FAO.GAUL.full.simpl <- terra::simplifyGeom(FAO.GAUL.full, tolerance=i.tolerance, preserveTopology=TRUE, makeValid=TRUE)

# write layers and RData files
terra::writeVector(GAUL0.simpl , paste0(output.dir, "GAUL_2024_L0_simpl",i.tolerance,".geojson") , filetype = "GeoJSON", overwrite = TRUE)
terra::writeVector(GAUL1.simpl , paste0(output.dir, "GAUL_2024_L1_simpl",i.tolerance,".geojson") , filetype = "GeoJSON", overwrite = TRUE)
terra::writeVector(GAUL2.simpl , paste0(output.dir, "GAUL_2024_L2_simpl",i.tolerance,".geojson") , filetype = "GeoJSON", overwrite = TRUE)
terra::writeVector(FAO.GAUL.full.simpl , paste0(output.dir, "FAO_GAUL_full_simpl",i.tolerance,".geojson") , filetype = "GeoJSON", overwrite = TRUE)
terra::writeVector(EFSA.distribution.simpl, paste0(output.dir, "EFSA_distribution_layer_simpl005.geojson") , filetype = "GeoJSON", overwrite = TRUE)

save(EFSA.distribution.simpl, file=paste0(output.dir, "EFSA_pest_distribution_layer.RData"))
save(GAUL0.simpl, GAUL1.simpl, GAUL2.simpl, file=paste0(output.dir, "FAO_GAUL_single_layers.RData"))
save(FAO.GAUL.full.simpl, file=paste0(output.dir, "FAO_GAUL_all_layers.RData"))

write.csv2(as.data.frame(FAO.GAUL.full), file = paste0(output.dir, "FAO.GAUL.admin.table.csv"), row.names = FALSE)

#terra::writeVector(GAUL.distribution, paste0(output.dir, "distribution.map.GAUL.full.geojson") , filetype = "GeoJSON", overwrite = TRUE)
#terra::writeVector(GAUL.distribution, paste0(dir.fao, "GAUL.EFSA") , filetype = "GeoJSON", overwrite = TRUE)

