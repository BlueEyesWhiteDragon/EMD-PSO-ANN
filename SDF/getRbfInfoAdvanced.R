### 采用无验证集的嵌套交叉验证改进训练一次的getPsoRbfInfo函数，相比之下，nUse参数不再需要，增加了nOverlap，和ithOverlap
### INPUT
# data 原始时间序列，一个一维列向量
# nTest 测试集长度
# nInput 输入向量维度（输入层节点数）
# nOutput 输出向量维度（输出层节点数）
# nHidden 隐含层节点数
# nOverlap 总预测轮数
# plot 布尔类型。默认为F，不画任何图；T，画聚类图和预测结果图。
# nLastOverlap 默认为1。进行nOverlap中的后nLastOverlap轮预测
### OUTPUT
# 看情况添加
getRbfInfoAdvanced <- function(data, nTest = 30, nInput = 3, nHidden = 4, nOutput = 1, nOverlap = 5, plot = F, nLastOverlap = 1) {
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
  rbfInfoList = vector("list", nOverlap)
  
  # 合计误差结果
  sumTrainMAE = 0
  sumTrainRMSE = 0
  sumTrainMAPE = 0
  sumTestMAE = 0
  sumTestRMSE = 0
  sumTestMAPE = 0
  sumFitnessValue = 0
  
  # 确定起始轮数
  startOverlap = nOverlap - nLastOverlap + 1
  
  # 循环处理每一轮预测
  for(ithOverlap in startOverlap:nOverlap) {
    print(paste("第", ithOverlap, "/", nOverlap, "轮预测", sep = ""))
    # 获取训练/测试的输入阵和观测阵
    ithOverlapList = getIthOverlapMat(data = data, nTest = nTest, nInput = nInput, nOutput = nOutput, nOverlap = nOverlap, ithOverlap = ithOverlap)
    trainInputMat = ithOverlapList$trainInputMat
    trainObsMat = ithOverlapList$trainObsMat
    testInputMat = ithOverlapList$testInputMat
    testObsMat = ithOverlapList$testObsMat
    
    # 使用hclust对训练集输入聚类
    trainInputMat.hclust <- hclust(dist(trainInputMat))
    
    # 通过隐层节点数控制聚类结果
    lambda = setHeightByNType(trainInputMat.hclust, nHidden)
    
    # 标记每个样本的类别
    type = cutree(trainInputMat.hclust, h = lambda)
    
    ### 控制是否绘图
    if(plot) {
      # 绘制聚类图
      par(mfrow = c(1, 1), mar = c(1.5, 3, 1, 1), mgp = c(1.5,0.5,0))
      plot(trainInputMat.hclust, main = NULL, ylab = "距离")
      # 画出红色方框以便观察
      rect.hclust(trainInputMat.hclust, h = lambda)
      mtext("输入向量", side=1, line=0.2, adj=0.5)
    }
    
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
    
    # 求训练误差列表（拟合误差）
    trainPredMat = getPredictionResult(trainInputMat, centers, sigmas, W)
    trainErrorList = calError(trainObsMat, trainPredMat)
    
    # 求适应度（拟合优度）
    fitnessValue = fitness(trainObsMat, trainPredMat) 
    
    # 求测试误差列表（预测误差）
    testPredMat = getPredictionResult(testInputMat, centers, sigmas, W)
    testErrorList = calError(testObsMat, testPredMat)
    
    ### 控制是否绘图
    if(plot) {
      # 绘图格式控制
      par(mfrow = c(1, 1))
      
      # 绘制测试集的实际值和预测值
      plot(testObsMat, type = "b", lwd = 2, pch = 16)
      lines(testPredMat, type = "b", lwd = 1, col = "red", pch = 1)
    }
    
    # 临时列表，用于包装本轮预测的相应结果
    tmpList = list(
      centers = centers,
      sigmas = sigmas, 
      weights = W,
      trainPredMat = trainPredMat,
      testPredMat = testPredMat,
      trainErrorList = trainErrorList,
      testErrorList = testErrorList,
      fitnessValue = fitnessValue
    )
    
    # 将临时列表封进rbfInfoList
    rbfInfoList[[ithOverlap]] = tmpList
    
    # 误差求和
    sumFitnessValue = sumFitnessValue + fitnessValue
    # MAE
    sumTrainMAE = sumTrainMAE + trainErrorList$MAE
    sumTestMAE = sumTestMAE + testErrorList$MAE
    # RMSE
    sumTrainRMSE = sumTrainRMSE + trainErrorList$RMSE
    sumTestRMSE = sumTestRMSE + testErrorList$RMSE
    # MAPE
    sumTrainMAPE = sumTrainMAPE + trainErrorList$MAPE
    sumTestMAPE = sumTestMAPE + testErrorList$MAPE
  }
  
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
  
  # 返回结果
  return(list(
    rbfInfoList = rbfInfoList,
    avgTrainErrorList = avgTrainErrorList,
    avgTestErrorList = avgTestErrorList
  ))
}