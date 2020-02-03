### 设定结构参数
nPredict = 30
nUse = 360

nInput = 3
nHidden = 4
nOutput = 1

### 执行EMD-PSO-RBF优化
infoEmdPsoRbf_360_30_3_4_1 = getEmdPsoRbfInfo(
  data = maxTemperatureByDay,
  nPredict = nPredict,
  nUse = nUse,
  nInput = nInput,
  nHidden = nHidden,
  nOutput = nOutput
)


infoEmdPsoRbf1_360_30_3_4_1 = getEmdPsoRbfInfo1(
  data = maxTemperatureByDay,
  nPredict = nPredict,
  nUse = nUse,
  nInput = nInput,
  nHidden = nHidden,
  nOutput = nOutput
)


infoEmdPsoRbf1A_360_30_3_4_1 = getEmdPsoRbfInfo1A(
  data = maxTemperatureByDay,
  nPredict = nPredict,
  nUse = nUse,
  nInput = nInput,
  nHidden = nHidden,
  nOutput = nOutput
)


infoEmdPsoRbf1B_360_30_3_4_1 = getEmdPsoRbfInfo1B(
  data = maxTemperatureByDay,
  nPredict = nPredict,
  nUse = nUse,
  nInput = nInput,
  nHidden = nHidden,
  nOutput = nOutput
)


infoEmdPsoRbf1C_360_30_3_4_1 = getEmdPsoRbfInfo1C(
  data = maxTemperatureByDay,
  nPredict = nPredict,
  nUse = nUse,
  nInput = nInput,
  nHidden = nHidden,
  nOutput = nOutput
)


infoEmdPsoRbf1D_360_30_3_4_1 = getEmdPsoRbfInfo1D(
  data = maxTemperatureByDay,
  nPredict = nPredict,
  nUse = nUse,
  nInput = nInput,
  nHidden = nHidden,
  nOutput = nOutput
)

