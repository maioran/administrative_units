# FAO GAUL 2024 Conversion #

##The FAO GAUL dataset##

    The Global Administrative Unit Layers (GAUL) dataset was developed in the late 1990s for accurate representations of political subnational administrative boundaries in Geographic Information Systems (GIS).
    In 2024, a new version was released with many code changes from the 2015 version. This project develops a conversion table to assist with the transition.
    
    source: Global Administrative Unit Layers (GAUL 2015) - Global Administrative Unit Layers (GAUL 2015) - "FAO catalog"

##Manage of not available data##

    In the 2024 database, when no data sources were available and it was not possible to rely on the 2015 dataset, the corresponding administrative units were labelled as 
    “Administrative unit not available.” These records were excluded from the conversion process and were removed before joining the tables.

## Match on multiple levels

    1 - Geodataframe were imported from Fao Gaul official site and clean from not available administrative 
        unite

    2 - items were spatially joined using centroids (previously calculated on the Marcator projection)

    3 - Dataframe transformed to show all item of different levels in a single row

    4 - a new join_column was created from gaul name eliminating special characters, space and accents to improve join

    5 - suffix were eliminated from join column : city, cityof, district, municipality, metropolitan, district

    6 - match ration between gaul 2015 and gaul 2024 name was calculated and store in a new column

    7 - the final dataset contain a distance column to filter by centroid join accuracy and a match ratio column
        to filter by % of letters in common between gaul 2015 and gaul 2024 names.

## output obtained:

    Not available unites list : na_2015.xlsx , na_2024.xlsx
    Conversion table based on spatial and string match : spatial_and_string_match.xsls
    Conversion table based on spatial and string match filtered with setted par : spatial_and_string_match_filtered.xsls
    list of unmatched : unmatched_2015.xlsx, unmatched_2024.xlsx