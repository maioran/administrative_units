config <- yaml::read_yaml("config/config.yaml")

# set main directories
output_dir    <- config$output_dir
input_dir     <- config$input_dir
data_dir      <- config$data_dir

# set geometry simplification tolerance
i_tolerance <- config$i_tolerance

# set list of federated countries
fed_countries_list <- c(config$fed_countries_list)

# list of disputed territories
list_disputed_territories <- config$disputed_territories
list_related_countries    <- config$related_countries

# set fields to keep for gaul attribute tables
colnames_to_keep <- config$colnames_to_keep
