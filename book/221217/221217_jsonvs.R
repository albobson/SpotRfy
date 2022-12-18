## Trying to parse the JSON file with all of the downloaded data

## Set up
library(tidyverse)
library(knitr)
library(lubridate)
library(hms)
library(spotifyr)
library(plotly)
library(jsonlite)


setwd("~/R/Projects/SpotRfy/book/221217/")

source("../SpotRfy/scripts/221212_dont_upload.R")
get_spotify_credentials()

access_token <- get_spotify_access_token()

## Import the dataset

## Path is path to where the data files are being stored.
## StreamingHistory* are the files that contain stream data
stream_files  <- list.files(path="../../data/lasty/",
                             recursive=T,
                             pattern='StreamingHistory*',
                             full.names=T)

## Create a null dataset to store the streaming data
data <- NULL

## For loop to extract from however many files you have
for(i in 1:length(stream_files)) {
  new_data <- fromJSON(stream_files[i])
  data <- rbind(data, new_data)
  data
}

View(data)

## Looks good!

## Time is in ms, changing to minutes or seconds
data$min_played <- data$msPlayed/60/1000
data$sec_played <- data$msPlayed/1000

## Spotify data is recorded in UTC, need to convert to a different time
data$dif_endtime <- lubridate::ymd_hm(data$endTime, tz = "UTC")
data$dif_endtime <- with_tz(data$dif_endtime, tzone = "EST")

## Adding columns to break apart the date and time
## Extracting just the hour-min characters
data$hm_endtime <- substr(data$dif_endtime, 11, 16)
data$hm_endtime <- lubridate::hm(data$hm_endtime)
data$day_endtime <- ymd(data$dif_endtime)
