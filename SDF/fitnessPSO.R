### 为了配合pso包中的pso函数，需要一个新版本的适应度函数
### INPUT
## paramsVec 参数向量，实际上是as.vector(centers)拼接as.vector(sigmas)拼接as.vector(W)
fitnessPSO <- function(paramsVec) {
  # 将参数向量转化为centers矩阵、sigmas矩阵和W矩阵
  centersVec = paramsVec[1:(nHidden*nInput)]
  sigmasVec = paramsVec[(nHidden*nInput+1):(nHidden*nInput+nHidden)]
  weightsVec = paramsVec[(nHidden*nInput+nHidden+1):length(paramsVec)]
  
  centersMat = matrix(centersVec, ncol = nInput)
  sigmasMat = matrix(sigmasVec, nrow = nHidden)
  weightsMat = matrix(weightsVec, ncol = nOutput)
  
  # 调用函数求预测值
  predResult = getPredictionResult(inputMat = trainInputMat, centerMat = centersMat, sigmaMat = sigmasMat, weightMat = weightsMat)
  
  # 调用函数求适应度
  fitnessValue = fitness(trainObsMat, predResult)
  
  # 返回一个标量值
  return(fitnessValue)
}