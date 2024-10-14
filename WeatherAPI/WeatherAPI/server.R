library(shiny)
library(httr)
library(jsonlite)
library(lubridate)

shinyServer(function(input, output) {
  
  # Fetch current weather data when button is clicked
  observeEvent(input$get_weather, {
    
    api_key <- "dca6484854b475187c5ca5dadf85278f"
    lat <- input$lat
    lon <- input$lon
    
    api_url <- paste0(
      "https://api.openweathermap.org/data/3.0/onecall?lat=", lat,
      "&lon=", lon,
      "&appid=", api_key
    )
    
    api_response <- GET(api_url)
    
    if (status_code(api_response) == 200) {
      weather_data <- fromJSON(content(api_response, "text", encoding = "UTF-8"))
      
      if (!is.null(weather_data[["current"]])) {
        current_weather <- weather_data[["current"]]
        current_temp <- current_weather[["temp"]]
        current_temp_celsius <- current_temp - 273.15
        current_humidity <- current_weather[["humidity"]]
        wind_speed <- current_weather[["wind_speed"]]
        pressure <- current_weather[["pressure"]]
        visibility <- current_weather[["visibility"]]
        uvi <- current_weather[["uvi"]]
        
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
        
        output$weather_info <- renderTable({ weather_table })
      } else {
        output$weather_info <- renderText({ "Error: 'current' weather data not found." })
      }
    } else {
      output$weather_info <- renderText({ "Error: Unable to fetch weather data. Please check your API key or inputs." })
    }
  })
  
  # Fetch historical weather data when button is clicked
  observeEvent(input$get_history, {
    
    api_key <- "dca6484854b475187c5ca5dadf85278f"
    lat <- input$hist_lat
    lon <- input$hist_lon
    
    # Convert selected date to UNIX timestamp, set time to 12:00 PM UTC
    selected_date <- as.POSIXct(input$date, tz = "UTC")
    noon_time <- selected_date + hours(12)  # 12:00 PM UTC
    unix_time <- as.numeric(noon_time)
    
    # Debugging: Print date, latitude, longitude, and API URL
    print(paste0("Selected Date: ", input$date))
    print(paste0("Latitude: ", lat))
    print(paste0("Longitude: ", lon))
    print(paste0("UNIX Timestamp: ", unix_time))
    
    # Make the API request for historical data
    api_url <- paste0(
      "https://api.openweathermap.org/data/3.0/onecall/timemachine?lat=", lat,
      "&lon=", lon,
      "&dt=", unix_time,
      "&appid=", api_key
    )
    
    api_response <- GET(api_url)
    
    if (status_code(api_response) == 200) {
      # Parse the response content
      history_data <- fromJSON(content(api_response, "text", encoding = "UTF-8"))
      
      # Access the first row of the `data` data frame
      historical_weather <- history_data$data[1, ]  # Accessing the first row
      
      # Extracting the fields from the data frame
      hist_temp <- historical_weather$temp
      hist_temp_celsius <- hist_temp - 273.15
      hist_humidity <- historical_weather$humidity
      hist_wind_speed <- historical_weather$wind_speed
      hist_pressure <- historical_weather$pressure
      hist_visibility <- historical_weather$visibility
      hist_uvi <- historical_weather$uvi
      
      # Create a table with the historical weather data
      history_table <- data.frame(
        Metric = c("Latitude", "Longitude", "Temperature", "Humidity", "Wind Speed", "Pressure", "Visibility", "UV Index"),
        Value = c(lat, lon, 
                  paste0(hist_temp, " K (", round(hist_temp_celsius, 2), " °C)"), 
                  paste0(hist_humidity, " %"), 
                  paste0(hist_wind_speed, " m/s"), 
                  paste0(hist_pressure, " hPa"), 
                  paste0(hist_visibility, " meters"), 
                  hist_uvi)
      )
      
      output$history_info <- renderTable({ history_table })
      
    } else {
      # Display the HTTP status code and error message
      output$history_info <- renderText({ paste("Error: Unable to fetch historical weather data. HTTP Status:", status_code(api_response)) })
    }
  })
})
