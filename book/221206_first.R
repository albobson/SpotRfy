# install.packages('spotifyr')

library(spotifyr)
library(tidyverse)
library(knitr)
library(lubridate)

## Most important package:
library(spotifyr)


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
  select(name, genres) %>% 
  rowwise %>% 
  mutate(genres = paste(genres, collapse = ', ')) %>% 
  ungroup %>%
  View()

get_my_top_artists_or_tracks(type = 'tracks', time_range = 'long_term', limit = 25) %>% 
  mutate(artist.name = map_chr(artists, function(x) x$name[1])) %>% 
  select(name, artist.name, album.name) %>% 
  kable()

?get_my_top_artists_or_tracks
