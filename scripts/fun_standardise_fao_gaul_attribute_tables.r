# add missing columns to gaul attribute tables
standardise_attribute_table <- function(colnames_to_keep, gaul)
{# gaul <- gaul2
  columns_to_add <- colnames_to_keep[which(!colnames_to_keep %in% names(gaul))]
  columns_to_remove <- names(gaul)[which(!names(gaul) %in% colnames_to_keep)]
  gaul <- gaul[ , !(names(gaul) %in% columns_to_remove)] 
  gaul$gaul0_code <- as.numeric(gaul$gaul0_code)
  gaul$gaul1_code <- as.numeric(gaul$gaul1_code)
  gaul$gaul2_code <- as.numeric(gaul$gaul2_code)
  gaul$gaul0_name <- as.character(gaul$gaul0_name)
  gaul$gaul1_name <- as.character(gaul$gaul1_name)
  gaul$gaul2_name <- as.character(gaul$gaul2_name)
  
  for (new_column in columns_to_add) {
    gaul[[new_column]] <- rep(NA, nrow(gaul))   # or NA_real_, NA_character_, etc. depending on type
  }
  # order columns
  gaul <- gaul[,colnames_to_keep]
  return(gaul)
}
