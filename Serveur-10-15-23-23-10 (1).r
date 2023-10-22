install.packages(c("httr","jsonlite"))
library(httr)
library(jsonlite)

if(!require("tidygeocoder")){
  install.packages("tidygeocoder")
}
library(dplyr, warn.conflicts = FALSE)
if(!require("ggplot2")){
  install.packages("ggplot2")
}
if(!require("shiny")){
  install.packages("shiny")
}

if(!require("markdown")){
  install.packages("markdown")
}
if(!require("leaflet")){
  install.packages("leaflet")
}
if(!require("DT")){
  install.packages("DT")
}

raw_data <-  GET('https://api.jcdecaux.com/vls/v3/stations?contract=Lyon&apiKey=fc41d1b1016a6b95f0f755048a0690a80719ab50') #importation des données du site internet sur Rstudio

df <- fromJSON ( rawToChar ( raw_data$content ) , flatten =  TRUE ) #Conversion des données en bloc de données
df <- subset(df, !(rownames(df) == 326))

if(!require("RMySQL")){
  install.packages("RMySQL")
}
library("RMySQL")
plouf <- dbConnect(MySQL(),
                   user = "sql11645724" ,
                   password = "C7MWFfpDxs" ,
                   host = "sql11.freesqldatabase.com" ,
                   dbname = "sql11645724",)


#id_cp <- df[, c("number",reverse$postcode)] Extraction des colonnes
#write.csv(id_cp, "id_cp.csv", row.names = FALSE) Exportation du csv
id_geocoded <- read.csv("id_cp.csv",header = T,sep = ",")
df <- merge(df, id_geocoded, by = "number")

# Calculer le nombre total de vélos disponibles
totvelodispo <- sum(df$totalStands.availabilities.bikes)

# Calculer le nombre total de places de station disponibles
totplacedispo <- sum(df$totalStands.availabilities.stands)

server <- function(input, output, session) {
  output$plot <- renderLeaflet({
    library(leaflet)
    m <- leaflet() %>%
      addTiles() %>% 
      addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R")
    m

    data <- data.frame(df$position.latitude, df$position.longitude, df$name)
    colnames(data) <- c("lat", "long","mag")
 
    leaflet(data) %>% addTiles() %>%
      addMarkers(~long, ~lat,
                 clusterOptions = markerClusterOptions(),
                 popup = paste("Station : ", df$name, "<br>" ,
                                            "Nombre de places de velos disponibles : ", df$totalStands.availabilities.stands, "<br>" ,
                                            "Nombre de velos disponibles : ", df$totalStands.availabilities.bikes, "<br>" ,
                                            "Etat de la station : ", df$status))
    })
  
  
  selectedStations <- reactive({
    if (!is.null(input$stationFilter) && length(input$stationFilter) > 0) {
      return(input$stationFilter)
    } else {
      return(unique(df$station))
    }
  })
  selectedPostalCodes <- reactive({
    if (!is.null(input$codePostalFilter) && length(input$codePostalFilter) > 0) {
      return(input$codePostalFilter)
    } else {
      return(unique(df$reverse.postcode))
    }
  })
  
  output$totvelodispo <- renderText({
    df_filtered <- df[df$reverse.postcode %in% selectedPostalCodes(), ]
    sum(df_filtered$totalStands.availabilities.bikes)
  })
  
  output$totplacedispo <- renderText({
    df_filtered <- df[df$reverse.postcode %in% selectedPostalCodes(), ]
    sum(df_filtered$totalStands.availabilities.stands)
  })
  
  output$summary <- renderPrint({
    summary(cars)
  })
  
  output$table <- DT::renderDataTable({
    DT::datatable(cars)
  })
}



