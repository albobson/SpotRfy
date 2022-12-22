## Going to slowly fill up this script as I find useful functions from the 
## spotifyR package

# install.packages('spotifyr')

library(tidyverse)
library(knitr)
library(lubridate)
library(dplyr)
library(ggplot2)
library(spotifyr)

## Have to set the client ID and Client Secret
## Got from here: https://developer.spotify.com/dashboard/applications/1d49b45a8ef9432499dbed35cc3fd9cf
## more information here: https://developer.spotify.com/documentation/general/guides/authorization/app-settings/

## Sourcing the actual ID and, more importantly, the secret from another document
## and then placing that script in gitignore

source("../SpotRfy/scripts/221212_dont_upload.R")

## Calling from the non-uploaded script to get the secret ID
get_spotify_credentials()

access_token <- get_spotify_access_token()

#### Scripts to work with locally downloaded data ####

## Import the spotify streaming data
## The filepath needs to be the path to the file where the downloaded 
## data is stored
import_spotify_streaming_data <- function(datafile) {
  
  stream_files  <- list.files(path=as.character(datafile),
                              recursive=T,
                              pattern='StreamingHistory*',
                              full.names=T)
  
  ## Create a null dataset to store the streaming data
  data <- NULL
  
  ## For loop to extract from however many files you have
  for(i in 1:length(stream_files)) {
    new_data <- jsonlite::fromJSON(stream_files[i])
    data <- rbind(data, new_data)
    data
  }
  return(data)
}

## Clean spotify streaming data
## This will add the various minutes/seconds columns and date column
## Need to specify desired timezone (eg. "PST")

clean_spotify_streaming_data <- function(data, your_timezone) {
  ## Time is in ms, changing to minutes or seconds
  data$min_played <- data$msPlayed/60/1000
  data$sec_played <- data$msPlayed/1000
  
  ## Spotify data is recorded in UTC, need to convert to a different time
  data$dif_endtime <- lubridate::ymd_hm(data$endTime, tz = "UTC")
  data$dif_endtime <- with_tz(data$dif_endtime, tzone = as.character(your_timezone))
  
  ## Adding columns to break apart the date and time
  ## Extracting just the hour-min characters
  data$hm_endtime <- substr(data$dif_endtime, 11, 16)
  data$hm_endtime <- lubridate::hm(data$hm_endtime)
  data$day_endtime <- substr(data$dif_endtime, 1, 10)
  data$day_endtime <- ymd(data$day_endtime)
  
  ## Time of day played
  data$time <- as.numeric(data$hm_endtime)
  data$hour <- data$time*24/86340
  
  data1 <- data %>%
    group_by(artistName) %>%
    dplyr::mutate(sum_min_per_artist = sum(min_played), numb_songs = n()) %>%
    dplyr::arrange(desc(sum_min_per_artist)) %>% 
    group_by(trackName, .add = TRUE) %>%
    dplyr::mutate(sum_min_per_song = sum(min_played), num_times_song_played = n()) %>%
    dplyr::arrange(desc(sum_min_per_artist)) %>%
    dplyr::ungroup()
  
  return(data1)
}

## A function to plot streams by time of day and date
## artist_cutoff - must specify how many of your top artists to show

plot_streaming_timeofday <- function(clean_stream_data, artist_cutoff) {
  func_df <- clean_stream_data
  
  # return(func_df)
  
  artist_names <- func_df %>%
    select(artistName, sum_min_per_artist) %>%
    distinct() %>%
    arrange(desc(sum_min_per_artist)) %>%
    top_n(n = artist_cutoff, wt = sum_min_per_artist)
  
  # return(artist_names)
  
  func_df$artistName <- ifelse(func_df$artistName %in% artist_names$artistName,
                               func_df$artistName, NA)
  
  func_df$trackName <- ifelse(func_df$artistName %in% artist_names$artistName,
                              func_df$artistName, NA)
  
  # return(func_df)
  
  plot1 <- ggplotly(
    ggplot(func_df, aes(x = day_endtime, y = hour, color = artistName)) +
      geom_point() +
      scale_y_continuous(limits = c(0, 24), breaks = (0:12)*2) +
      theme_light()
  )
  
  return(plot1)
  
}

## A function to plot a barplot of each artist's time listened stacked by songs
## artist_cutoff - must specify how many of your top artists to show
plot_streaming_artists <- function(clean_stream_data, artist_cutoff) {
  
  artist_names <- clean_stream_data %>%
    select(artistName, sum_min_per_artist) %>%
    distinct() %>%
    arrange(desc(sum_min_per_artist)) %>%
    top_n(n = artist_cutoff, wt = sum_min_per_artist)
  
  # return(artist_names)
  
  clean_stream_data$artistName <- ifelse(clean_stream_data$artistName %in% artist_names$artistName,
                                         clean_stream_data$artistName, NA)
  
  clean_stream_data$trackName <- ifelse(clean_stream_data$artistName %in% artist_names$artistName,
                                        clean_stream_data$trackName, NA)
  
  clean_stream_data <- clean_stream_data %>%
    select(trackName, artistName, sum_min_per_artist, 
           sum_min_per_song, numb_songs, num_times_song_played) %>%
    na.omit() %>%
    distinct()
  
  ggplotly(
    ggplot(clean_stream_data, 
           aes(x = reorder(artistName, -sum_min_per_artist), 
               y = sum_min_per_song, fill = trackName)) +
      geom_bar(stat = 'identity', position = 'stack', ) +
      theme_light() +
      theme(axis.text.x = element_text(angle = 90), legend.position = 'none') +
      ggtitle("Total Minutes of song played by each artist") +
      ylab("Total time listened to artist (min)") +
      xlab("")
  )
  
}