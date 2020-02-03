### 给定nOutput（本研究中nOutput等于1）和nPredict（可变），划分数据并建立基本RBF网络预测模型，研究nInput、nHidden为多少时适应度较小
### INPUT
## nUse 训练集长度
## nOutput 输出层节点数，默认为1
## nPredict 测试集长度，默认为7
### OUTPUT
## nInput 输入层节点数
## nHidden 隐含层节点数
optRbfStructure <- function(data, nPredict = 7, nOutput = 1, nUse = 100, maxInput = 9, maxHidden = 27) {
  fitnessMin = Inf
  for(nInputTemp in seq(3, maxInput)) {
    for(nHiddenTemp in seq(nInputTemp + 1, min(maxHidden, 3*nInputTemp))) {
      tryCatch({
        info = getRbfInfo(data, nUse, nPredict, nInputTemp, nOutput, nHiddenTemp)
        print(paste(nInputTemp, nHiddenTemp, info$trainErrorList$RMSE, info$trainErrorList$MAPE, info$trainErrorList$MAE))
        if(info$fitnessValue < fitnessMin) {
          fitnessMin = info$fitnessValue
          nInput <<- nInputTemp
          nHidden <<- nHiddenTemp
        }
      }, warning = function(w) {
        print(w)
      }, error = function(e) {
        print(e)
      })
    }
  }
    
  return(list(
    nInput = nInput,
    nHidden = nHidden
  ))
}