#Graphique
install.packages(c("httr","jsonlite"))
library(httr)
library(jsonlite)
raw_data <-  GET('https://api.jcdecaux.com/vls/v1/stations?contract=Lyon&apiKey=fc41d1b1016a6b95f0f755048a0690a80719ab50') #importation des données du site internet sur Rstudio

df <- fromJSON ( rawToChar ( raw_data$content ) , flatten =  TRUE ) #Conversion des données en bloc de données
df <- subset(df, !(rownames(df) == 326))

velodispo <- sum(df$available_bikes)

