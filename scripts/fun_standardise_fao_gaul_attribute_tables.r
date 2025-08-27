# add missing columns to gaul attribute tables
standardise_attribute_table <- function(colnames_to_keep, gaul)
{# gaul <- gaul0
  columns_to_add <- colnames_to_keep[which(!colnames_to_keep %in% names(gaul))]
  columns_to_remove <- names(gaul)[which(!names(gaul) %in% colnames_to_keep)]
  gaul <- gaul[ , !(names(gaul) %in% columns_to_remove)] 
  
  for (new_column in columns_to_add) {
    gaul[[new_column]] <- rep(NA, nrow(gaul))   # or NA_real_, NA_character_, etc. depending on type
  }
  # order columns
  gaul <- gaul[,colnames_to_keep]
  return(gaul)
}
