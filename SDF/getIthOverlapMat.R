### 给定原始序列、测试集长度、输入个数、输出个数、预测总轮数、第i轮预测，输出第i轮预测的训练输入阵、训练观测阵、测试输入阵、测试输出阵
### INPUT
# data
# nTest
# nInput
# nOutput
# nOverlap
# ithOverlap
### OUTPUT
# trainInputMat
# trainObsMat
# testInputMat
# testObsMat
getIthOverlapMat <- function(data, nTest, nInput, nOutput, nOverlap, ithOverlap) {
  # 整形为矩阵
  data = reshapeData(data, nInput = nInput, nOutput = nOutput)
  
  # 求样本总数
  nSample = nrow(data)
  
  # 求嵌套交叉验证的相关参数
  overlapParams = getOverlapParams(nSample = nSample, nTest = nTest, nOverlap = nOverlap)
  
  # 规范化指定的预测轮数
  maxOverlap = overlapParams$nOverlap
  ithOverlap = min(ithOverlap, overlapParams$nOverlap)
  
  # 求出第i轮预测时的训练阵起止行号和测试阵起止行号
  trainStartRowNum = overlapParams$trainStartRowNumVec[ithOverlap]
  trainEndRowNum = overlapParams$trainEndRowNumVec[ithOverlap]
  testStartRowNum = overlapParams$testStartRowNumVec[ithOverlap]
  testEndRowNum = overlapParams$testEndRowNumVec[ithOverlap]
  
  # 取出第i轮预测的训练阵和测试阵
  trainMat = data[trainStartRowNum:trainEndRowNum, ]
  testMat = data[testStartRowNum:testEndRowNum, ]
  
  # 训练阵 = 训练输入阵 | 训练观测阵
  # 测试阵 = 测试输入阵 | 测试观测阵
  trainInputMat = as.matrix(trainMat[, 1:nInput])
  trainObsMat = as.matrix(trainMat[, (nInput+1):(nInput+nOutput)])
  testInputMat = as.matrix(testMat[, 1:nInput])
  testObsMat = as.matrix(testMat[, (nInput+1):(nInput+nOutput)])
  
  return(list(
    nSample = nSample,
    maxOverlap = maxOverlap,
    ithOverlap = ithOverlap,
    trainInputMat = trainInputMat,
    trainObsMat = trainObsMat,
    testInputMat = testInputMat,
    testObsMat = testObsMat
  ))
}

### 测试
# getIthOverlapMat(c(1,2,3,4,5,6,7,8,9,10,11,12,13), nTest = 3, nInput = 2, nOutput = 1, nOverlap = 3, ithOverlap = 3)
