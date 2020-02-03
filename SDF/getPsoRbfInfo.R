### 给定结构参数，自动划分数据集，并得到预测误差
### INPUT
## data 原始时间序列，一个一维列向量
## nUse 训练集观测结果个数
## nPredict 测试集观测结果个数
## nInput 输入向量维度（输入层节点数）
## nOutput 输出向量维度（输出层节点数）
## nHidden 隐含层节点数
### OUTPUT
## $predMat
## $errorList
getPsoRbfInfo <- function(data, nUse, nPredict, nInput, nOutput, nHidden) {
  # 划分原始数据集
  segmentList = segmentData(data, nUse, nPredict, nInput, nOutput)
  trainInputMat <<- segmentList$trainInputMat
  trainObsMat <<- segmentList$trainObsMat
  testInputMat = segmentList$testInputMat
  testObsMat = segmentList$testObsMat
  
  # 使用hclust对训练集输入聚类
  trainInputMat.hclust <- hclust(dist(trainInputMat))
  
  # 通过隐层节点数控制聚类结果
  lambda = setHeightByNType(trainInputMat.hclust, nHidden)
  
  # 标记每个样本的类别
  type = cutree(trainInputMat.hclust, h = lambda)
  
  # 绘制聚类图
  # plot(trainInputMat.hclust)
  # 画出红色方框以便观察
  # rect.hclust(trainInputMat.hclust, h = lambda)
  
  # 求各隐层神经元的中心
  centers = aggregate(trainInputMat, by = list(type), FUN = mean)
  # 去掉第一列
  centers$Group.1 = NULL
  centers = as.matrix(centers)
  
  # 求各隐层神经元的RBF宽度
  alpha = 1
  dst = as.matrix(dist(centers))
  dst[dst == 0] = max(dst)
  sigmas = as.matrix(alpha*apply(dst, 1, min))
  
  # 构建隐层神经元，得到phi矩阵
  phiMatrix=NULL
  for(i in 1:nrow(trainInputMat)) {
    xi = as.matrix(trainInputMat[i, ])
    tmpInput = t(matrix(rep(xi, nHidden), ncol = nHidden))
    tmpSigmas = matrix(rep(sigmas^2, nHidden), ncol = nHidden)
    phiMatrix = rbind(
      phiMatrix,
      diag(
        exp(
          -((tmpInput-centers) %*% t(tmpInput-centers)) / tmpSigmas
        )
      )
    )
  }
  phiMatrix = cbind(1, phiMatrix)
  colnames(phiMatrix) = NULL
  
  # 求权向量W
  W = (solve(t(phiMatrix) %*% phiMatrix) %*% t(phiMatrix)) %*% trainObsMat
  
  # 求PSO优化前训练误差列表（拟合误差）
  trainPredMat = getPredictionResult(trainInputMat, centers, sigmas, W)  # 训练集拟合结果矩阵
  trainErrorList = calError(trainObsMat, trainPredMat)
  
  # 求PSO优化前测试误差列表（预测误差）
  testPredMat = getPredictionResult(testInputMat, centers, sigmas, W) # 测试集拟合结果矩阵
  testErrorList = calError(testObsMat, testPredMat)
  
  # 将centers矩阵、sigmas矩阵和W矩阵转化为向量并拼接
  centersVec = as.vector(centers)
  sigmasVec = as.vector(sigmas)
  weightsVec = as.vector(W)
  paramsVec = c(centersVec, sigmasVec, weightsVec)
  
  # 设定参数向量的上界和下界
  centersLowerVec = centersVec - 3*abs(centersVec)
  centersUpperVec = centersVec + 3*abs(centersVec)
  sigmasLowerVec = rep(0, length(sigmasVec))
  sigmasUpperVec = sigmasVec + 3*abs(sigmasVec)
  weightsLowerVec = weightsVec - 3*abs(weightsVec)
  weightsUpperVec = weightsVec + 3*abs(weightsVec)
  paramsLowerVec = c(centersLowerVec, sigmasLowerVec, weightsLowerVec)
  paramsUpperVec = c(centersUpperVec, sigmasUpperVec, weightsUpperVec)
  
  # PSO参数优化
  psoResult <- psoptim(par = paramsVec, fn = fitnessPSO, lower = paramsLowerVec, upper = paramsUpperVec, control = list(fnscale = 1, maxit = 150, reltol = 0.025, max.restart = 3, p = 1, trace = 1, trace.stats = TRUE, REPORT = 5))
  # psoResult <- psoptim(par = paramsVec, fn = fitnessPSO, lower = paramsLowerVec, upper = paramsUpperVec, control = list(fnscale = 1, maxit = 150, p = 1, trace = 1, trace.stats = TRUE, REPORT = 10))
  
  # 将PSO获取到的最优参数向量转为矩阵
  paramsOptVec = psoResult$par
  centersOptVec = paramsOptVec[1:(nHidden*nInput)]
  sigmasOptVec = paramsOptVec[(nHidden*nInput+1):(nHidden*nInput+nHidden)]
  weightsOptVec = paramsOptVec[(nHidden*nInput+nHidden+1):length(paramsOptVec)]
  
  centersOptMat = matrix(centersOptVec, ncol = nInput)
  sigmasOptMat = matrix(sigmasOptVec, ncol = 1)
  weightsOptMat = matrix(weightsOptVec, ncol = 1)
  
  # 求PSO优化后训练误差列表（拟合误差）
  trainPredOptMat = getPredictionResult(trainInputMat, centersOptMat, sigmasOptMat, weightsOptMat)
  trainErrorOptList = calError(trainObsMat, trainPredOptMat)
  
  # 求PSO优化后测试误差列表（预测误差）
  testPredOptMat = getPredictionResult(testInputMat, centersOptMat, sigmasOptMat, weightsOptMat)
  testErrorOptList = calError(testObsMat, testPredOptMat)
  
  # 绘图格式控制
  # par(mfrow = c(1, 1), mar = c(4,4,4,4))
  
  # 绘制nUse部分的实际值和拟合值
  # plot(trainObsMat, type = "l", lwd = 2)
  # lines(trainPredMat, type = "l", lwd = 2, lty = 2, col = "red")
  # lines(trainPredOptMat, type = "l", lwd = 2, lty = 2, col = "blue")
  
  # 绘制nPredict部分的实际值和预测值
  # plot(testObsMat, type = "b", lwd = 2, pch = 16)
  # lines(testPredMat, type = "b", lwd = 1, col = "red", pch = 1)
  # lines(testPredOptMat, type = "b", lwd = 1, col = "blue", pch = 5)

  # 初始化绘图格式控制
  # par(mfrow = c(1, 1), mar = c(4,4,4,4))
    
  return(
    list(
      centers = centers, 
      centersPSO = centersOptMat, 
      sigmas = sigmas, 
      sigmasPSO = sigmasOptMat, 
      weights = W, 
      weightsPSO = weightsOptMat, 
      trainPredMat = trainPredMat, 
      trainPredMatPSO = trainPredOptMat, 
      testPredMat = testPredMat, 
      testPredMatPSO = testPredOptMat, 
      trainErrorList = trainErrorList, 
      trainErrorListPSO = trainErrorOptList, 
      testErrorList = testErrorList, 
      testErrorListPSO = testErrorOptList,
      psoResult = psoResult
    )
  )
}