### 设置共同参数
nTest = 30
nOverlap = 5
nLastOverlap = 2

### 纯RBF网络 + 嵌套
infoRbfAdvanced_1 = getRbfInfoAdvanced(data = maxTemperatureByDay, nTest = nTest, nInput = 3, nOutput = 1, nHidden = 4, nOverlap = nOverlap, nLastOverlap = nLastOverlap)

### PSO-RBF网络 + 嵌套
infoPsoRbfAdvanced_1 = getPsoRbfInfoAdvanced(data = maxTemperatureByDay, nTest = nTest, nInput = 3, nHidden = 4, nOutput = 1, nOverlap = nOverlap, nLastOverlap = nLastOverlap, fnscale = 1, maxit = 150, reltol = 0.02, max.restart = 3, trace = 1, trace.stats = T, REPORT = 10)

### EMD-PSO-RBF网络 + 嵌套
infoEmdPsoRbfAdvanced_none_1 = getEmdPsoRbfInfoAdvanced(data = maxTemperatureByDay, nTest = nTest, nInput = 3, nHidden = 4, nOutput = 1, nOverlap = nOverlap, nLastOverlap = nLastOverlap, boundary = "none", max.imf = 10, fnscale = 1, maxit = 150, reltol = 0.02, max.restart = 3, trace = 1, trace.stats = T, REPORT = 10)

# infoEmdPsoRbfAdvanced_wave_1 = getEmdPsoRbfInfoAdvanced(data = maxTemperatureByDay, nTest = nTest, nInput = 3, nHidden = 4, nOutput = 1, nOverlap = nOverlap, lastOverlapControl = lastOverlapControl, boundary = "wave", max.imf = 10, fnscale = 1, maxit = 150, reltol = 0.02, max.restart = 3, trace = 1, trace.stats = T, REPORT = 10)

# infoEmdPsoRbfAdvanced_periodic_1 = getEmdPsoRbfInfoAdvanced(data = maxTemperatureByDay, nTest = nTest, nInput = 3, nHidden = 4, nOutput = 1, nOverlap = nOverlap, lastOverlapControl = lastOverlapControl, boundary = "periodic", max.imf = 10, fnscale = 1, maxit = 150, reltol = 0.02, max.restart = 3, trace = 1, trace.stats = T, REPORT = 10)

# infoEmdPsoRbfAdvanced_evenodd_1 = getEmdPsoRbfInfoAdvanced(data = maxTemperatureByDay, nTest = nTest, nInput = 3, nHidden = 4, nOutput = 1, nOverlap = nOverlap, lastOverlapControl = lastOverlapControl, boundary = "evenodd", max.imf = 10, fnscale = 1, maxit = 150, reltol = 0.02, max.restart = 3, trace = 1, trace.stats = T, REPORT = 10)

# infoEmdPsoRbfAdvanced_symmetric_1 = getEmdPsoRbfInfoAdvanced(data = maxTemperatureByDay, nTest = nTest, nInput = 3, nHidden = 4, nOutput = 1, nOverlap = nOverlap, lastOverlapControl = lastOverlapControl, boundary = "symmetric", max.imf = 10, fnscale = 1, maxit = 150, reltol = 0.02, max.restart = 3, trace = 1, trace.stats = T, REPORT = 10)

