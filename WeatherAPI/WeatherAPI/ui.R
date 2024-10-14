library(shiny)

shinyUI(fluidPage(
  
  # Add custom CSS for styling
  tags$head(
    tags$style(HTML("
      .table-bordered {
        border: 2px solid #4CAF50;  /* Green border for the table */
        border-radius: 8px;         /* Rounded corners */
        padding: 10px;              /* Padding inside the table */
      }
      .table th {
        background-color: #4CAF50;  /* Green background for headers */
        color: white;               /* White text for headers */
        font-weight: bold;          /* Bold header text */
      }
      .table td {
        padding: 8px;               /* Padding for table data cells */
      }
      .title {
        font-size: 24px;            /* Larger font for title */
        font-weight: bold;          /* Bold text */
        color: #4CAF50;             /* Green color for the title */
        text-align: center;         /* Centered title */
        margin-bottom: 20px;        /* Space below the title */
      }
    "))
  ),
  
  # Main content with titles and tables
  div("Weather Dashboard", class = "title"),  # Corrected title with styling
  
  fluidRow(
    column(6,  # Left side for current weather
           wellPanel(
             textInput("lat", "Latitude (Current Weather)", value = "14.63"),   # Default latitude (Guatemala City)
             textInput("lon", "Longitude (Current Weather)", value = "-90.5"),  # Default longitude (Guatemala City)
             actionButton("get_weather", "Get Weather")
           ),
           tableOutput("weather_info")  # Output for current weather data
    ),
    
    column(6,  # Right side for historical weather
           wellPanel(
             textInput("hist_lat", "Latitude (Historical Data)", value = "14.63"),   # Default latitude (Guatemala City)
             textInput("hist_lon", "Longitude (Historical Data)", value = "-90.5"),  # Default longitude (Guatemala City)
             dateInput("date", "Select a Date for Historical Data", value = Sys.Date() - 1, 
                       min = Sys.Date() - 5, max = Sys.Date() - 1),  # Allow up to 5 days in the past
             actionButton("get_history", "Get Historical Weather")
           ),
           tableOutput("history_info")  # Output for historical weather data
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