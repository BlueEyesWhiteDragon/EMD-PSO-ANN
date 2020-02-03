### 求适应度
### INPUT
## trueValue 真实值
## predValue 预测值
### OUTPUT
## fitnessValue 适应度
fitness <- function(trueValue, predValue) {
  trueValue = matrix(trueValue, ncol = 1)
  predValue = matrix(predValue, ncol = 1)
  errorList = calError(trueValue, predValue)
  fitnessValue = errorList$RMSE
  return(fitnessValue)
}