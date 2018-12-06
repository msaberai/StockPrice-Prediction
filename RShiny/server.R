
library(shiny)
library(quantmod)
library(tseries)
library(timeSeries)
library(forecast)
library(xts)

# Define server logic required to draw a histogram
shinyServer(function(input , output){
  ## Run area
  observeEvent(input$upload,{
    selectdata (input, output)
    view_dataset(input,output)
    plot_close(input,output)
    plot_stationary(input,output)
    plot_acf_pacf(input,output)
    comparison (input,output)
    view_accuracy(input,output)
  })
  
})
################## Functions Area ###########################

selectdata <- function(input, output) 
  {
  output$value  <- renderPrint({ input$radio })
  }


upload_data <- function(input,output) # AAPL | GOOG | MSFT | AMZN | SPY | LMT | BA
{
  #n = selectdata(input,output)
  getSymbols("SPY" ,src='yahoo' ,from='2016-01-01')
  return(SPY)
}

view_dataset <- function(input,output)
{
  df <- upload_data(input,output)
  output$my_data <- renderDataTable({
    return(df)
  },options = list(scrollX=TRUE))
}

plot_close <- function(input,output)
{
  dataa = upload_data(input,output)
  stock_prices = dataa[,4]
  output$plot_close <- renderPlot({
    plot(stock_prices)
  })
  return(stock_prices)
}
  plot_stationary <- function(input,output)
  {
    stock_prices <-plot_close(input,output) 
    stock = diff(log(stock_prices),lag=1)
    stock = stock[!is.na(stock)]
    output$plot_stationary <- renderPlot({
      plot(stock)
      
    })
    return(stock)
  }
  plot_acf_pacf <- function(input,output)
  {
    stock <-plot_stationary(input,output)
    breakpoint = floor(nrow(stock)*(4.9/5))
    output$plot_acf <- renderPlot({
      acf.stock = acf(stock[c(1:breakpoint),], main='ACF Plot')
    })
    output$plot_pacf <- renderPlot({
      pacf.stock = pacf(stock[c(1:breakpoint),], main='PACF Plot')
    })
    return(breakpoint)
  }
  comparison <-function(input,output){
    stock_prices <-plot_close(input,output)
    stock <-plot_stationary(input,output)
    breakpoint <-plot_acf_pacf(input,output)
    Actual_series = xts(0,as.Date("2018-11-01","%Y-%m-%d"))
    forecasted_series = data.frame(Forecasted = numeric())
    for (b in breakpoint:(nrow(stock)-1)) {
      stock_train = stock[1:b, ]
      stock_test = stock[(b+1):nrow(stock), ]
      # Summary of the ARIMA model using the determined (p,d,q) parameters
      fit = arima(stock_train, order = c(1, 0, 4),include.mean=FALSE)
      #summary(fit)
      # Forecasting the log returns
      arima.forecast = forecast(fit, h = 1,level=99)
      #plot(arima.forecast, main = "ARIMA Forecast")
      # Creating a series of forecasted returns for the forecasted period
      forecasted_series = rbind(forecasted_series,arima.forecast$mean[1])
      colnames(forecasted_series) = c("Forecasted")
      # Creating a series of actual returns for the forecasted period
      Actual_return = stock[(b+1),]
      Actual_series = c(Actual_series,xts(Actual_return))
      rm(Actual_return)
      print(stock_prices[(b+1),])
      print(stock_prices[(b+2),])
    }
    Actual_series = Actual_series[-1]
    forecasted_series = xts(forecasted_series,index(Actual_series))
    output$plot_afp<- renderPlot({
      plot(Actual_series,main='Actual Returns Vs Forecasted Returns');
      lines(forecasted_series,col='red');
    })
    
    comparsion = merge(Actual_series,forecasted_series)
    comparsion$Accuracy = sign(comparsion$Actual_series)==sign(comparsion$Forecasted)
    Accuracy_percentage = sum(comparsion$Accuracy == 1)*100/length(comparsion$Accuracy)
    
     output$my_comparison <- renderDataTable({
      return(comparsion )
    },options = list(scrollX=TRUE))
     
     return(Accuracy_percentage)
  }
  
  view_accuracy <-function(input,output){
    df <-comparison(input,output)
    output$Accuracy_Box <- renderValueBox({
      valueBox(
        paste0(df,"%"),"Model Accuracy",color = "aqua",width = 20
        ,icon = icon("thumbs-up")
      )
    })
    
  }
  
  
  
  
 
  