# install.packages('spotifyr')

library(tidyverse)
library(knitr)
library(lubridate)

## Most important package:
library(spotifyr)


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


## Have to set the client ID and Client Secret
## Got from here: https://developer.spotify.com/dashboard/applications/1d49b45a8ef9432499dbed35cc3fd9cf
## more information here: https://developer.spotify.com/documentation/general/guides/authorization/app-settings/

## Sourcing the actual ID and, more importantly, the secret from another document
## and then placing that script in gitignore

source("../SpotRfy/scripts/221212_dont_upload.R")
get_spotify_credentials()

access_token <- get_spotify_access_token()




# Artist
artist <- get_artist_audio_features('radiohead')

# Top keys used for that artist
artist %>% 
  count(key_mode, sort = TRUE) %>% 
  head(5) %>% 
  kable()

# Recent tracks
get_my_recently_played(limit = 5) %>% 
  mutate(artist.name = map_chr(track.artists, function(x) x$name[1]),
         played_at = as_datetime(played_at)) %>% 
  select(track.name, artist.name, track.album.name, played_at) %>% 
  kable()


# Top artists
get_my_top_artists_or_tracks(type = 'artists', time_range = 'long_term', limit = 25) %>% 
  # select(name, genres) %>% 
  rowwise %>% 
  mutate(genres = paste(genres, collapse = ', ')) %>% 
  ungroup %>%
  View()

get_my_top_artists_or_tracks(type = 'tracks', time_range = 'long_term', limit = 25) %>% 
  mutate(artist.name = map_chr(artists, function(x) x$name[1])) %>% 
  select(name, artist.name, album.name) %>% 
  View()


## What do we actually get when we call get_my_top_artists_or_tracks()?
# Artists
get_my_top_artists_or_tracks(type = 'artists', time_range = 'long_term', limit = 25) %>% 
  View()

# Songs
get_my_top_artists_or_tracks(type = 'tracks', time_range = 'long_term', limit = 25) %>% 
  View()

# Recent tracks
get_my_recently_played(limit = 5) %>%
  View()
