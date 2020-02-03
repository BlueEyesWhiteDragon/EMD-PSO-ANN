### 设定结构参数
nUse = 360
nPredict = 30

nInput = 3
nHidden = 4
nOutput = 1

maxInput = 7
maxHidden = 15

### 观察不同nInput和nHidden的情况
optRbfStructure(maxTemperatureByDay[1:(nrow(maxTemperatureByDay)-20)], nPredict, nOutput, nUse, maxInput, maxHidden)

### 使用自定义函数
infoPsoRbf_360_30_3_4_1 = getPsoRbfInfo(maxTemperatureByDay, nUse, nPredict, nInput, nOutput, nHidden)

infoPsoRbfAdvanced = getPsoRbfInfoAdvanced(data = maxTemperatureByDay, nTest = 30, nInput = 3, nOutput = 1, nHidden = 4, nOverlap = 5, lastOverlapControl = T, fnscale = 1, maxit = 200, reltol = 0.02, max.restart = 3, trace = 1, trace.stats = T, REPORT = 10)

View(infoPsoRbfAdvanced)


### 用于观察粒子上下界是否合适，比如出现边界值则考虑扩充边界
# abs((info$centersPSO - info$centers)) / abs(info$centers)
# abs((info$sigmasPSO - info$sigmas)) / abs(info$sigmas)
# abs((info$weightsPSO - info$weights)) / abs(info$weights)