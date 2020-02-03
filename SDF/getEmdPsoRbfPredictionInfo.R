### 根据getEmdListAdvanced(·)的结果、getEachImfPsoRbfinfoList(·)的结果、观测结果矩阵，求出预测结果矩阵
### INPUT
# emdList getEmdListAdvanced(·)的结果
# infoList getEachImfPsoRbfinfoList(·)的结果
# obsMat 观测结果矩阵，此处为一个一维列向量
### OUTPUT
# 看情况添加
getEmdPsoRbfPredictionInfo <- function(emdList, infoList, obsMat) {
  ### 获得测试序列长度
  nTest = length(emdList[["emdList"]])
  
  ### 存放结果向量
  predVec = vector("numeric", nTest)
  
  ### 对emdList和infoList进行遍历，每遍历一次求出一个预测值
  for(i in 1:nTest) {
    ### 取出第i个EMD分解结果的nimf
    nimf = emdList[["emdList"]][[i]][["nimf"]]
    
    ### 取出第i个EMD分解结果的imf
    imf = emdList[["emdList"]][[i]][["imf"]]
    
    ### 取出第i个EMD分解结果的residue
    residue = emdList[["emdList"]][[i]][["residue"]]
    
    ### 存放各imf累加和
    sum = 0
    
    ### 遍历tmpEmdlist和infoList，取出各imf（和residue）最后nInput项作为输入，取出对应的PSO-RBF网络参数，预测下一期的值，并累加求和重构原序列预测值
    for(j in 1:nimf) {
      ### 获得第j个imf的nInput、nHidden和nOutput
      nInput = ncol(infoList[[i]][[j]][["centers"]])
      nHidden = nrow(infoList[[i]][[j]][["centers"]])
      nOutput = ncol(infoList[[i]][[j]][["weights"]])
      
      ### 取出第j个imf
      tmpImf = imf[, j]
      
      ### 获得imf的长度
      tmpLen = nrow(emdList[["emdList"]][[i]][["imf"]])
      
      ### 取出第j个imf的后nInput项作为输入
      tmpInput = matrix(tmpImf[(tmpLen-nInput+1):tmpLen], nrow = 1)
      
      ### 取出PSO-RBF参数
      tmpCenters = infoList[[i]][[j]][["centersPso"]]
      tmpSigmas = infoList[[i]][[j]][["sigmasPso"]]
      tmpWeights = infoList[[i]][[j]][["weightsPso"]]
      
      ### 计算预测值
      tmpPredValue = getPredictionResult(inputMat = tmpInput, centerMat = tmpCenters, sigmaMat = tmpSigmas, weightMat = tmpWeights)
      
      ### 累加求和
      sum = sum + tmpPredValue[1]
    }
    
    ### 取出residue的后nInput项作为输入
    tmpInput = matrix(residue[(tmpLen-nInput+1):tmpLen], nrow = 1)
    
    ### 取出PSO-RBF参数
    tmpCenters = infoList[[i]][[nimf+1]][["centersPso"]]
    tmpSigmas = infoList[[i]][[nimf+1]][["sigmasPso"]]
    tmpWeights = infoList[[i]][[nimf+1]][["weightsPso"]]
    
    ### 计算residue预测值
    tmpPredValue = getPredictionResult(inputMat = tmpInput, centerMat = tmpCenters, sigmaMat = tmpSigmas, weightMat = tmpWeights)
    
    ### 累加求和
    sum = sum + tmpPredValue[1]
    
    ### 更新结果向量
    predVec[i] = sum
  }
  
  ### 计算误差向量
  errorList = calError(obsMat, predVec)
  
  ### 打印运行信息
  print("计算已完成")
  
  
  ### 返回结果矩阵和误差列表
  return(list(
    obsMat = matrix(obsMat, ncol = 1),
    predMat = matrix(predVec, ncol = 1),
    errorList = errorList
  ))
}

### 测试
# emdList_TEST <- getEmdListAdvanced(data = maxTemperatureByDay, nTest = 3, trainStartIndex = 2901, trainEndIndex = 3000, fix = T, plot = F, max.imf = 1, boundary = "none")

# infoList_TEST <- getEachImfPsoRbfInfoList(emdList_TEST)

# obsMat_TEST <- as.matrix(maxTemperatureByDay[3001:3003])

# predInfo_TEST <- getEmdPsoRbfPredictionInfo(emdList_TEST, infoList_TEST, obsMat_TEST)
