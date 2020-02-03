### 采用无验证集的嵌套交叉验证改进训练一次的getRbfInfo函数，相比之下，nUse参数不再需要，增加了nOverlap，和ithOverlap。
### INPUT
# data 原始时间序列，一个一维列向量
# nTest 测试集长度
# nInput 输入向量维度（输入层节点数）
# nOutput 输出向量维度（输出层节点数）
# nHidden 隐含层节点数
# nOverlap 总预测轮数
# nLastOverlap 默认为1。在nOverlap轮预测中取后nLastOverlap轮预测。
# fnscale 默认1。取-1时可以将最小化问题转变成最大化问题
# maxit 默认150。最大迭代次数
# reltol 默认0.02。当粒子最大间距小于搜索空间线度×reltol时，重新开始搜索。
# max.restart 默认3。最大搜索轮数，默认最多搜索3轮：start → 搜索 → restart → 搜索 → restart → 搜索 → restart → 终止
# trace 默认1。记录PSO粒子状态的步长。
# trace.stats 默认T。控制是否记录每次迭代后粒子的信息。
# REPORT 默认10。每记录10次打印一次信息。
### OUTPUT
# 看情况添加
getPsoRbfInfoAdvanced <- function(data, nTest, nInput, nOutput, nHidden, nOverlap, nLastOverlap = 1, fnscale = 1, maxit = 150, reltol = 0.02, max.restart = 3, trace = 1, trace.stats = T, REPORT = 10) {
  # 整形为向量
  data = as.vector(data)
  
  # 原始序列长度
  nData = length(data)
  
  # 求样本总数
  nSample = nData + 1 - nInput - nOutput
  
  # 求出允许的最大预测轮数
  maxOverlap = floor(nSample / nTest) - 1
  
  # 规范化输入的nOverlap
  nOverlap = min(nOverlap, maxOverlap)
  
  # 返回结果中应该包括nOverlap个list，每个list包含各轮预测的相关信息；这nOverlap个list合成一个向量
  psoRbfInfoList = vector("list", nOverlap)
  
  # 各轮误差结果之和
  sumTrainMAE = 0
  sumTrainRMSE = 0
  sumTrainMAPE = 0
  sumTestMAE = 0
  sumTestRMSE = 0
  sumTestMAPE = 0
  
  sumTrainMAEPso = 0
  sumTrainRMSEPso = 0
  sumTrainMAPEPso = 0
  sumTestMAEPso = 0
  sumTestRMSEPso = 0
  sumTestMAPEPso = 0
  
  ### fitnessPSO函数需要一些全局变量
  nInput <<- nInput
  nHidden <<- nHidden
  nOutput <<- nOutput
  
  # 控制是否只需要最后一轮的预测结果
  startOverlap = nOverlap - nLastOverlap + 1
  
  # 循环处理每一轮预测
  for(ithOverlap in startOverlap:nOverlap) {
    # 输出信息
    print(paste("第", ithOverlap, "/", nOverlap, "轮预测", sep = ""))
    
    # 获取训练/测试的输入阵和观测阵
    ithOverlapList = getIthOverlapMat(data = data, nTest = nTest, nInput = nInput, nOutput = nOutput, nOverlap = nOverlap, ithOverlap = ithOverlap)
    trainInputMat <<- ithOverlapList$trainInputMat
    trainObsMat <<- ithOverlapList$trainObsMat
    testInputMat = ithOverlapList$testInputMat
    testObsMat = ithOverlapList$testObsMat
    
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
    
    # 求PSO优化前测试误差列表（预测误差）
    testPredMat = getPredictionResult(testInputMat, centers, sigmas, W) # 测试集预测结果矩阵
    testErrorList = calError(testObsMat, testPredMat)
    
    # 将centers矩阵、sigmas矩阵和W矩阵转化为向量并拼接
    centersVec = as.vector(centers)
    sigmasVec = as.vector(sigmas)
    weightsVec = as.vector(W)
    paramsVec = c(centersVec, sigmasVec, weightsVec)
    
    # 设定参数向量的上界和下界
    centersLowerVec = rep(-25, length(centersVec)) # 西安历史最低温度为-20.6℃
    centersUpperVec = rep(45, length(centersVec)) # 西安历史最高温度为42.9℃
    sigmasLowerVec = rep(0, length(sigmasVec))
    sigmasUpperVec = sigmasVec + 3*abs(sigmasVec)
    weightsLowerVec = weightsVec - 3*abs(weightsVec)
    weightsUpperVec = weightsVec + 3*abs(weightsVec)
    paramsLowerVec = c(centersLowerVec, sigmasLowerVec, weightsLowerVec)
    paramsUpperVec = c(centersUpperVec, sigmasUpperVec, weightsUpperVec)
    
    # PSO参数优化
    psoResult <- psoptim(par = paramsVec, fn = fitnessPSO, lower = paramsLowerVec, upper = paramsUpperVec, control = list(fnscale = fnscale, maxit = maxit, reltol = reltol, max.restart = max.restart, p = 1, trace = trace, trace.stats = trace.stats, REPORT = REPORT))
    
    # 将PSO获取到的最优参数向量转为矩阵
    paramsVecPso = psoResult$par
    centersVecPso = paramsVecPso[1:(nHidden*nInput)]
    sigmasVecPso = paramsVecPso[(nHidden*nInput+1):(nHidden*nInput+nHidden)]
    weightsVecPso = paramsVecPso[(nHidden*nInput+nHidden+1):length(paramsVecPso)]
    
    centersMatPso = matrix(centersVecPso, ncol = nInput)
    sigmasMatPso = matrix(sigmasVecPso, ncol = 1)
    weightsMatPso = matrix(weightsVecPso, ncol = 1)
    
    # 求PSO优化后训练误差列表（拟合误差）
    trainPredMatPso = getPredictionResult(trainInputMat, centersMatPso, sigmasMatPso, weightsMatPso)
    trainErrorListPso = calError(trainObsMat, trainPredMatPso)
    
    # 求PSO优化后测试误差列表（预测误差）
    testPredMatPso = getPredictionResult(testInputMat, centersMatPso, sigmasMatPso, weightsMatPso)
    testErrorListPso = calError(testObsMat, testPredMatPso)
    
    # 临时列表，用于包装本轮预测的相应结果
    tmpList = list(
      centers = centers,
      centersPso = centersMatPso,
      sigmas = sigmas,
      sigmasPso = sigmasMatPso,
      weights = W,
      weightsPso = weightsMatPso,
      trainPredMat = trainPredMat,
      trainPredMatPso = trainPredMatPso,
      testPredMat = testPredMat,
      testPredMatPso = testPredMatPso,
      trainErrorList = trainErrorList,
      trainErrorListPso = trainErrorListPso,
      testErrorList = testErrorList,
      testErrorListPso = testErrorListPso,
      psoResult = psoResult
    )
    
    # 将临时列表装入psoRbfInfoList
    psoRbfInfoList[[ithOverlap]] = tmpList
    
    # 误差求和
    sumTrainMAE = sumTrainMAE + trainErrorList$MAE
    sumTrainRMSE = sumTrainRMSE + trainErrorList$RMSE
    sumTrainMAPE = sumTrainMAPE + trainErrorList$MAPE
    
    sumTestMAE = sumTestMAE + testErrorList$MAE
    sumTestRMSE = sumTestRMSE + testErrorList$RMSE
    sumTestMAPE = sumTestMAPE + testErrorList$MAPE
    
    sumTrainMAEPso = sumTrainMAEPso + trainErrorListPso$MAE
    sumTrainRMSEPso = sumTrainRMSEPso + trainErrorListPso$RMSE
    sumTrainMAPEPso = sumTrainMAPEPso + trainErrorListPso$MAPE
    
    sumTestMAEPso = sumTestMAEPso + testErrorListPso$MAE
    sumTestRMSEPso = sumTestRMSEPso + testErrorListPso$RMSE
    sumTestMAPEPso = sumTestMAPEPso + testErrorListPso$MAPE
  } # 第ithOverlap轮预测结束
  
  # 求平均误差并装入列表
  avgTrainErrorList = list(
    MAE = (sumTrainMAE / nLastOverlap),
    RMSE = (sumTrainRMSE / nLastOverlap),
    MAPE = (sumTrainMAPE / nLastOverlap)
  )
  avgTestErrorList = list(
    MAE = (sumTestMAE / nLastOverlap),
    RMSE = (sumTestRMSE / nLastOverlap),
    MAPE = (sumTestMAPE / nLastOverlap)
  )
  avgTrainErrorListPso = list(
    MAE = (sumTrainMAEPso / nLastOverlap),
    RMSE = (sumTrainRMSEPso / nLastOverlap),
    MAPE = (sumTrainMAPEPso / nLastOverlap)
  )
  avgTestErrorListPso = list(
    MAE = (sumTestMAEPso / nLastOverlap),
    RMSE = (sumTestRMSEPso / nLastOverlap),
    MAPE = (sumTestMAPEPso / nLastOverlap)
  )
  
  # 返回结果
  return(list(
    psoRbfInfoList = psoRbfInfoList,
    avgTrainErrorList = avgTrainErrorList,
    avgTestErrorList = avgTestErrorList,
    avgTrainErrorListPso = avgTrainErrorListPso,
    avgTestErrorListPso = avgTestErrorListPso
  ))
}