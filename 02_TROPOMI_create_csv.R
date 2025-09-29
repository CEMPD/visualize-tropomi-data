## ------------------------------------------------------------------------------------
## Description
## ------------------------------------------------------------------------------------

## Author: Renee Bichler, 2025
## Find me on GitHub: reneebichler

## Within this code, we will create a CSV file for the TROPOMI data.

cat("##################################################################################\n")
cat("##\n")
cat("##                               That's fun!\n")
cat("##                Let's create a CSV file for the TROPOMI data!\n")
cat("##                             ╰( ^o^)╮╰( ^o^)╮\n")
cat("##\n")
cat("##################################################################################\n")

## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

packages <- c("sf", "stringi")

## Install missing packages
installed <- packages %in% rownames(installed.packages())
if (any(!installed)) {install.packages(packages[!installed])}

## Load all packages
lapply(packages, function(pkg) suppressPackageStartupMessages(library(pkg, character.only = TRUE)))

source("/Other/00_process_satellite_data.R")

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

satellite <- "Sentinel-5P"
var_name_list <- c("NO2", "CH4")
time_resolution <- "mm" #ym

sat_path <- paste0("/RemoteSensing/DATA/Sentinel-5P")
path_out <- paste0("/RemoteSensing/Results/Other/CSV/TROPOMI")

instrument_dic <- c(
    "Sentinel-5P" = "TROPOMI"
)

aoi_l <- c(
    "AOI_BO_City"
)

aoi_keys <- c(
    "AOI_BO_City" = "/RemoteSensing/DATA/GEODATA/SHP/mapc_dissolved.shp"
)

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

for (aoi in aoi_l) {

    print(paste0("Process AOI: ", aoi))

    polygon_file <- aoi_keys[[aoi]]

    print(paste0("Polygon for ", aoi))
    
    ## Get layername from file and remove ".geojson"
    layer_name <- gsub("\\..*", "", strsplit(polygon_file, "/")[[1]][7])

    ## Read polygon
    multipolygon_sf <- read_sf(polygon_file)

    ## Add a column with a new ID
    multipolygon_sf$new_id <- seq_len(nrow(multipolygon_sf))
    multipolygon_sf$path <- polygon_file

    id_df <- data.frame()

    for (i in seq(1, nrow(multipolygon_sf))) {
        for (var_name in var_name_list) {

            ## Walk through polygons
            polygon <- multipolygon_sf[i,]

            ## Retrieve ID
            id <- polygon$new_id

            if ("NAME" %in% names(polygon)) {
                name <- polygon$NAME
            } else {
                print("No NAME column in polygon")
                name <- NA
            }
            
            ## Row bind the polygon to the id data frame
            id_df <- rbind(id_df, polygon)           

            ## Retrieve CRS from polygon_sf and apply to 
            polygon <- st_as_sfc(polygon, crs = st_crs(multipolygon_sf))
            polygon <- st_sf(geometry = polygon)

            ## Make sure polygon is in CRS 4326 in case it is not
            polygon <- st_transform(polygon, crs = 4326)

            ## Retrieve satellite instrument
            instrument <- instrument_dic[[satellite]]

            print(paste0("Process: ", var_name))

            ## List all files
            file_l <- list.files(paste0(sat_path, "/", var_name), sprintf(paste0("_", time_resolution, "_")), recursive=TRUE, full.names=TRUE, include.dirs=TRUE)
            print(file_l)
        
            ## Crop the satellite raster object to polygon
            df_crop_aoi <- crop_sat(polygon, file_l)

            ## Extract the date from the column names and convert them into a sorted date list of object date
            date_l <- sort(as.Date(gsub("^X_", "", colnames(df_crop_aoi)), format = "%Y.%m.%d"))

            ## Get start and end date
            sd <- date_l[1]
            ed <- date_l[length(date_l)]
            
            #print(paste0("UTC time: ", utc, " Start date: ", sd,  " and end date: ", ed))
            write.csv(df_crop_aoi, file = paste0(path_out, "/", instrument, "_", var_name, "_", time_resolution, "_TVC_", sd, "-", ed, "_crop_", aoi, "_ID_", id, ".csv"))
            print(paste0("Saving: ", instrument, "_", var_name, "_", time_resolution, "_TVC_", sd, "-", ed, "_crop_", aoi, "_ID_", id, ".csv"))

            ## calculate column mean based on input data
            df_c_mean_aoi <- generate_c_mean_df(df_crop_aoi, var_name, aoi, id, name)
            write.csv(df_c_mean_aoi, file = paste0(path_out, "/", instrument, "_", var_name, "_", time_resolution, "_TVC_", sd, "-", ed, "_crop_mean_", aoi, "_ID_", id, ".csv"))
            print(paste0(instrument, "_", var_name, "_", time_resolution, "_TVC_", sd, "-", ed, "_crop_mean_", aoi, "_ID_", id, ".csv"))
        }
    }
    write.csv(id_df, paste0(path_out, "/", instrument, "_id-df_", aoi, ".csv"))
    print(paste0("Saved csv file: ", path_out, "/", instrument, "_id-df_", aoi, ".csv"))
}

cat("##################################################################################\n")
cat("##\n")
cat("##                                Success!\n")
cat("##                             Job completed!\n")
cat("##                                ( ┘^o^)┘\n")
cat("##\n")
cat("##################################################################################\n")
