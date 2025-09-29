## ------------------------------------------------------------------------------------
## Description
## ------------------------------------------------------------------------------------

## Author: Renee Bichler, 2025
## Find me on GitHub: reneebichler

## Within this code we are going to download NASA Digital Elevation Model data using Google Earth Engine,
## clipped to a shapefile and exported as GeoTIFF.

## Date format: YYYY-MM-DD

print("#################################################################################")
print("##")
print("##                      Houston, we've no problem!")
print("##                       We're about to download")
print("##             Sentinel-5P NO2/CH4 satellite data using GEE!")
print("##                           ╰( ^o^)╮╰( ^o^)╮")
print("##")
print("#################################################################################")

## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

import ee
import pandas as pd
import geopandas as gpd
from datetime import date
from calendar import monthrange

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

sy = 2019
ey = 2022

aoi = "CONUS"
project_id = 'xxx'
data_product = 'OFFL'
google_drive_folder = 'S5P_OFFL_L3_NO2'
#google_drive_folder = 'S5P_OFFL_L3_CH4'
name = google_drive_folder

## Input
shapefile_path = '/Volumes/DATA/GEODATA/s_18mr25/CONUS.shp'

collection = 'COPERNICUS/S5P/' + data_product + '/L3_NO2'
dat_var = 'tropospheric_NO2_column_number_density'
dat_des = 'NO2_Export'

#collection = 'COPERNICUS/S5P/' + data_product + '/L3_CH4'
#dat_var = 'CH4_column_volume_mixing_ratio_dry_air'
#dat_des = 'CH4_Export'

s = 1000

## ------------------------------------------------------------------------------------
## Functions
## ------------------------------------------------------------------------------------

## Function to download NO2 data from Sentinel-5P
def download_gee_data_with_shapefile(start_date, end_date, shapefile_path, output_file):
    
    ## Load the shapefile using GeoPandas
    gdf = gpd.read_file(shapefile_path)

    ## Convert the GeoJSON to an Earth Engine geometry
    region = ee.Geometry.Polygon(gdf.unary_union.convex_hull.exterior.coords[:])

    ## Load the Sentinel-5P NRTI NO2 dataset
    dat_collection = ee.ImageCollection(collection)\
        .filterDate(start_date, end_date)\
        .filterBounds(region)

    ## Select the NO2 column density variable
    dat_image = dat_collection.select(dat_var).mean()

    ## Export the image to Google Drive as GeoTIFF
    task = ee.batch.Export.image.toDrive(
        image = dat_image.clip(region),
        description = dat_des,
        folder = google_drive_folder,
        fileNamePrefix = output_file,
        region = region.bounds().getInfo()['coordinates'],
        scale = s,
        crs = 'EPSG:4326',
        fileFormat = 'GeoTIFF'
    )

    task.start()
    print(f"Export started for {output_file}; Check your Google Drive for the GeoTIFF file.")

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

if __name__ == "__main__":

    ## Trigger the authentication flow.
    ee.Authenticate()

    ## Initialize the library.
    ee.Initialize(project = project_id)

    ## Create a yearly list
    year_l = list(range(sy, ey + 1))

    for YEAR in year_l:

        start_date1 = YEAR + '-01-01'
        end_date1 = YEAR + '-12-31'

        ## Create the output filename
        output_file1 = aoi + '_' + name + '_ym_' + start_date1 + '_' + end_date1
        print(output_file1)

        ## Call the function
        download_gee_data_with_shapefile(start_date1, end_date1, shapefile_path, output_file1)

        df = pd.DataFrame()

        ## Get the first date of a month "2024-01-01" and the last day of a month "2024-01-31"
        ## and store the information with concat() to the empty data frame
        for month in range(1, 13):
            start = date(YEAR, month, 1)
            end = date(YEAR, month, monthrange(YEAR, month)[1])
            df1 = pd.DataFrame({"start":[start], "end":[end]})
            df = pd.concat([df, df1], ignore_index=True)
            print(df1)

        ## Create an index list based on the length of the data frame
        idx_l = list(range(len(df)))

        for idx in idx_l:

            ## Retrieve the start date and end date based on the index (idx)
            start_date2 = str(df.loc[idx, 'start'])
            end_date2 = str(df.loc[idx, 'end'])
            print('Start date:', start_date2, '| End date:', end_date2, sep=" ")

            ## Create the output filename
            output_file2 = aoi + '_' + name + '_mm_' + start_date2 + '_' + end_date2
            print(output_file2)

            ## Call the function
            download_gee_data_with_shapefile(start_date2, end_date2, shapefile_path, output_file2)

print("#################################################################################")
print("##")
print("##                               Success!")
print("##                            Job completed!")
print("##                               ( ┘^o^)┘")
print("##")
print("#################################################################################")

## Note: To export the data to Google Drive can take a moment.
## Check status: https://code.earthengine.google.com/tasks
