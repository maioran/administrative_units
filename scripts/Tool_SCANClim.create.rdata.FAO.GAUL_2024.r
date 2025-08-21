####################################################################################################
# EFSA Koppen-Geiger climate suitability tool
# This script load relevant administrative boundary layers from different sources and at 
# different administrative resolution
####################################################################################################
# ------------------
# Clean environment
# ------------------
rm(list=ls())
gc()
#library(sp)
#library(sf)

output.dir    <- "Output\\"
input.dir     <- "Data\\input\\"
data.dir      <- "Data\\"
gis.dir    <- paste(data.dir,"input\\GIS\\", sep="")

eu.country.dir <- "Admin_units\\EU_Countries\\"
eu.country    <- terra::vect(paste0(gis.dir, eu.country.dir, "CNTR_RG_10M_2024_4326.geojson"))

# ######### EPPO ####################
# # save EPPO layer rdata file
# EPPO.admin.layer    <- rgdal::readOGR(paste(data.dir, "input\\GIS\\EPPOadm_simplified.shp", sep=""), "EPPOadm_simplified", stringsAsFactors = FALSE)
# EPPO.admin.layer    <- sp::spTransform(EPPO.admin.layer, CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
# save(EPPO.admin.layer, file=paste(data.dir, "rdata\\EPPO0.layer.RData", sep=""))
# # save EPPO admin table (based on FAO GAUL)
# EPPO.table <- EPPO.admin.layer@data[,-which(names(EPPO.admin.layer) %in% c("layer", "path"))]
# write.csv(EPPO.table, file="Supporting_information\\EPPO Codes and names.csv", row.names = FALSE)
# rm(EPPO.admin.layer, EPPO.table)

######### FAO.GAUL ####################
# FAO GAUL 0 RData
FAO.GAUL.layer <- sf::st_read("C:\\Users\\maioran\\EFSA\\PLH Climate Suitability - Documents\\GIS\\Admin_units\\Administrative_Units.gpkg", layer = "g2015_2014_all_fixed_geom_simplified_0.005")

save(FAO.GAUL.layer, file=paste(data.dir, "rdata\\FAO.GAUL.layer.RData", sep=""))

# write table with GAUL codes and names
FAO.GAUL.attributes <- sf::st_drop_geometry(FAO.GAUL.layer)
write.csv(FAO.GAUL.attributes, file="Documentation\\FAO_GAUL_Codes_and_names_v6.csv", row.names = FALSE)

# save layer with fed countries
fed.countries <- c("Canada", "United States of America", "Brazil", "Russian Federation", "India", "China", "Australia")
# remove FAO.GAUL 2
FAO.GAUL.layer.fed <- FAO.GAUL.layer[which(FAO.GAUL.layer$adm_level==1),]
FAO.GAUL.layer.fed <- FAO.GAUL.layer.fed[which(FAO.GAUL.layer.fed$ADM0_NAME %in% fed.countries),]

#FAO.GAUL.layer.1 <- sf::st_simplify(FAO.GAUL.layer.1, preserveTopology = TRUE, dTolerance = 10000)
save(FAO.GAUL.layer.fed, file=paste(data.dir, "rdata\\FAO.GAUL.fed.countries.layer.RData", sep=""))

# save layer at country level
gaul0.countries <- unique(FAO.GAUL.layer$ADM0_CODE)
FAO.GAUL.layer.0 <- FAO.GAUL.layer[which(FAO.GAUL.layer$adm_code %in% gaul0.countries),]
FAO.GAUL.layer.0.no.fed <- FAO.GAUL.layer.0[-which(FAO.GAUL.layer.0$ADM0_CODE %in% FAO.GAUL.layer.fed$ADM0_CODE),]
#FAO.GAUL.layer.0 <- sf::st_simplify(FAO.GAUL.layer.0, preserveTopology = TRUE, dTolerance = 10000)
save(FAO.GAUL.layer.0, file=paste(data.dir, "rdata\\FAO.GAUL.Countries.layer.RData", sep=""))
save(FAO.GAUL.layer.0.no.fed, file=paste(data.dir, "rdata\\FAO.GAUL.Countries.no.fed.layer.RData", sep=""))

