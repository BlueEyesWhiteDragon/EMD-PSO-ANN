### 给出一个序列的ARIMA模型的预测及误差
### INPUT
## data
## nUse
## nPredict
### OUTPUT
## $predSeries
## $errorList
getArimaInfo <- function(data, nUse, nPredict) {
  # 整形
  data = ts(data)
  
  # 序列总长度
  nData = length(data)
  
  # 标定起始位置
  indexStart = nData - nPredict - nUse + 1
  
  # 最终结果向量
  predSeries = vector("numeric", length = nPredict)
  
  # 进行nPredict个arima建模，得到nPredict个1步预测值
  for(i in 1:nPredict) {
    # 截取数据（训练窗口逐渐加宽）
    trainSeries = data[indexStart:(nData - nPredict + i - 1 )]
    
    # 自动arima建模
    trainSeries.arima = auto.arima(trainSeries)
    
    # 1步预测
    trainSeries.fore = forecast(trainSeries.arima, h = 1)
    
    # 将预测结果保存
    predSeries[i] = trainSeries.fore$mean
  }
  
  # 截取测试序列
  testSeries = data[(nData - nPredict + 1):nData]
  
  # 计算预测误差
  errorList = calError(testSeries, predSeries)
  
  # 画图
  par(mfrow = c(1, 1), mar = c(2, 2, 2, 2))
  plot(testSeries, type = "b", lwd = 2, pch = 16)
  lines(predSeries, type = "b", lwd = 1, pch = 5, col = "blue")
  
  return(list(
    predSeries = predSeries,
    errorList = errorList
  ))
}