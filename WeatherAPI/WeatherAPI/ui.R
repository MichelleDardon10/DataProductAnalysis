library(shiny)

shinyUI(navbarPage(
  "Weather Dashboard",
  
  # Add custom CSS for styling with sage green and a darker shade for the title
  tags$head(
    tags$style(HTML("
      .table-bordered {
        border: 2px solid #9CBA7F;  /* Sage green border */
        border-radius: 8px;         /* Rounded corners */
        padding: 10px;              /* Padding inside the table */
      }
      .table th {
        background-color: #9CBA7F;  /* Sage green background for headers */
        color: white;               /* White text for headers */
        font-weight: bold;          /* Bold header text */
      }
      .table td {
        padding: 8px;               /* Padding for table data cells */
      }
      .title {
        font-size: 26px;            /* Larger font for the title */
        font-weight: bold;          /* Bold text */
        color: #6B8E23;             /* Darker sage green for the title */
        text-align: center;         /* Centered title */
        margin-bottom: 20px;        /* Space below the title */
      }
    "))
  ),
  
  # First page for current and historical weather data (left and right side layout)
  tabPanel("Current & Historical Weather",
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
  ),
  
  # New page for wind data
  tabPanel("Wind Data",
           fluidRow(
             column(6,  # Left side for wind speed and direction
                    wellPanel(
                      textInput("wind_lat", "Latitude (Wind Data)", value = "14.63"),   # Default latitude (Guatemala City)
                      textInput("wind_lon", "Longitude (Wind Data)", value = "-90.5"),  # Default longitude (Guatemala City),
                      
                      sliderInput("days", "Select the number of days (negative for past, positive for forecast):", 
                                  min = -5, max = 5, value = 0, step = 1),  # Slider for days (from -5 to 5)
                      
                      actionButton("get_wind", "Get Wind Data")  # Button to get wind data
                    ),
                    tableOutput("wind_data")  # Output for wind speed and direction data
             ),
             
             column(6,  # Right side for any future visualizations (e.g., wind direction chart)
                    plotOutput("wind_plot")  # Placeholder for potential wind speed/direction visualizations
             )
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