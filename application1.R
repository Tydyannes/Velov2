#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

if(!require("shiny")){
  install.packages("shiny")
}
if(!require("markdown")){
  install.packages("markdown")
}
if(!require("leaflet")){
  install.packages("leaflet")
}


# Définir UI pour l'application
ui <- navbarPage(
  "Velo'v",
  tabPanel(
    "Accueil",
    sidebarLayout(
      sidebarPanel(
        radioButtons(
          "plotType",
          "Filtre Station",
          c("Velo disponible" = "p", "Place disponible" = "l")
        )
      ),
      mainPanel(
        leafletOutput("plot")
      )
    )
  ),
  tabPanel(
    "Stations",
    verbatimTextOutput("summary")
  ),
  tabPanel(
    "Donées",
    DT::dataTableOutput("table")
  )
)

# Définir la logique du serveur
server <- function(input, output, session) {
  output$plot <- renderLeaflet({
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
  })
  
  output$summary <- renderPrint({
    summary(cars)
  })
  
  output$table <- DT::renderDataTable({
    DT::datatable(cars)
  })
}

# Exécuter l'application
shinyApp(ui = ui, server = server)


