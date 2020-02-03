### 设定训练集观测结果的个数、测试集观测结果的个数、输入向量维度、输出向量维度、隐层节点数
nUse = 360
nPredict = 30

nInput = 3
nHidden = 4
nOutput = 1

### 观察不同nInput和nHidden的情况
infoRbf_360_30_3_4_1 = getRbfInfo(maxTemperatureByDay, nUse, nPredict, nInput, nOutput, nHidden)
infoRbf_360_30_3_4_1$trainErrorList

infoRbfAdvanced = getRbfInfoAdvanced(data = maxTemperatureByDay, nTest = 30, nInput = 3, nOutput = 1, nHidden = 4, nOverlap = 100, lastOverlapControl = F)

View(infoRbfAdvanced)
