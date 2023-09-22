install.packages("leaflet")
# to install the development version from Github, run
# devtools::install_github("rstudio/leaflet")
library(leaflet)
m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R")
m  # Print the map

# Assurez-vous que les noms des colonnes sont corrects
data <- data.frame(df$position.lat, df$position.lng, df$name)
colnames(data) <- c("lat", "long","mag")

# Show first 20 rows from the `quakes` dataset
leaflet(data) %>% addTiles() %>%
  addMarkers(~long, ~lat, popup = ~as.character(mag), label = ~as.character(mag))