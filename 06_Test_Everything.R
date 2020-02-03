### 纯RBF网络 + 嵌套
infoRbf_01 = getRbfInfoAdvanced(
  data = maxTemperatureByDay,
  nInput = 3,  
  nHidden = 4,
  nOutput = 1,  
  nTest = 30, 
  nOverlap = 5, 
  nLastOverlap = 3
)

infoRbf_02 = getRbfInfoAdvanced(
  data = maxTemperatureByDay,
  nInput = 3,  
  nHidden = 4,
  nOutput = 1,  
  nTest = 30, 
  nOverlap = 10, 
  nLastOverlap = 3
)

infoRbf_03 = getRbfInfoAdvanced(
  data = maxTemperatureByDay,
  nInput = 3,  
  nHidden = 4,
  nOutput = 1,  
  nTest = 30, 
  nOverlap = 15, 
  nLastOverlap = 3
)

### PSO-RBF网络 + 嵌套
infoPsoRbf_01 = getPsoRbfInfoAdvanced(
  data = maxTemperatureByDay,
  nInput = 3, 
  nHidden = 4, 
  nOutput = 1,  
  nTest = 30, 
  nOverlap = 5, 
  nLastOverlap = 3, 
  fnscale = 1,
  maxit = 150,
  reltol = 0.02, 
  max.restart = 3, 
  trace = 1,
  trace.stats = T,
  REPORT = 10
)

infoPsoRbf_02 = getPsoRbfInfoAdvanced(
  data = maxTemperatureByDay,
  nInput = 3, 
  nHidden = 4, 
  nOutput = 1,  
  nTest = 30, 
  nOverlap = 10, 
  nLastOverlap = 3, 
  fnscale = 1,
  maxit = 150,
  reltol = 0.02, 
  max.restart = 3, 
  trace = 1,
  trace.stats = T,
  REPORT = 10
)

infoPsoRbf_03 = getPsoRbfInfoAdvanced(
  data = maxTemperatureByDay,
  nInput = 3, 
  nHidden = 4, 
  nOutput = 1,  
  nTest = 30, 
  nOverlap = 15, 
  nLastOverlap = 3, 
  fnscale = 1,
  maxit = 150,
  reltol = 0.02, 
  max.restart = 3, 
  trace = 1,
  trace.stats = T,
  REPORT = 10
)

### EMD-PSO-RBF网络 + 嵌套
infoEmdPsoRbf_01 = getEmdPsoRbfInfoAdvanced(
  data = maxTemperatureByDay,
  nInput = 3, 
  nHidden = 4, 
  nOutput = 1, 
  nTest = 30, 
  nOverlap = 5, 
  nLastOverlap = 3, 
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