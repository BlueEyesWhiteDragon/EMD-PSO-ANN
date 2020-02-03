### 输入一个imf分量或者residue分量，输入RBF神经网络的结构参数nInput、nHidden、nOutput，自动构建PSO-RBF网络，返回下一期的预测值
### INPUT
## data
## nInput
## nHidden
## nOutput
### OUTPUT
## predValue
getImfPredResult <- function(data, nInput, nHidden, nOutput = 1) {
  # 整形
  data = matrix(data, ncol = 1)
  
  # 获取数据长度
  nData = nrow(data)
  
  # 划分原始数据集
  trainMat = reshapeData(data = data, nInput = nInput, nOutput = nOutput)
  trainInputMat <<- trainMat[, 1:nInput]
  trainObsMat <<- trainMat[, (nInput+1):(nInput+nOutput)]
  
  # 使用hclust对训练集输入聚类
  trainInputMat.hclust <- hclust(dist(trainInputMat))
  
  # 通过隐层节点数控制聚类结果
  lambda = setHeightByNType(trainInputMat.hclust, nHidden)
  
  # 标记每个样本的类别
  type = cutree(trainInputMat.hclust, h = lambda)
  
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
  psoResult <- psoptim(par = paramsVec, fn = fitnessPSO, lower = paramsLowerVec, upper = paramsUpperVec, control = list(fnscale = 1, maxit = 150, reltol = 0.01, max.restart = 3, p = 1, trace = 1, trace.stats = TRUE, REPORT = 10))
  
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
  
  # 求以最后nInput项为输入的预测值
  lastInput = matrix(data[(nData-nInput+1):nData, ], ncol = nInput)
  predMat = getPredictionResult(lastInput, centersOptMat, sigmasOptMat, weightsOptMat)
  predValue = predMat[1,1]
  
  return(predValue)
  
}