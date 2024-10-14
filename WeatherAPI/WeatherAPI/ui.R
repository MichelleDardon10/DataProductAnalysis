library(shiny)

shinyUI(fluidPage(
  titlePanel("Weather Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      # Dynamic inputs for latitude and longitude
      textInput("lat", "Latitude", value = "14.63"),   # Default latitude
      textInput("lon", "Longitude", value = "-90.50"), # Default longitude
      actionButton("get_weather", "Get Weather")
    ),
    
    mainPanel(
      tableOutput("weather_info")  # Output table instead of plain text
    )
  )
))


#Guatemala City, Guatemala:
#Latitude: 14.634915
#Longitude: -90.506882

#Florida, USA:
#Latitude: 27.9944024
#Longitude: -81.7602544

#Moscow, Russia:
#Latitude: 55.751244
#Longitude: 37.618423


#Australia:
#Latitude: -25.274398
#Longitude: 133.775136