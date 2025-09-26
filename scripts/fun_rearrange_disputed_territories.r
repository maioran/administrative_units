
rearrange_disputed_territories <- function(disputed_territory, related_disputed_country, efsa_pest_distribution_layer_simpl)
{
  disputed_and_countries <- terra::subset(efsa_pest_distribution_layer_simpl, efsa_pest_distribution_layer_simpl$gaul_name %in%
                                    c(related_disputed_country,disputed_territory))
  
  disputed_and_countries_snap <- terra::snap(disputed_and_countries, disputed_and_countries, tolerance=0.01)
  disputed_and_countries_agg <- terra::aggregate(disputed_and_countries_snap)
  
  countries_attributes <- terra::subset(efsa_pest_distribution_layer_simpl, efsa_pest_distribution_layer_simpl$gaul_name == related_disputed_country)
  
  terra::values(disputed_and_countries_agg) <- terra::values(countries_attributes)
  
  efsa_pest_distribution_layer_simpl_remove_countries <- efsa_pest_distribution_layer_simpl[!efsa_pest_distribution_layer_simpl$gaul_name %in% c(disputed_territory, related_disputed_country),]
  
  efsa_pest_distribution_layer_simpl_v02 <- rbind(efsa_pest_distribution_layer_simpl_remove_countries, disputed_and_countries_agg)

  return(efsa_pest_distribution_layer_simpl_v02)
}
