### 求各种数值预测评估值的函数
### INPUT
## trueValue 真实值
## predValue 预测值
### OUTPUT
## list(...)
calError <- function(trueValue, predValue) {
  trueValue = matrix(trueValue, ncol = 1)
  predValue = matrix(predValue, ncol = 1)
  #1.计算绝对误差（Absolute Error，简记为E）
  AE <- trueValue - predValue
  #2.计算相对误差（Relative Error，简记为e）
  RE <- AE*sign(trueValue)/(abs(trueValue)+exp(-10))
  #3.计算平均绝对误差（Mean Absolute Error，简记为MAE）
  MAE<-mean(abs(AE))
  #4.计算均方误差（Mean Squared Error，简记为MSE）
  MSE<-mean(AE^2)
  #5.计算归一化均方误差（Normalized Mean Squared Error，简记为NMSE）
  # NMSE<-sum(AE^2)/sum(trueValue-mean(trueValue))
  #6.计算均方根误差（Root Mean Squared Error，简记为RMSE）
  RMSE<-sqrt(MSE)
  #7.计算平均绝对百分误差（Mean Absolute Percentage Error，简记为MAPE）
  MAPE<-mean(abs(RE))
  #8.计算希尔不等系数（Theil inequality coefficient，简记为TIC）
  # TIC<-RMSE/(sqrt(mean(trueValue^2))+sqrt(mean(predValue^2)))
  #9.计算判定系数（Coefficient Of Determination，一般记为R^2）
  # R2<-1-sum(AE^2)/sum((trueValue-mean(trueValue))^2)
  
  return(list(MAE = MAE, RMSE = RMSE, MAPE = MAPE))
}