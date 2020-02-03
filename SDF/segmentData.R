### 用于划分原始数据集的函数
### INPUT
## originData 原始数据，此处为一个1维列向量
## nUse 训练集的数据个数，相当于用最后nPredict项之前的nUse项去训练网络
## nPredict 测试集的数据个数，也就是将原始数据最后nPredict项作为预测真实值，不参与模型的训练
## nInput 输入向量的维度，也就是输入层节点数
## nOutput 输出向量的维度，也就是输出层节点数
### OUTPUT
## $trainInputMat 训练输入矩阵，行数为训练样本数，列数为nInput
## $trainObsMat 训练观测结果矩阵，行数为训练样本数，列数为nOutput
## $testInputMat 测试输入矩阵，行数为测试样本数，列数为nInput
## $testObsMat 测试观测结果矩阵，行数为测试样本数，列数为nOutput
segmentData <- function(originData = NULL, nUse = 100, nPredict = 20, nInput = 3, nOutput = 1) {
  # 将原始数据整形为一个列向量（一维时间序列）
  originData = matrix(originData, ncol = 1)
  # 获取原始数据的项数
  nData = nrow(originData)
  # 训练集开始位置和结束位置，要考虑训练集第一项数据之前的nInput项
  indexTrainStart = nData - nPredict - nUse + 1 - nInput
  indexTrainEnd = nData - nPredict
  # 测试集开始位置和结束位置，要考虑测试集第1项数据之前的nInput项
  indexTestStart = nData - nPredict + 1 - nInput
  indexTestEnd = nData
  # 截取训练集和测试集
  trainData = as.matrix(originData[indexTrainStart:indexTrainEnd, ])
  testData = as.matrix(originData[indexTestStart:indexTestEnd, ])
  # 将训练集和测试集整形为左输入矩阵、右输出矩阵（一维列向量）的形式
  trainMat = reshapeData(data = trainData, nInput = nInput, nOutput = nOutput)
  testMat = reshapeData(data = testData, nInput = nInput, nOutput = nOutput)
  # 截取训练输入矩阵、训练观测结果矩阵、测试输入矩阵、测试观测结果矩阵
  trainInputMat = as.matrix(trainMat[, 1:nInput])
  trainObsMat = as.matrix(trainMat[, (nInput+1):(nInput+nOutput)])
  testInputMat = as.matrix(testMat[, 1:nInput])
  testObsMat = as.matrix(testMat[, (nInput+1):(nInput+nOutput)])
  # 返回列表
  return(list(trainInputMat = trainInputMat, trainObsMat = trainObsMat, testInputMat = testInputMat, testObsMat = testObsMat))
}