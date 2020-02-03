### 给出无验证集型嵌套交叉验证的有关参数
### INPUT
# nSample 样本总数，也就是整形后的矩阵行数
# nTest 测试样本总数，也就是要预测的期数
# nOverlap 嵌套次数，或者说预测轮数，有可能过大，需要在函数中先求出允许的最大轮数maxOverlap
### OUTPUT
# maxOverlap 最大嵌套次数，即最大预测轮数
# trainStartRowNumVec 训练集样本起始行数向量
# trainEndRowNumVec 训练集样本结束行数向量
# testStartRowNumVec 测试集样本起始行数向量
# testEndRowNumVec 测试集样本结束行数向量
# 以上4个向量各包含的元素个数为：预测轮数
getOverlapParams <- function(nSample, nTest, nOverlap) {
  # 求出允许的最大预测轮数
  maxOverlap = floor(nSample / nTest) - 1
  
  # 预测轮数规范化
  nOverlap = min(nOverlap, maxOverlap)
  
  # 初始化各结果向量
  trainStartRowNumVec = vector("numeric", nOverlap)
  trainEndRowNumVec = trainStartRowNumVec
  testStartRowNumVec = trainStartRowNumVec
  testEndRowNumVec = trainStartRowNumVec
  
  # 首先确定的是testEndRowNumVec的最后一个元素，应该等于nSample，之前的元素依次递减nPredict
  testEndRowNumVec[nOverlap] = nSample
  if(nOverlap > 1) {
    for(i in seq((nOverlap - 1), 1, -1)) {
      testEndRowNumVec[i] = testEndRowNumVec[i+1] - nTest
    }
  }
  
  # 确定testStartRowNumVec
  testStartRowNumVec = testEndRowNumVec - (nTest - 1)
  
  # 确定trainEndRowNumVec
  trainEndRowNumVec = testEndRowNumVec - nTest
  
  # 确定trainStartRowNumVec
  trainStartRowNumVec = rep((testStartRowNumVec[1] - nTest), nOverlap)
  
  return(list(
    nOverlap = nOverlap,
    maxOverlap = maxOverlap,
    trainStartRowNumVec = trainStartRowNumVec,
    trainEndRowNumVec = trainEndRowNumVec,
    testStartRowNumVec = testStartRowNumVec,
    testEndRowNumVec = testEndRowNumVec
  ))
  
}