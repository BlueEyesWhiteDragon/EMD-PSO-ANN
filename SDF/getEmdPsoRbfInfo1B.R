### 传入原始数据和结构参数，对上面得到的含有nPredict个emd结果的大型list，进行PSO-RBF建模。nInput和nHidden分别暂定为3和4
### INPUT
## data
## nPredict
## nUse
## nInput
## nHidden
## nOutput
### OUTPUT
## $testPredMat
## $testErrorList
getEmdPsoRbfInfo1B <- function(data, nPredict, nUse, nInput, nHidden, nOutput) {
  # 数据集长度
  nData = nrow(data)
  # 提取最后nPredict项作为测试观测值
  testObsMat = matrix(data[(nData - nPredict + 1):nData, ])
  # 对原始数据进行EMD分解
  emdList = getEmdList1B(data, nPredict, nUse)
  # 存放nPredict个预测值的向量
  predVec = vector("numeric")
  # 对emdList中的nPredict个emd分解结果列表中的imf和residue进行处理
  for(i in 1:nPredict) {
    # 存放第i个预测值
    sum = 0
    # 拿出第i个emd结果
    item = emdList$emdList[[i]]
    # 对item中的所有imf分量和residue分量进行PSO-RBF模型并预测结果
    nimf = item$nimf
    for(j in 1:nimf) {
      print(paste("第", i, "/", nPredict, "个预测结果", " 第", j, "/", nimf, "个imf", sep = ""))
      # 取出第j个imf分量
      imf = item$imf[, j]
      # 对imf进行PSO-RBF建模并预测结果
      predValue = getImfPredResult(data = imf, nInput = nInput, nHidden = nHidden, nOutput = nOutput)
      # 累加
      sum = sum + predValue
    }
    print(paste("第", i, "/", nPredict, "个预测结果", " 预测residue", sep = ""))
    # 预测residue并累加
    sum = sum + getImfPredResult(item$residue, nInput = nInput, nHidden = nHidden, nOutput = nOutput)
    # 拼接预测结果向量
    predVec = c(predVec, sum)
  }
  # 整形
  testPredMat = matrix(predVec, ncol = 1)
  # 计算误差
  errorList = calError(testObsMat, testPredMat)
  
  # 绘图格式控制
  par(mfrow = c(1, 1), mar = c(4,4,4,4))
  
  # 绘制预测部分的实际值和预测值
  plot(testObsMat, type = "b", lwd = 2, pch = 16)
  lines(testPredMat, type = "b", lwd = 1, col = "blue", pch = 5)
  
  return(list(
    testPredMat = testPredMat,
    errorList = errorList
  ))
}