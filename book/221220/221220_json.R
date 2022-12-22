## Playing with the spotify fully downloaded data

## Some ideas that I have:
    ## 1. Plot the time of day that I listened to spotify and color the dots
    ##    by the top 5 artists for the year to see when I listened to them
    ##
    ## 2. 

## Set up
library(tidyverse)
library(knitr)
library(lubridate)
library(hms)
library(spotifyr)
library(plotly)
library(jsonlite)

setwd("~/R/Projects/SpotRfy/book/221220/")

source("~/R/Projects/SpotRfy/scripts/221212_dont_upload.R")

#### Import the data set and clean the data ####

## Path is path to where the data files are being stored.
## StreamingHistory* are the files that contain stream data
stream_files  <- list.files(path="~/R/Projects/SpotRfy/data/lasty/",
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
data$day_endtime <- substr(data$dif_endtime, 1, 10)
data$day_endtime <- ymd(data$day_endtime)

#### Time of day played ####
data$time <- as.numeric(data$hm_endtime)
data$hour <- data$time*24/86340

data1 <- data %>%
  group_by(artistName) %>%
  mutate(sum_min_per_artist = sum(min_played)) %>%
  ungroup()

## Removing the artists names of anyone who was below the 80% quantile 
## so that I can color the time of day plot by artist
data1$artistName <- ifelse(data1$sum_min_per_artist < quantile(data1$sum_min_per_artist, 0.8), 
                           NA, data1$artistName)

data1$trackName <- ifelse(data1$sum_min_per_artist < quantile(data1$sum_min_per_artist, 0.8), 
                          NA, data1$trackName)

## MAKE a feature that includes song names
ggplotly(
  ggplot(data1, aes(x = day_endtime, y = hour, color = artistName)) +
    geom_point() +
    scale_y_continuous(limits = c(0, 24), breaks = (0:12)*2) +
    theme_light()
)

## IT WORKED


## Filtering to just artists that I listened to more than 100 songs
all_ta100 <- all_ta %>%
  filter(numb_songs >=100, artistName != "Exodar") %>%
  select(trackName, artistName, sum_min_per_artist, sum_min_per_song, numb_songs, num_times_song_played) %>%
  distinct()

ex <- all_ta %>%
  filter(artistName == "Exodar")



## Total minutes played
ggplotly(
  ggplot(all_ta100, 
         aes(x = reorder(artistName, -sum_min_per_artist), 
             y = sum_min_per_song, fill = trackName)) +
    geom_bar(stat = 'identity', position = 'stack', ) +
    theme(axis.text.x = element_text(angle = 90), legend.position = 'none') +
    ggtitle("Total Minutes of song played by each artist")
)

## Total minutes played
ggplotly(
  ggplot(all_ta100, aes(x = artistName, y = num_times_song_played, fill = trackName)) +
    geom_bar(stat = 'identity', position = 'stack') +
    theme(axis.text.x = element_text(angle = 90), legend.position = 'none') +
    ggtitle("Total Minutes of song played by each artist")
)
