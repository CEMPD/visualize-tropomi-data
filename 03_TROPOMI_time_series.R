## ------------------------------------------------------------------------------------
## Description
## ------------------------------------------------------------------------------------

## Author: Renee Bichler, 2025
## Find me on GitHub: reneebichler

## Within this code, we will create a time series for the TROPOMI data.

cat("##################################################################################\n")
cat("##\n")
cat("##                               That's fun!\n")
cat("##                Let's create a time series for the TROPOMI data!\n")
cat("##                             ╰( ^o^)╮╰( ^o^)╮\n")
cat("##\n")
cat("##################################################################################\n")

## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

packages <- c("stringr", "ggplot2", "zoo", "plotly")

## Install missing packages
installed <- packages %in% rownames(installed.packages())
if (any(!installed)) {install.packages(packages[!installed])}

## Load all packages
lapply(packages, function(pkg) suppressPackageStartupMessages(library(pkg, character.only = TRUE)))

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

satellite <- "Sentinel-5P"
var_name_list <- c("NO2", "CH4")
time_resolution <- c("mm") #"ym"
no2_div_val <- 15

path_inp <- "/RemoteSensing/Results/Other/CSV/TROPOMI"
path_out <- "/RemoteSensing/Results/Other/Plots/TROPOMI/time_series"

instrument_dic <- c(
    "Sentinel-5P" = "TROPOMI"
)

subtitle_dic <- list(
    NO2 = "Tropospheric vertical column of NO\u2082\nVariable: tropospheric_NO2_column_number_density",
    CH4 = "Column-averaged dry air mixing ratio of CH\u2084, as parts-per-billion\nVariable: CH4_column_volume_mixing_ratio_dry_air"
)

unit_dic <- c(
    "NO2" = bquote("10"^.(no2_div_val) * " molec./cm"^2),
    "CH4" = "Molec. fraction"
)

aoi_l <- c(
    "AOI_BO_City"
)

## ------------------------------------------------------------------------------------
## Functions
## ------------------------------------------------------------------------------------

spline_trend <- stat_smooth(
    method = "gam", 
    formula = y~s(x), 
    color = "steelblue3", 
    fill = "steelblue1", 
    alpha = 0.2, 
    size = 0.8
)

theme1 <- theme_bw() +
theme(
    rect = element_rect(fill = "transparent", colour = NA),
    plot.title = element_text(hjust = 0, size = 16), 
    plot.subtitle = element_text(color = "grey35", size = 14),
    plot.caption = element_text(color = "grey35", size = 12),
    plot.background = element_blank(),
    axis.title = element_text(color = "grey35", size = 14),
    axis.text = element_text(color = "grey35", size = 12),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.ticks = element_blank(), 
    legend.title = element_text(color = "grey35", size = 14),
    legend.title.position = "top",
    legend.text = element_text(color = "grey35", size = 12), 
    legend.position = "bottom", 
    legend.key = element_rect(colour = NA, fill = NA),
    legend.key.width = unit(1, "cm"),
    legend.key.height = unit(.4, "cm"),
    legend.margin = margin(-10, 0, 0, 0),
    legend.spacing.y = unit(0, "cm"),
    legend.background = element_blank(),
    panel.background = element_blank(),
    panel.border = element_blank(),
    text = element_text(family = "serif")
)

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

