# add standard columns for admin codes and names
standardize_coding_system <- function(gaul, gaul_level)
{#TEST: gaul=gaul0; gaul_level=0
  gaul_code_colname <- paste0("gaul",gaul_level,"_code")
  gaul_name_colname <- paste0("gaul",gaul_level,"_name")
  gaul$gaul_code <- gaul[[gaul_code_colname]]
  gaul$gaul_name <- gaul[[gaul_name_colname]]
  gaul$gaul_level <- gaul_level
  return(gaul)
}