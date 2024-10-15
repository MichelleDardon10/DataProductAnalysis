library(shiny)
library(httr)
library(jsonlite)

shinyServer(function(input, output) {
  
  # Reactive expression for current weather data
  current_weather_data <- reactive({
    input$get_weather  # This triggers the reactivity
    isolate({
      lat <- input$lat
      lon <- input$lon
      
      api_key <- "dca6484854b475187c5ca5dadf85278f"
      api_url <- paste0("https://api.openweathermap.org/data/3.0/onecall?lat=", lat,
                        "&lon=", lon, "&exclude=minutely,hourly,daily,alerts&appid=", api_key)
      
      response <- GET(api_url)
      
      if (status_code(response) != 200) {
        return(NULL)
      }
      
      weather_data <- fromJSON(content(response, "text", encoding = "UTF-8"))
      return(weather_data$current)
    })
  })
  
  # Reactive expression for historical weather data
  historical_weather_data <- reactive({
    input$get_history  # This triggers the reactivity
    isolate({
      lat <- input$hist_lat
      lon <- input$hist_lon
      date <- input$date
      
      unix_time <- as.numeric(as.POSIXct(date, tz = "UTC"))
      api_key <- "dca6484854b475187c5ca5dadf85278f"
      api_url_hist <- paste0("https://api.openweathermap.org/data/3.0/onecall/timemachine?lat=", lat,
                             "&lon=", lon, "&dt=", unix_time, "&appid=", api_key)
      
      response_hist <- GET(api_url_hist)
      
      if (status_code(response_hist) != 200) {
        return(NULL)
      }
      
      data_hist <- fromJSON(content(response_hist, "text", encoding = "UTF-8"))
      return(data_hist$data)
    })
  })
  
  # Render current weather data only after the button is pressed
  output$weather_info <- renderTable({
    current_data <- current_weather_data()
    
    if (input$get_weather == 0 || is.null(current_data)) {
      return(NULL)  # Do not render table until button is pressed
    }
    
    # Convert temperature to Celsius
    current_temp_celsius <- current_data$temp - 273.15
    
    data.frame(
      "Parameter" = c("Temperature (K)", "Temperature (°C)", "Feels Like", "Humidity", "Wind Speed", "Pressure", 
                      "Visibility", "UV Index", "Clouds"),
      "Value" = c(current_data$temp, round(current_temp_celsius, 2), current_data$feels_like, 
                  current_data$humidity, current_data$wind_speed, current_data$pressure, 
                  current_data$visibility, current_data$uvi, current_data$clouds)
    )
  })
  
  # Render historical weather data only after the button is pressed
  output$history_info <- renderTable({
    hist_data <- historical_weather_data()
    
    if (input$get_history == 0 || is.null(hist_data)) {
      return(NULL)  # Do not render table until button is pressed
    }
    
    # Handle missing fields in historical data
    temp <- ifelse(!is.null(hist_data$temp), hist_data$temp, NA)
    feels_like <- ifelse(!is.null(hist_data$feels_like), hist_data$feels_like, NA)
    humidity <- ifelse(!is.null(hist_data$humidity), hist_data$humidity, NA)
    wind_speed <- ifelse(!is.null(hist_data$wind_speed), hist_data$wind_speed, NA)
    pressure <- ifelse(!is.null(hist_data$pressure), hist_data$pressure, NA)
    visibility <- ifelse(!is.null(hist_data$visibility), hist_data$visibility, NA)
    uvi <- ifelse(!is.null(hist_data$uvi), hist_data$uvi, NA)
    clouds <- ifelse(!is.null(hist_data$clouds), hist_data$clouds, NA)
    
    # Convert temperature to Celsius
    hist_temp_celsius <- temp - 273.15
    
    data.frame(
      "Parameter" = c("Temperature (K)", "Temperature (°C)", "Feels Like", "Humidity", "Wind Speed", "Pressure", 
                      "Visibility", "UV Index", "Clouds"),
      "Value" = c(temp, round(hist_temp_celsius, 2), feels_like, humidity, wind_speed, pressure, 
                  visibility, uvi, clouds)
    )
  })
  
})
