infoEmdPsoRbfAdvanced = getEmdPsoRbfInfoAdvanced(data = maxTemperatureByDay, nTest = 300, nInput = 3, nHidden = 4, nOutput = 1, nOverlap = 5, lastOverlapControl = T)

View(infoEmdPsoRbfAdvanced)

##################################
##################################
##################################

### 采用无验证集的嵌套交叉验证
### 先写脚本，再改成函数
### INPUT
# data 原始时间序列，一维列向量
# nTest 测试集长度
# nInput 输入层节点数
# nHidden 隐含层节点数
# nOutput 输出层节点数
# nOverlap 总预测轮数
# lastOverlapControl 布尔类型。默认为T，只进行最后一轮预测，相当于训练集长度为nOverlap乘以nTest的预测；为F时，进行最多nOverlap轮预测
### OUTPUT
# 看情况添加

### 要用到的自变量
# data = maxTemperatureByDay
# nTest = 300
# nInput = 3
# nHidden = 4
# nOutput = 1
# nOverlap = 5
# lastOverlapControl = F

# ### 整形为矩阵
# data = matrix(data, ncol = 1)
# 
# ### 求原始序列长度
# nData = nrow(data)
# 
# ### 求样本总数
# nSample = nData + 1 - nInput - nOutput
# 
# ### 求出允许的最大轮数
# maxOverlap = floor(nSample / nTest) - 1
# 
# ### 防止nOverlap太大，限制在合理范围内
# nOverlap = min(nOverlap, maxOverlap)
# 
# ### 返回结果中应该包括nOverlap个list，每个list包含各轮预测的相关信息；这nOverlap个list合成一个向量
# emdPsoRbfInfoList = vector("list", nOverlap)
# 
# ### 为了求各轮误差结果之和，需要初始化一些数值
# sumMAE = 0
# sumRMSE = 0
# sumMAPE = 0
# 
# ### 控制是否只需要最后一轮的预测结果
# startOverlap = ifelse(lastOverlapControl, nOverlap , 1)
# 
# ### 循环处理每一轮预测
# for(ithOverlap in startOverlap:nOverlap) {
#   ### 输出信息
#   print(paste("第", ithOverlap, "/", nOverlap, "轮预测", sep = ""))
#   
#   ### 获取第ithOverlap轮要进行emd分解的序列，在此之前先计算每轮预测emd分解序列的开始位置和结束位置，以及每轮预测的测试集起始位置和结束位置
#   emdStartIndex = nData - (nOverlap + 1)*nTest + 1
#   emdEndIndex = nData - (nOverlap + 1 - ithOverlap)*nTest
#   obsStartIndex = emdEndIndex + 1
#   obsEndIndex = emdEndIndex + nTest
#   
#   ### 取出要进行EMD分解的序列，实际上要包括测试集序列
#   tmpData = as.matrix(data[emdStartIndex:obsEndIndex, ])
#   
#   ### 取出观测结果序列
#   obsMat = as.matrix(data[obsStartIndex:obsEndIndex, ])
#   
#   ### 先进行一次EMD分解，获得imf数量的最小值
#   emdListRaw = getEmdListAdvanced(data = tmpData, nTest = nTest, trainStartIndex = 1, trainEndIndex = ithOverlap*nTest, fix = T, plot = F, max.imf = 10, boundary = "none")
#   nImf.min = emdListRaw[["nImf.min"]]
#   
#   ### 再按照imf数量最小值进行EMD分解
#   emdList = getEmdListAdvanced(data = tmpData, nTest = nTest, trainStartIndex = 1, trainEndIndex = ithOverlap*nTest, fix = T, plot = F, max.imf = nImf.min, boundary = "none")
#   
#   ### 获得各阶imf的PSO-RBF参数
#   infoVec = getEachImfPsoRbfInfoVec(emdList = emdList)
#   
#   ### 获得预测结果和误差
#   tmpList = getEmdPsoRbfPredictionInfo(emdList = emdList, infoVec = infoVec, obsMat = obsMat)
#   
#   ### 累加
#   sumMAE = sumMAE + tmpList[["errorList"]][["MAE"]]
#   sumRMSE = sumRMSE + tmpList[["errorList"]][["RMSE"]]
#   sumMAPE = sumMAPE + tmpList[["errorList"]][["MAPE"]]
#   
#   ### 储存到结果列表向量中
#   emdPsoRbfInfoList[[ithOverlap]] = tmpList
# }
# 
# ### 将所需结果封装到列表当中
# infoEmdPsoRbfAdvanced = list(
#   emdPsoRbfInfoList = emdPsoRbfInfoList,
#   avgErrorList = list(
#     avgMAE = sumMAE / ifelse(lastOverlapControl, 1, nOverlap),
#     avgRMSE = sumRMSE / ifelse(lastOverlapControl, 1, nOverlap),
#     avgMAPE = sumMAPE / ifelse(lastOverlapControl, 1, nOverlap)
#   )
# )
# 
# View(infoEmdPsoRbfAdvanced)


