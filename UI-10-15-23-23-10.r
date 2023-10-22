if(!require("shinydashboard")){
  install.packages("shinydashboard")
}
library(shinydashboard)
library(shiny)

# UI
ui <- dashboardPage(
  dashboardHeader(title = "Velo'v Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Accueil", tabName = "accueil"),
      menuItem("Stations", tabName = "stations"),
      menuItem("Données", tabName = "donnees")
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "accueil",
              fluidRow(
                box(
                  title = "Filtre par station",
                  selectInput("stationFilter", "Sélectionnez des stations", choices = unique(df$name), multiple = TRUE)
                ),
                box(
                  title = "Carte Vélo'v de Lyon",
                  leafletOutput("plot", width = "120%", height = "850px")
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


