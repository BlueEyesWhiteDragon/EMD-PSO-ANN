### 获取getEmdListAdvanced结果中的每一个emd分解结果的各分量的PSO-RBF网络参数
### INPUT
# emdList getEmdListAdvanced(·)的结果
# fnscale 默认1。取-1时可以将最小化问题转变成最大化问题
# maxit 默认150。最大迭代次数
# reltol 默认0.02。当粒子最大间距小于搜索空间线度×reltol时，重新开始搜索。
# max.restart 默认3。最大搜索轮数，默认最多搜索3轮：start → 搜索 → restart → 搜索 → restart → 搜索 → restart → 终止
# trace 默认1。记录PSO粒子状态的步长。
# trace.stats 默认T。控制是否记录每次迭代后粒子的信息。
# REPORT 默认10。每记录10次打印一次信息。
### OUTPUT
# 每个分解结果各分量的PSO-RBF网络参数，封装进一个list，返回一个包含nTest个list的向量
getEachImfPsoRbfInfoList <- function(emdList, fnscale = 1, maxit = 150, reltol = 0.02, max.restart = 3, trace = 1, trace.stats = T, REPORT = 10) {
  ### 获取nTest
  nTest = length(emdList[["emdList"]])
  
  ### 结果向量初始化
  infoList = vector("list", nTest)
  
  ### 对每一个EMD分解结果进行处理
  for(k in 1:nTest) {
    ### 保存emdList中的各参数
    imf = emdList[["emdList"]][[k]][["imf"]]
    residue = emdList[["emdList"]][[k]][["residue"]]
    nimf = emdList[["emdList"]][[k]][["nimf"]]
    
    ### 初始化
    infoList[[k]] = vector("list", nimf)
    
    ### 对各阶imf进行处理，建立PSO-RBF模型，将优化后的参数存入一个list，将该list存入结果向量
    for(i in 1:nimf) {
      ### 打印信息
      print(paste("第", k, "/", nTest, "个预测 第", i, "/", (nimf + 1), "个分量", sep = ""))
      ### 处理imf分量
      infoList[[k]][[i]] = getEachImfPsoRbfInfo(imf[, i], fnscale = fnscale, maxit = maxit, reltol = reltol, max.restart = max.restart, trace = trace, trace.stats = trace.stats, REPORT = REPORT)
    }
    ### 打印信息
    print(paste("第", k, "/", nTest, "个预测 第", (nimf + 1), "/", (nimf + 1), "个分量···", sep = ""))
    ### 处理residue分量
    infoList[[k]][[nimf+1]] = getEachImfPsoRbfInfo(residue, fnscale = fnscale, maxit = maxit, reltol = reltol, max.restart = max.restart, trace = trace, trace.stats = trace.stats, REPORT = REPORT)
  }
  
  return(infoList)
}



### 测试
# infoList_TEST = getEachImfPsoRbfInfoList(emdList_TEST)