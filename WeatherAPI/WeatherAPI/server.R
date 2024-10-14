library(shiny)
library(httr)
library(jsonlite)

shinyServer(function(input, output) {
  
  observeEvent(input$get_weather, {
    
    # Your API key
    api_key <- "dca6484854b475187c5ca5dadf85278f"
    
    # Get latitude and longitude dynamically from user input
    lat <- input$lat
    lon <- input$lon
    
    # Build the API URL using dynamic lat and lon
    api_url <- paste0(
      "https://api.openweathermap.org/data/3.0/onecall?lat=", lat,
      "&lon=", lon,
      "&appid=", api_key
    )
    
    # Make the API call
    api_response <- GET(api_url)
    
    # Check if the API call was successful
    if (status_code(api_response) == 200) {
      # Parse the JSON response
      weather_data <- fromJSON(content(api_response, "text", encoding = "UTF-8"))
      
      # Safely access 'current' field
      if (!is.null(weather_data[["current"]])) {
        current_weather <- weather_data[["current"]]
        
        # Safely access fields (temperature, humidity, wind speed, pressure, visibility, and UV index)
        current_temp <- current_weather[["temp"]]   # Temperature in Kelvin
        current_temp_celsius <- current_temp - 273.15  # Convert to Celsius
        current_humidity <- current_weather[["humidity"]]
        wind_speed <- current_weather[["wind_speed"]]
        pressure <- current_weather[["pressure"]]
        visibility <- current_weather[["visibility"]]
        uvi <- current_weather[["uvi"]]
        
        # Create a table to display the weather data
        weather_table <- data.frame(
          Metric = c("Latitude", "Longitude", "Current Temperature", "Humidity", "Wind Speed", "Pressure", "Visibility", "UV Index"),
          Value = c(lat, lon, 
                    paste0(current_temp, " K (", round(current_temp_celsius, 2), " °C)"), 
                    paste0(current_humidity, " %"), 
                    paste0(wind_speed, " m/s"), 
                    paste0(pressure, " hPa"), 
                    paste0(visibility, " meters"), 
                    uvi)
        )
        
        # Display the table in the UI
        output$weather_info <- renderTable({
          weather_table
        })
      } else {
        output$weather_info <- renderText({
          "Error: 'current' weather data not found."
        })
      }
      
    } else {
      output$weather_info <- renderText({
        "Error: Unable to fetch weather data. Please check your API key or inputs."
      })
    }
  })
})
