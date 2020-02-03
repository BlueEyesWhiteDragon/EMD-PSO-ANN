### 采用无验证集的嵌套交叉验证
### INPUT
# data 原始时间序列，一维列向量
# nTest 测试集长度
# nInput 输入层节点数
# nHidden 隐含层节点数
# nOutput 输出层节点数
# nOverlap 总预测轮数
# nLastOverlap 默认1。进行后几轮预测，默认只进行最后一轮预测
# boundary 默认"none"。EMD分解的边界条件
# max.imf 默认10。最多保留几个imf
# fnscale 默认1。取-1时可以将最小化问题转变成最大化问题
# maxit 默认150。最大迭代次数
# reltol 默认0.02。当粒子最大间距小于搜索空间线度×reltol时，重新开始搜索。
# max.restart 默认3。最大搜索轮数，默认最多搜索3轮：start → 搜索 → restart → 搜索 → restart → 搜索 → restart → 终止
# trace 默认1。记录PSO粒子状态的步长。
# trace.stats 默认T。控制是否记录每次迭代后粒子的信息。
# REPORT 默认10。每记录10次打印一次信息。
### OUTPUT
# 看情况添加
getEmdPsoRbfInfoAdvanced <- function(
  data, 
  nTest = 30, 
  nInput = 3, 
  nHidden = 4, 
  nOutput = 1, 
  nOverlap = 5,
  nLastOverlap = 1,
  boundary = "none", 
  max.imf = 10, 
  fnscale = 1, 
  maxit = 150, 
  reltol = 0.02, 
  max.restart = 3, 
  trace = 1, 
  trace.stats = T, 
  REPORT = 10
  )
{
  ### 整形为矩阵
  data = matrix(data, ncol = 1)
  
  ### 求原始序列长度
  nData = nrow(data)
  
  ### 求样本总数
  nSample = nData + 1 - nInput - nOutput
  
  ### 求出允许的最大轮数
  maxOverlap = floor(nSample / nTest) - 1
  
  ### 防止nOverlap太大，限制在合理范围内
  nOverlap = min(nOverlap, maxOverlap)
  
  ### 返回结果中应该包括nOverlap个list，每个list包含各轮预测的相关信息；这nOverlap个list合成一个向量
  emdPsoRbfInfoList = vector("list", nOverlap)
  
  ### 为了求各轮误差结果之和，需要初始化一些数值
  sumMAE = 0
  sumRMSE = 0
  sumMAPE = 0
  
  ### 根据需要预测的总轮数计算起始轮数
  startOverlap = nOverlap - nLastOverlap + 1
  
  ### 循环处理每一轮预测
  for(ithOverlap in startOverlap:nOverlap) {
    ### 输出信息
    print(paste("第", ithOverlap, "/", nOverlap, "轮预测", sep = ""))
    
    ### 获取第ithOverlap轮要进行emd分解的序列，在此之前先计算每轮预测emd分解序列的开始位置和结束位置，以及每轮预测的测试集起始位置和结束位置
    emdStartIndex = nData - (nOverlap + 1)*nTest + 1
    emdEndIndex = nData - (nOverlap + 1 - ithOverlap)*nTest
    obsStartIndex = emdEndIndex + 1
    obsEndIndex = emdEndIndex + nTest
    
    ### 取出要进行EMD分解的序列，实际上要包括测试集序列
    tmpData = as.matrix(data[emdStartIndex:obsEndIndex, ])
    
    ### 取出观测结果序列
    obsMat = as.matrix(data[obsStartIndex:obsEndIndex, ])
    
    ### 先进行一次EMD分解，获得imf数量的最小值（这里其实已经作弊了，因为用到了测试集的数据）【因为减少计算量的计划失败了，所以每一步预测之前都需要进行建模，故没有必要对最大imf数量进行限制】
    # emdListRaw = getEmdListAdvanced(data = tmpData, nTest = nTest, trainStartIndex = 1, trainEndIndex = ithOverlap*nTest, fix = T, plot = F, max.imf = max.imf, boundary = boundary)
    # nImf.min = emdListRaw[["nImf.min"]]
    
    ### 进行EMD分解
    emdList = getEmdListAdvanced(data = tmpData, nTest = nTest, trainStartIndex = 1, trainEndIndex = ithOverlap*nTest, fix = T, plot = F, max.imf = max.imf, boundary = boundary)
    
    ### 获得各阶imf的PSO-RBF参数
    infoList = getEachImfPsoRbfInfoList(emdList = emdList, fnscale = fnscale, maxit = maxit, reltol = reltol, max.restart = max.restart, trace = trace, trace.stats = trace.stats, REPORT = REPORT)
    
    ### 获得预测结果和误差
    tmpList = getEmdPsoRbfPredictionInfo(emdList = emdList, infoList = infoList, obsMat = obsMat)
    
    ### 累加
    sumMAE = sumMAE + tmpList[["errorList"]][["MAE"]]
    sumRMSE = sumRMSE + tmpList[["errorList"]][["RMSE"]]
    sumMAPE = sumMAPE + tmpList[["errorList"]][["MAPE"]]
    
    ### 储存到结果列表向量中
    emdPsoRbfInfoList[[ithOverlap]] = tmpList
  }
  
  ### 将所需结果封装到列表当中
  return(list(
    emdPsoRbfInfoList = emdPsoRbfInfoList,
    avgErrorList = list(
      avgMAE = sumMAE / nLastOverlap,
      avgRMSE = sumRMSE / nLastOverlap,
      avgMAPE = sumMAPE / nLastOverlap
    )
  ))
}