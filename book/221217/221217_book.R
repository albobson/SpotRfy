## 221217

## First real playing around with the package

library(tidyverse)
library(knitr)
library(lubridate)
library(spotifyr)
library(plotly)


## Thoughts from the previous script:
    ##'* Thoughts to come back to*
    ## 1.   What are my least listened to top artists when looking at how many followers
    ##      they have? IE which of my top artists have the least number of followers?
    ##
    ## 2.   What does that popularity column mean among artists and songs?
    ##
    ## 3.   How long are the top songs on average?
    ##
    ## 4.   What keys do I listen to most?
    ##
    ## 5.   What track numbers are my favorites?
    ##
    ## 6.   Top songs by album release date
    ##
    ## 7.   It's possible to check what an artists top songs are. It would be interesting
    ##      to see where an individual's top songs from that artist compare to the
    ##      popular songs. How much do you _actually_ care for an artist?


source("../SpotRfy/scripts/221212_dont_upload.R")
get_spotify_credentials()

access_token <- get_spotify_access_token()

#### Top tracks ####

## Top 25
top25lt <- get_my_top_artists_or_tracks(
  ## Type can be tracks or artists. Time range == long_term for "all" data
  type = 'tracks', time_range = 'long_term', limit = 25
  ) %>%
  mutate(artist.name = map_chr(artists, function(x) x$name[1])) 
View(top25lt)

top25lt <- top25lt %>%
  mutate(duration_ms = as.numeric(duration_ms)) %>%
  mutate(duration_s = duration_ms/1000, duration_m = duration_ms/60000)

top25lt$rank <- 1:nrow(top25lt)

ggplotly(
  ggplot(top25lt, aes(x = rank, y = duration_m, fill = artist.name)) +
    geom_bar(stat = 'identity') +
    theme_light() +
    theme(legend.position = 'none') +
    ylab("duration (minutes)")
  )

## Top 50 of all time 
  ## (note - can't select more than 50 at a time. Could you offset to 50, 
  ## then select the next 50?)
top50lt <- get_my_top_artists_or_tracks(
  ## Type can be tracks or artists. Time range == long_term for "all" data
  type = 'tracks', time_range = 'long_term', limit = 50
  ) %>%
  mutate(artist.name = map_chr(artists, function(x) x$name[1])) 
View(top50lt)

top50lt <- top50lt %>%
  mutate(duration_ms = as.numeric(duration_ms)) %>%
  mutate(duration_s = duration_ms/1000, duration_m = duration_ms/60000)

top50lt$rank <- 1:nrow(top50lt)

## Plotting duration by rank
ggplotly(
  ggplot(top50lt, aes(x = rank, y = duration_m, fill = artist.name, color = name)) +
    geom_bar(stat = 'identity') +
    theme_light() +
    theme(legend.position = 'none') +
    ylab("duration (min)") +
    ggtitle("Duration by Rank")
)

ggplot(top50lt, aes(x = rank, y = duration_m, fill = artist.name, color = name)) +
  geom_bar(stat = 'identity') +
  theme_light() +
  theme(legend.position = 'none') +
  ylab("duration (min)") +
  ggtitle("Duration by Rank (All time)")

## Plotting popularity by rank
ggplotly(
  ggplot(top50lt, aes(x = rank, y = popularity, fill = artist.name, color = name)) +
    geom_bar(stat = 'identity') +
    theme_light() +
    theme(legend.position = 'none') +
    ylab("popularity (arbitrary?)") +
    ggtitle("Spotify-Determined Popularity by Rank")
)

## Plotting track number by rank
ggplotly(
  ggplot(top50lt, aes(x = rank, y = track_number, fill = artist.name, color = name)) +
    geom_bar(stat = 'identity') +
    theme_light() +
    theme(legend.position = 'none') +
    ylab("track number") +
    ggtitle("Track Number by Rank")
)

## Plotting the years since track release by rank
## Creating a variable that codes for how many days it's been since the track
## was released
top50lt$album.release_year <- substr(top50lt$album.release_date, 1, 4)
top50lt$album.release_year <- as.numeric(top50lt$album.release_year)
top50lt$years_since_release <- as.numeric(year(today()))-top50lt$album.release_year

ggplotly(
  ggplot(top50lt, aes(x = rank, y = years_since_release, fill = artist.name, color = name)) +
    geom_bar(stat = 'identity') +
    theme_light() +
    theme(legend.position = 'none') +
    ylab("years since track release") +
    ggtitle("Years Since Track Release by Rank")
)

