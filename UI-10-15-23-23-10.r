if(!require("shinydashboard")){
  install.packages("shinydashboard")
}
library(shinydashboard)
library(shiny)

# UI
ui <- dashboardPage(
  dashboardHeader(
    title = "Velo'v Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      id = "tabs",
      menuItem("Accueil", tabName = "accueil"),
      menuItem("Stations", tabName = "stations"),
      menuItem("Données", tabName = "donnees"),
      actionButton("refreshButton", "Refresh", icon("refresh"), style = "margin-top: 20px;"),
      textInput("message", label = "Message de confirmation", value = "")
      
      )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "accueil",
              fluidRow(
                box(
                  title = "Filtre par station",
                  selectInput("stationFilter", "Sélectionnez des stations", choices = unique(df$name), multiple = FALSE)
                ),
                infoBoxOutput("infoBoxVelosDispo", width = 3),
                infoBoxOutput("infoBoxPlacesDispo", width = 3)
              ),
              fluidRow(
                box(
                  title = "Carte Vélo'v de Lyon", width = 12,
                  leafletOutput("plot", width = NULL, height = "700px")
                )
              )
      ),
      tabItem(tabName = "stations",
              box(
                title = "Filtre par code postal",
                selectInput("codePostalFilter", "Sélectionnez un code postal", choices = unique(df$reverse.postcode), multiple = TRUE)
              ),
              box(
                title = "Nombre total de vélos disponibles",
                textOutput("totvelodispo")
              ),
              box(
                title = "Nombre total de places en station disponibles",
                textOutput("totplacedispo")
              ),
              verbatimTextOutput("summary")
      ),
      tabItem(tabName = "donnees",
              DT::dataTableOutput("table")
      )
    )
  )
)



