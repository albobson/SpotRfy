## 221221 - Working on creating master functions that can be referenced

library(dplyr)

setwd("~/R/Projects/SpotRfy/book/221221")

source("~/R/Projects/SpotRfy/scripts/spotRfy_local_data.R")


## A function to import data
test <- import_spotify_streaming_data(datafile = "../../data/lasty")

## A function to clean the data
test_clean <- clean_spotify_streaming_data(data = test, your_timezone = "EST")
test_clean

## A function to plot the time series data
test_plot1 <- plot_streaming_timeofday(test_clean, artist_cutoff = 20)
test_plot1

## A function to plot the bar plot data
test_plot2 <- plot_streaming_artists(test_clean, artist_cutoff = 10)
test_plot2
