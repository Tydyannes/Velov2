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
      addTiles()
    
    if (!is.null(input$stationFilter) && length(input$stationFilter) > 0) {
      selected_station <- df[df$name %in% input$stationFilter, ]
      
      if (!is.null(selected_station) && nrow(selected_station) > 0) {
        m <- m %>% setView(lng = selected_station$position.longitude, lat = selected_station$position.latitude, zoom = 18)
      }
    }

    data <- data.frame(df$position.latitude, df$position.longitude, df$name)
    colnames(data) <- c("lat", "long","mag")
 
     m <- m %>% addMarkers(
       data = data,
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
  
  output$infoBoxVelosDispo <- renderInfoBox({
    df_filtered <- df[df$name %in% input$stationFilter, ]
    velos_dispo <- sum(df_filtered$totalStands.availabilities.bikes)
    infoBox(
      "Velos disponibles", paste0(velos_dispo, " vélos"),
      icon = icon("bicycle")
    )
  })
  
  # Calculer le nombre total de places en station disponibles et mettre à jour l'infoBox
  output$infoBoxPlacesDispo <- renderInfoBox({
    df_filtered <- df[df$name %in% input$stationFilter, ]
    places_dispo <- sum(df_filtered$totalStands.availabilities.stands)
    infoBox(
      "Places disponibles", paste0(places_dispo, " places"),
      icon = icon("map-marker")
    )
  })
  
  observeEvent(input$refreshButton, {
    raw_data <-  GET('https://api.jcdecaux.com/vls/v3/stations?contract=Lyon&apiKey=fc41d1b1016a6b95f0f755048a0690a80719ab50')
    new_df <- fromJSON ( rawToChar ( raw_data$content ) , flatten =  TRUE )
    new_df <- subset(df, !(rownames(df) == 326))
    new_df <- merge(df, id_geocoded, by = "number")
    updateTextInput(session, "message", value = "Données rafraîchies :)")
  })
  
  output$table <- DT::renderDataTable({
    DT::datatable(cars)
  })
}



