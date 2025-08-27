# function that generate the vector layer used for mapping pest distribution
# The layer includes GAUL level 0 + GAUL level 1 for the federated countries
generate_efsa_pest_distribution_layer <- function(fed_countries_list, gaul1, gaul0)
{
  # vector with federated countries GAUL level 1
  gaul1_fed_countries <- gaul1[gaul1$gaul0_name %in% fed_countries_list,]
  # vector with no federated countries
  gaul0_no_fed_countries <- gaul0[!(gaul0$gaul0_name %in% fed_countries_list),]
  # add field including gaul code, gaul name, gaul level
  gaul0_no_fed_countries$gaul_code  <- gaul0_no_fed_countries$gaul0_code
  gaul0_no_fed_countries$gaul_name  <- gaul0_no_fed_countries$gaul0_name
  gaul0_no_fed_countries$gaul_level <- 0
  
  #gaul0_no_fed_countries <- gaul0_no_fed_countries[,colnames_to_keep]
  #gaul1_fed_countries <- gaul1_fed_countries[,colnames_to_keep]
  EFSA_admin_distribution_layer <- rbind(gaul0_no_fed_countries, gaul1_fed_countries)
  return(EFSA_admin_distribution_layer)
}


