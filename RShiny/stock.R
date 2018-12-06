#------dev.off() if plot does not appear
install.packages("quantmod")
install.packages("tseries")
install.packages("timeSeries")
install.packages("forecast")
install.packages("xts")


library(quantmod)
library(tseries)
library(timeSeries)
library(forecast)
library(xts)
library(ggplot2)
#----de hagep beha p ,d, q hya btgrp arima model  l7d ma ttl3 a7sen p,d,q
#----------------------to Get Order of P ,d,q----------------------
getSymbols('AAPL',src='yahoo' ,from='2016-01-01')
AAPL = diff(log(Cl(AAPL)))
azfinal.aic <- Inf
azfinal.order <- c(0,0,0)
for (p in 1:4) for (d in 0:1) for (q in 1:4) {
  azcurrent.aic <- AIC(arima(AAPL, order=c(p, d, q)))
  if (azcurrent.aic < azfinal.aic) {
    azfinal.aic <- azcurrent.aic
    azfinal.order <- c(p, d, q)
    azfinal.arima <- arima(AAPL, order=azfinal.order)
  }
}
print(azfinal.order) #this show p d q
#--------------------------------------------------------------------
# Pull data from Yahoo finance 
getSymbols('AAPL',src='yahoo' ,from='2016-01-01')
plot(AAPL)

#ggplot(AAPL , aes(AAPL$AAPL.High))+geom_histogram()
# Select the relevant close price series
stock_prices = AAPL[,4]
plot(stock_prices)
#we compute the logarithmic returns of the stock 
#as we want the ARIMA model to forecast
#the log returns and not the stock price.
#We also plot the log return series using the plot function.
# Compute the log returns for the stock
stock = diff(log(stock_prices),lag=1)#ln(current/previous) w diff btshel el trend el nateg W 3ml diff 3shan yshel trend mn series
stock = stock[!is.na(stock)]#de btshel el null lw fe nateg mn elli fo2

# Plot log returns 010
plot(stock,type='l', main='log returns plot')

# Conduct ADF(Augmented Dickey-Fuller unit root test) test on log returns series
#if p-value is lower than 0.05 or 5% time series is stationary 
print(adf.test(stock))#hattl3 p-value t7tt b 0.01 yb2a series is stationary
#----------------------------------------------------------------------
# Split the dataset in two parts - training and testing
#de hat7ot fe variable breakpoint 715 rows y3nii 715 days 
#w e7na 3ndna stock kol 730 days yp2a kda ana ha3ml forecast le 15 days
#breakpoint = floor(nrow(stock)*(7.9/8)) de tal3 accuracy 50%
#breakpoint = floor(nrow(stock)*(2.9/3)) de tal3 accuracy 60%
breakpoint = floor(nrow(stock)*(4.9/5))# de tal3 accuracy 66.7%
# Apply the ACF and PACF functions
par(mfrow = c(1,1))
#we set up a plotting environment of one row and one column (in order to hold one graph)
acf.stock = acf(stock[c(1:breakpoint),], main='ACF Plot')

pacf.stock = pacf(stock[c(1:breakpoint),], main='PACF Plot')

# Initialzing an xts object for Actual log returns
#de 3mlt time series fadya 3shan ab2a a7ot feha el actual series elli bto3 15 days
Actual_series = xts(0,as.Date("2018-11-01","%Y-%m-%d"))

#de ha3ml dataframe 3shan a7ot feha el forecasted bto3 el 15days
# Initialzing a dataframe for the forecasted return series
forecasted_series = data.frame(Forecasted = numeric())
#-------------------------------------------------------
#de b2a for loop hat3dii 3la kol 15 days w tqrnohom b ba2ii eldays 3shan tml model 
#w t forecast 3la 15days
for (b in breakpoint:(nrow(stock)-1)) {
  
  stock_train = stock[1:b, ]
  stock_test = stock[(b+1):nrow(stock), ]
  
  # Summary of the ARIMA model using the determined (p,d,q) parameters
  fit = arima(stock_train, order = c(1, 0, 4),include.mean=FALSE)
  summary(fit)
  
  # plotting a acf plot of the residuals
  ##acf(fit$residuals,main="Residuals plot")
  
  # Forecasting the log returns
  arima.forecast = forecast(fit, h = 1,level=99)
  # level de confidence level y3nii ana 3wza tb2a confidence b 99% 
  # w h = is the number of values that we want to forecast elii hya day day 
  #arima.forecast = forecast.Arima(fit, h = 1,level=99)
  summary(arima.forecast)
  
  # plotting the forecast
  par(mfrow=c(1,1))
  plot(arima.forecast, main = "ARIMA Forecast")
  
  #hna b2a 3ml combine ll rows mn forecasted_series elli ana 3mllaha fo2 bl values el forecasted
  # Creating a series of forecasted returns for the forecasted period
  forecasted_series = rbind(forecasted_series,arima.forecast$mean[1])
  #5la asm el column bt3ha Forecasted
  colnames(forecasted_series) = c("Forecasted")
  
  # Creating a series of actual returns for the forecasted period
  Actual_return = stock[(b+1),]
  Actual_series = c(Actual_series,xts(Actual_return))
  rm(Actual_return)
  
  print(stock_prices[(b+1),])
  print(stock_prices[(b+2),])
}
#----------------------------------------
#arima.forecast
#plot(arima.forecast)
#------------------------------------------------------------
#------------------------------------------------------------
#plot(residuals(fit))
#-----------------------------------------------------------

# Adjust the length of the Actual return series
Actual_series = Actual_series[-1]

# Create a time series object of the forecasted series
forecasted_series = xts(forecasted_series,index(Actual_series))

# Create a plot of the two return series - Actual versus Forecasted
plot(Actual_series,type='l',main='Actual Returns Vs Forecasted Returns')
lines(forecasted_series,lwd=1.5,col='red')
legend('bottomright',c("Actual","Forecasted"),lty=c(1,1),lwd=c(1.5,1.5),col=c('black','red'))

#hna 3ml comparison ben Actual_series (elli hya gbha asln mn el data elli 3ndii)
#,forecasted_series (elli 3mlha forecast mn el model)
# Create a table for the accuracy of the forecast
comparsion = merge(Actual_series,forecasted_series)
#7ot nateg el comparison fe column accuracy elli hwa 1-> lw c 
# w 0 -> lw Actual,Forecasted el sign mo5tlfen
comparsion$Accuracy = sign(comparsion$Actual_series)==sign(comparsion$Forecasted)
print(comparsion)

# Compute the accuracy percentage metric
Accuracy_percentage = sum(comparsion$Accuracy == 1)*100/length(comparsion$Accuracy)
print(Accuracy_percentage)

