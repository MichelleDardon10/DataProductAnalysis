library(shiny)
library(httr)
library(jsonlite)
library(ggplot2)
library(DT)

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
  
  # Render current weather data in a table
  output$weather_info <- renderDT({
    current_data <- current_weather_data()
    
    if (is.null(current_data)) {
      return(NULL)
    }
    
    current_temp_celsius <- current_data$temp - 273.15
    
    datatable(data.frame(
      "Parameter" = c("Temperature (K)", "Temperature (°C)", "Feels Like", "Humidity", "Wind Speed", "Pressure", 
                      "Visibility", "UV Index", "Clouds"),
      "Value" = c(current_data$temp, round(current_temp_celsius, 2), current_data$feels_like, 
                  current_data$humidity, current_data$wind_speed, current_data$pressure, 
                  current_data$visibility, current_data$uvi, current_data$clouds)
    ), selection = "single")
  })
  
  # Render historical weather data in a table
  output$history_info <- renderDT({
    hist_data <- historical_weather_data()
    
    if (is.null(hist_data)) {
      return(NULL)
    }
    
    hist_temp_celsius <- hist_data$temp - 273.15
    
    datatable(data.frame(
      "Parameter" = c("Temperature (K)", "Temperature (°C)", "Feels Like", "Humidity", "Wind Speed", "Pressure", 
                      "Visibility", "UV Index", "Clouds"),
      "Value" = c(hist_data$temp, round(hist_temp_celsius, 2), hist_data$feels_like, 
                  hist_data$humidity, hist_data$wind_speed, hist_data$pressure, 
                  hist_data$visibility, hist_data$uvi, hist_data$clouds)
    ), selection = "single")
  })
  
  # Render the selected parameter's trend over the past 5 days
  output$param_plot <- renderPlot({
    selected_row <- input$history_info_rows_selected
    
    if (is.null(selected_row)) {
      return(NULL)
    }
    
    # Simulate data for the selected parameter over the last 5 days
    selected_param <- colnames(historical_weather_data())[selected_row]
    past_data <- rnorm(5, mean = 20, sd = 5)  # Simulated data for now
    
    ggplot(data.frame(Date = Sys.Date() - 5:1, Value = past_data), aes(x = Date, y = Value)) +
      geom_line(color = "blue") +
      geom_point() +
      labs(title = paste("Trend of", selected_param, "over the last 5 days"),
           x = "Date", y = selected_param) +
      theme_minimal()
  })
})
