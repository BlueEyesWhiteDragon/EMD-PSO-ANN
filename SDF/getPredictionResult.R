### 求预测结果矩阵
### INPUT
## inputMat 输入矩阵，行数为样本数，列数为输入向量的长度
## centerMat 隐含层节点中心坐标矩阵，行数为隐含层节点数目，列数为输入向量的长度
## sigmaMat 隐含层节点RBF宽度矩阵，行数为隐含层节点数目，列数为1
## weightMat 隐含层到输出层的权重矩阵，行数为(隐含层节点数目+1)，1对应阈值权重，列数为1
## obsMat 观测结果矩阵，行数为样本数，列数为输出向量的长度
### OUTPUT
## $predMat 预测结果矩阵，行数为样本数，列数为输出向量的长度
getPredictionResult <- function(inputMat, centerMat, sigmaMat, weightMat) {
  # 隐层节点数
  nHidden = nrow(centerMat)
  # 求出phi矩阵
  phiMatrix = NULL
  for(i in 1:nrow(inputMat)) {
    xi = as.matrix(inputMat[i, ])
    tmpInput = t(matrix(rep(xi, nHidden), ncol = nHidden))
    tmpSigmas = matrix(rep(sigmaMat^2, nHidden), ncol = nHidden)
    phiMatrix = rbind(
      phiMatrix,
      diag(
        exp(
          -((tmpInput-centerMat) %*% t(tmpInput-centerMat)) / tmpSigmas
        )
      )
    )
  }
  phiMatrix = cbind(1, phiMatrix)
  colnames(phiMatrix) = NULL
  # 求出预测结果矩阵
  predMat = phiMatrix %*% weightMat
  
  return( predMat )
}