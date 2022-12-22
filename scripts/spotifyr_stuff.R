library(tidyverse)
library(knitr)
library(lubridate)
library(dplyr)
library(ggplot2)
library(spotifyr)
library(plotly)


## Have to set the client ID and Client Secret
## Got from here: https://developer.spotify.com/dashboard/applications/1d49b45a8ef9432499dbed35cc3fd9cf
## more information here: https://developer.spotify.com/documentation/general/guides/authorization/app-settings/

## Sourcing the actual ID and, more importantly, the secret from another document
## and then placing that script in gitignore

source("~/R/Projects/SpotRfy/scripts/221212_dont_upload.R")

## Calling from the non-uploaded script to get the secret ID
get_spotify_credentials()

access_token <- get_spotify_access_token()
