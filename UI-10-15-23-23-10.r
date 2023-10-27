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
              fluidRow(
              box(
                title = "Filtre par code postal",
                selectInput("codePostalFilter", "Sélectionnez un code postal", choices = unique(df$reverse.postcode), multiple = FALSE)
              ),
              infoBoxOutput("infoBoxVelosDispoMoy", width = 6),
              ),
              fluidRow(
              box(
                title = "Répartition des vélos et places par code postal",
                plotOutput("percentageChart", width = "100%", height = "400px")
              ),
              box(
                title = "Top 3 stations se rapprochant le plus d'une répartition 50%/50% : Velos Disponibles/Places Disponibles ",
                tableOutput("top3StationsTable")
              ),
              ),

      ),
      tabItem(tabName = "donnees",
              DT::dataTableOutput("table")
      )
    )
  )
)



