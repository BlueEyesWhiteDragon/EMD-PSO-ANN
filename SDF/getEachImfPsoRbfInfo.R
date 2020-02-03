### 该函数主要用于对emdList中的一个分量建立PSO-RBF模型，PSO优化的标准是拟合优度，所以没有测试集
### INPUT
# data 需要拟合的序列
# nInput 输入层节点数
# nHidden 隐含层节点数
# nOutput 输出层节点数
### OUTPUT
# 看情况添加
getEachImfPsoRbfInfo <- function(data, nInput = 3, nHidden = 4, nOutput = 1, fnscale = 1, maxit = 150, reltol = 0.02, max.restart = 3, trace = 1, trace.stats = T, REPORT = 10) {
  ### 将原始序列整形为左输入阵右输出阵的形式，并提取出来
  trainMat = reshapeData(data = data, nInput = nInput, nOutput = nOutput)
  trainInputMat <<- trainMat[, 1:nInput]
  trainObsMat <<- trainMat[, (nInput+1):(nInput+nOutput)]
  
  ### fitnessPSO需要一些全局变量
  nInput <<- nInput
  nHidden <<- nHidden
  nOutput <<- nOutput
  
  ### 使用hclust对训练集输入聚类
  trainInputMat.hclust <- hclust(dist(trainInputMat))
  
  ### 通过隐层节点数控制聚类结果
  lambda = setHeightByNType(trainInputMat.hclust, nHidden)
  
  ### 标记每个样本的类别
  type = cutree(trainInputMat.hclust, h = lambda)
  
  ### 求各隐层神经元的中心
  centers = aggregate(trainInputMat, by = list(type), FUN = mean)
  centers$Group.1 = NULL
  centers = as.matrix(centers)
  
  ### 求各隐层神经元的RBF宽度
  alpha = 1
  dst = as.matrix(dist(centers))
  dst[dst == 0] = max(dst)
  sigmas = as.matrix(alpha*apply(dst, 1, min))
  
  ### 构建隐层神经元，得到phi矩阵
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
  
  ### 求权向量W
  W = (solve(t(phiMatrix) %*% phiMatrix) %*% t(phiMatrix)) %*% trainObsMat
  
  ### 求PSO优化前训练误差列表（拟合误差）
  trainPredMat = getPredictionResult(trainInputMat, centers, sigmas, W)  # 训练集拟合结果矩阵
  trainErrorList = calError(trainObsMat, trainPredMat)
  
  ### 将centers矩阵、sigmas矩阵和W矩阵转化为向量并拼接
  centersVec = as.vector(centers)
  sigmasVec = as.vector(sigmas)
  weightsVec = as.vector(W)
  paramsVec = c(centersVec, sigmasVec, weightsVec)
  
  ### 设定参数向量的上界和下界
  centersLowerVec = rep(-25, length(centersVec)) # 西安历史最低温度为-20.6℃
  centersUpperVec = rep(45, length(centersVec)) # 西安历史最高温度为42.9℃
  sigmasLowerVec = rep(0, length(sigmasVec))
  sigmasUpperVec = sigmasVec + 3*abs(sigmasVec)
  weightsLowerVec = weightsVec - 3*abs(weightsVec)
  weightsUpperVec = weightsVec + 3*abs(weightsVec)
  paramsLowerVec = c(centersLowerVec, sigmasLowerVec, weightsLowerVec)
  paramsUpperVec = c(centersUpperVec, sigmasUpperVec, weightsUpperVec)
  
  ### PSO参数优化
  psoResult <- psoptim(par = paramsVec, fn = fitnessPSO, lower = paramsLowerVec, upper = paramsUpperVec, control = list(fnscale = fnscale, maxit = maxit, reltol = reltol, max.restart = max.restart, p = 1, trace = trace, trace.stats = trace.stats, REPORT = REPORT))
  
  ### 将PSO获取到的最优参数向量转为矩阵
  paramsVecPso = psoResult$par
  centersVecPso = paramsVecPso[1:(nHidden*nInput)]
  sigmasVecPso = paramsVecPso[(nHidden*nInput+1):(nHidden*nInput+nHidden)]
  weightsVecPso = paramsVecPso[(nHidden*nInput+nHidden+1):length(paramsVecPso)]
  
  centersMatPso = matrix(centersVecPso, ncol = nInput)
  sigmasMatPso = matrix(sigmasVecPso, nrow = nHidden)
  weightsMatPso = matrix(weightsVecPso, ncol = nOutput)
  
  ### 求PSO优化后训练误差列表（拟合误差）
  trainPredMatPso = getPredictionResult(trainInputMat, centersMatPso, sigmasMatPso, weightsMatPso)
  trainErrorListPso = calError(trainObsMat, trainPredMatPso)
  
  ### 装入list并返回
  return(list(
    centers = centers,
    centersPso = centersMatPso,
    sigmas = sigmas,
    sigmasPso = sigmasMatPso,
    weights = W,
    weightsPso = weightsMatPso,
    trainPredMat = trainPredMat,
    trainPredMatPso = trainPredMatPso,
    trainErrorList = trainErrorList,
    trainErrorListPso = trainErrorListPso,
    psoResult = psoResult
  ))
}


### 测试
# test = getEachImfPsoRbfInfo(test_100[["emdList"]][[1]][["imf"]][, 1])
