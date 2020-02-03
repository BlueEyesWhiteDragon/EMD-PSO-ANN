### 读入数据转化为时间序列
maxTimeSeries = ts(maxTemperatureByDay)

### 数据量
nUse = 360
nPredict = 30

### 取出训练序列和测试序列
nData = nrow(maxTemperatureByDay)
trainInputSeries = maxTimeSeries[(nData - nUse - nPredict + 1):(nData - nPredict)]
testObsSeries = maxTimeSeries[(nData - nPredict + 1):nData]

### 绘制训练序列原始时序图
plot(trainInputSeries, type = "l")

### 白噪声检验，可以在外围用tryCatch包起来
if(isWhiteNoise(trainInputSeries)) {
  stop("原序列是一个白噪声序列，分析停止。")
}

### 平稳性检验
isStationary(trainInputSeries)

### arima建模
trainInput.arima = auto.arima(trainInputSeries)
trainInput.arima

### 输入数据起始位置
indexStart = nData - nPredict - 1

### 预测
predSeries = vector("numeric", nPredict)
for(i in 1:nPredict) {
  predSeries[i] = -0.4815*maxTimeSeries[indexStart] + 1.4815*maxTimeSeries[indexStart + 1]
  indexStart = indexStart + 1
}

### 测试序列
testSeries = maxTimeSeries[(nData - nPredict + 1):nData]

### 求误差
errorList = calError(testSeries, predSeries)
errorList

### 自动拟合
# infoArima_360_30 = getArimaInfo(maxTemperatureByDay, 1800, nPredict)


infoEmdPsoRbf1A_360_30_3_4_1$errorList
