## The complete dataset was finally ready, however it's in a slightly different
## format than the recen dataset.

## Need to write code that downloads and parses through that data and gets it 
## into a format similar to the previous data

source("C:/Users/meowy/OneDrive/Documents/R/Projects/SpotRfy/scripts/spotRfy_master.R")

setwd("~/R/Projects/SpotRfy/book/221223")

ltdf <- import_lifetime_streaming_data(datafile = "~/R/Projects/SpotRfy/data/total")

lttracks <- get_lifetime_tracks(ltdf)

# ltpods <- get_lifetime_podcasts(ltdf)

## Filtering to songs played more than 25 seconds

sm_lttracks <- lttracks %>%
  filter(msPlayed > 30000)

clttracks <- clean_spotify_streaming_data(data = sm_lttracks, your_timezone = "EST", data_length = "lifetime")

View(clttracks)

## It's just too many datapoints for plotly data. Restricting to just songs 
## that had more than 10 plays
small <- clttracks %>%
  filter(num_times_song_played >=20)


sm_lifetime_plot <- plot_streaming_timeofday(small, artist_cutoff = 15)

sm_lifetime_plot
Shtmlwidgets::saveWidget(widget = sm_lifetime_plot, #the plotly object
                        file = "221223_sm_lifetime_tod.html", #the path & file name
                        selfcontained = TRUE #creates a single html file
)

bar_lifetime_plot <- plot_streaming_artists(clttracks, artist_cutoff = 20)

bar_lifetime_plot
