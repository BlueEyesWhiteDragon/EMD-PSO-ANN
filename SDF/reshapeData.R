### 对一个一维时间序列列向量，假设前p个是输入向量，后q个是输出向量。将该时间序列整合为一个每行(p+q)个元素，逐项后移作为新一行的矩阵。比如1, 2, 3, 4, 5, 6整合为(1, 2, 3; 2, 3, 4; 3, 4, 5; 4, 5, 6)
reshapeData <- function(data = c(1,2,3,4,5), nInput = 3, nOutput = 1) {
  # 将一维数据整形为向量
  dataVec = as.vector(data)
  
  # 数据的个数
  nData <- length(dataVec)
  
  # 矩阵的行数
  rowNum <- nData + 1 - nInput - nOutput
  
  # 矩阵的列数
  colNum <- nInput + nOutput
  
  # 结果矩阵置空
  matrix <- matrix(NA, nrow = rowNum, ncol = colNum)
  
  # 循环改变矩阵的每一行
  for(i in 1:rowNum) {
    matrix[i, ] = dataVec[i:(nInput + nOutput + i - 1)]
  }
  
  return(matrix)
}