for (aoi in aoi_l) {
    for (var_name in var_name_list) {
        for (time_res in time_resolution) {

            print(paste0("Process: ", aoi, "; Variable: ", var_name, "; Time resolution: ", time_res))

            instrument <- instrument_dic[[satellite]]

            ## List all files in folder with certain pattern
            df_path_l <- list.files(path = path_inp, pattern = paste0("^", instrument, "_", var_name, "_", time_res, "_TVC_\\d{4}-\\d{2}-\\d{2}-\\d{4}-\\d{2}-\\d{2}_crop_mean_", aoi, "_ID_\\d{+}.csv$"), recursive = FALSE, full.names = TRUE, include.dirs = TRUE)
            
            for (df_path in df_path_l) {
                
                print(paste0("Process path: ", df_path))
                df <- read.csv(df_path)
           
                ## Check for missing dates in time series
                if (time_res %in% c("dm")) {

                    date_range <- seq.Date(from = as.Date(df$date[1]), to = as.Date(df$date[length(df$date)]), by = "day") 
                    missing_date_l <- as.character(date_range[!date_range %in% df$date])

                    for (md in missing_date_l) {
                        print(paste0("Process missing date (daily df): ", md))
                        missing_df <- data.frame(X = NA, date = as.character(md), variable = "missing", level = NA, aoi = NA, n = NA, mean = NA)
                        df <- rbind(df, missing_df)
                    }

                } else if (time_res %in% c("mm")) {

                    date_range <- seq.Date(from = as.Date(df$date[1]), to = as.Date(df$date[length(df$date)]), by = "month") 
                    missing_date_l <- date_range[!date_range %in% df$date]

                    for (md in missing_date_l) {
                        print(paste0("Process missing date (monthly df): ", md))
                        missing_df <- data.frame(X = NA, date = as.character(md), variable = "missing", level = NA, aoi = NA, n = NA, mean = NA)
                        df <- rbind(df, missing_df)
                    }
                }

                ## Order data frame by date
                df <- df[order(as.Date(df$date, format = "%Y-%m-%d")),]

                if (var_name == "NO2") {
                    ## Convert mol/m2 to molecules/cm2
                    cat("Convert TROPOMI NO2 values from mol/m2 to molec./cm2\n")
                    df$mean <- df$mean * (6.022 * (10^19))
                }

                ## Interpolate missing dates
                df["interpl"] <- na.approx(df$mean, na.rm = FALSE)

                if (var_name == "NO2") {
                    ## Divide values by no2_div_val
                    df$interpl <- df$interpl / 10^no2_div_val
                    df$mean <- df$mean / 10^no2_div_val
                }

                ## Subset missing date to show in the plot
                subset_md <- subset(df, df$variable  ==  "missing")

                ## Extract filename
                filename <- str_sub(str_split(df_path, "/")[[1]][length(str_split(df_path, "/")[[1]])], end = -5)
                
                ## Create plot
                plot <- ggplot(df, aes(x = as.POSIXct(date), y = interpl)) +

                ## Highlight
                geom_point(subset_md, mapping = aes(x = as.POSIXct(date), y = interpl), color = "orange", size = 1.8) +

                ## Plot the interpolated values
                geom_line(color = "grey85", linewidth = .2) +
                geom_point(color = "grey85", size = .1) +

                ## Plot the actual values
                geom_line(df, mapping = aes(x = as.POSIXct(date), y = mean), linewidth = .2) +
                geom_point(df, mapping = aes(x = as.POSIXct(date), y = mean), size = .1) +

                ## x-axis as date
                scale_x_datetime(date_labels = "%Y-%m", date_breaks = "6 months") +

                ## Add longterm trend
                spline_trend +

                ## Add text and style to plot
                labs(title = filename, subtitle = subtitle_dic[[var_name]], x = NULL, y = unit_dic[[var_name]]) +
                theme1

                ## Save files in RemoteSensing directory
                write.csv(df, paste0(path_out, "/", filename, "_plot_df.csv"))
                ggsave(paste0(path_out, "/", filename, ".png"), plot = plot, width = 2800, height = 950, units = "px")
                print(paste0("Saved to: ", path_out, "/", filename, ".png"))
            }
        }
    }
}

cat("##################################################################################\n")
cat("##\n")
cat("##                                Success!\n")
cat("##                             Job completed!\n")
cat("##                                ( ┘^o^)┘\n")
cat("##\n")
cat("##################################################################################\n")
