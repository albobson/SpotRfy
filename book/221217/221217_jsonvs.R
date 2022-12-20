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

source("~/R/Projects/SpotRfy/scripts/221212_dont_upload.R")

## Import the dataset

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
data$day_endtime <- substr(data$dif_endtime, 1, 10)
data$day_endtime <- ymd(data$day_endtime)

#### Number of minutes per day ####
data_sum_date <- data %>%
  group_by(day_endtime) %>%
  summarize(tot_min = sum(min_played))


## Should figure out how to color the top 5 artists to show when they were
## listened to
min_played_per_day <- ggplot(data_sum, aes(x = day_endtime, y = tot_min)) +
                        geom_bar(stat = 'identity') + 
                        ggtitle("Number of minutes played per day")

ggsave("221219_bar_min_played_per_day.png",min_played_per_day)

#### Number of minutes per day of the week ####
data$wk_day <- wday(data$day_endtime, label = TRUE)
data_sum_wkday <- data %>%
  group_by(wk_day) %>%
  summarize(tot_min = sum(min_played))

min_played_per_wkday <- ggplot(data_sum_wkday, aes(x = wk_day, y = tot_min)) +
  geom_bar(stat = 'identity') + 
  ggtitle("Number of minutes played per day of the week") +
  xlab("Week Day")

min_played_per_wkday

ggsave("221219_bar_min_played_per_wkday.png",min_played_per_wkday)


#### Time of day played ####

data$time <- as.numeric(data$hm_endtime)
data$hour <- data$time*24/86340
ggplotly(
ggplot(data, aes(x = day_endtime, y = hour, size = min_played, color = artistName)) +
  geom_point() +
  scale_y_continuous(limits = c(0, 24), breaks = (0:12)*2) +
  theme_light()
)

#### Finding stats on artists/songs most played ####

## Artists
artist_only <- data %>%
  select(artistName, min_played, hm_endtime)

artist_sum <- artist_only %>%
  group_by(artistName) %>%
  summarize(sum_min_per_artist = sum(min_played)) %>%
  dplyr::arrange(desc(sum_min_per_artist))

artist_sum

## ggplot is plotting in alphabetical order but I want it to be in order of the 
## most listened. Since I don't have service, I'm doing that the best way I know
artist_sum$order <- paste0(1:nrow(artist_sum))

for (k in 1:9) {
artist_sum$order[k] <- paste0("0", k)
}

artist_sum$n_ar_name <- paste0(
  as.character(artist_sum$order),"_",as.character(artist_sum$artistName))

artist_sum50 <- head(artist_sum, 50)

ggplot(artist_sum50, aes(x=n_ar_name, y=sum_min_per_artist)) +
  geom_bar(stat='identity') +
  theme(axis.text.x = element_text(angle = 90))

## Songs
tracks_sel <- data %>%
  select(trackName, artistName, min_played, hm_endtime)

tracks_artist <- tracks_sel %>%
  group_by(trackName,artistName) %>%
  summarize(sum_min_per_track = sum(min_played)) %>%
  dplyr::arrange(desc(sum_min_per_track)) %>% 
  ungroup()

tracks_artist

tracks_artist$order <- paste0(1:nrow(tracks_artist))

for (k in 1:9) {
  tracks_artist$order[k] <- paste0("0", k)
}

tracks_artist$n_ar_name <- paste0(
  as.character(tracks_artist$order),"_",as.character(tracks_artist$artistName))

tracks_artist50 <- head(tracks_artist, 50)
tracks_artist50


## This plots the top 50 songs, stacked by artist
ggplotly(
ggplot(tracks_artist50, aes(x = artistName, y = sum_min_per_track, fill = trackName)) +
  geom_bar(stat='identity', position='stack') +
  theme(axis.text.x = element_text(angle = 90), legend.position = 'none')
)

## Instead, I should plot the top 50 artists and each song of theirs
head(tracks_sel)

all_ta <- tracks_sel %>%
  group_by(artistName) %>%
  dplyr::mutate(sum_min_per_artist = sum(min_played), numb_songs = n()) %>%
  dplyr::arrange(desc(sum_min_per_artist)) %>% 
  group_by(trackName, .add = TRUE) %>%
  dplyr::mutate(sum_min_per_song = sum(min_played), num_times_song_played = n()) %>%
  dplyr::arrange(desc(sum_min_per_artist))

# all_ta$order <- paste0(1:nrow(all_ta))
# 
# for (k in 1:9) {
#   all_ta$order[k] <- paste0("0", k)
# }
# 
# all_ta$n_ar_name <- paste0(
#   as.character(all_ta$order),"_",as.character(all_ta$artistName))


## Filtering to just artists that I listened to more than 100 songs
all_ta100 <- all_ta %>%
  filter(numb_songs >=100, artistName != "Exodar")

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
