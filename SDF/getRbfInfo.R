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
getRbfInfo <- function(data, nUse, nPredict, nInput, nOutput, nHidden) {
  # 划分原始数据集
  segmentList = segmentData(data, nUse, nPredict, nInput, nOutput)
  trainInputMat = segmentList$trainInputMat
  trainObsMat = segmentList$trainObsMat
  testInputMat = segmentList$testInputMat
  testObsMat = segmentList$testObsMat
  
  # 尝试打乱训练输入集和训练结果集的顺序，观察结果是否有变：结论是结果不太一样，差异的原因是输入的顺序影响聚类结果，导致centers、sigmas和weights的估计值有所区别，但是正负号和大致的数据范围和之前是一致的。
  # randomIndexVec = sample(seq(1, nrow(trainInputMat)), nrow(trainInputMat))
  # trainInputMat = trainInputMat[randomIndexVec, ]
  # trainObsMat = trainObsMat[randomIndexVec, ]
  
  # 使用hclust对训练集输入聚类
  trainInputMat.hclust <- hclust(dist(trainInputMat))
  
  # 通过隐层节点数控制聚类结果
  lambda = setHeightByNType(trainInputMat.hclust, nHidden)
  
  # 标记每个样本的类别
  type = cutree(trainInputMat.hclust, h = lambda)
  
  # 绘制聚类图
  par(mfrow = c(1, 1), mar = c(1.5, 3, 1, 1), mgp = c(1.5,0.5,0))
  plot(trainInputMat.hclust, main = NULL, ylab = "距离")
  # 画出红色方框以便观察
  rect.hclust(trainInputMat.hclust, h = lambda)
  mtext("输入向量", side=1, line=0.2, adj=0.5)
  
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
  
  # 绘图格式控制
  # par(mfrow = c(2, 1))
  
  # 绘制nUse部分的实际值和拟合值
  # plot(trainObsMat, type = "l", lwd = 2)
  # lines(trainPredMat, type = "l", lwd = 2, lty = 2, col = "red")
  
  # 绘制nPredict部分的实际值和预测值
  # plot(testObsMat, type = "l", lwd = 2)
  # lines(testPredMat, type = "l", lwd = 2, lty = 2, col = "red")
  
  # 初始化绘图格式控制
  # par(mfrow = c(1, 1))
  
  return(
    list(
      centers = centers,
      sigmas = sigmas, 
      weights = W,
      trainPredMat = trainPredMat,
      testPredMat = testPredMat,
      trainErrorList = trainErrorList,
      testErrorList = testErrorList,
      fitnessValue = fitnessValue
    )
  )
}