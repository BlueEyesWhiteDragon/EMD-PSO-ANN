### 输入原始数据、测试集长度、训练集起始位置、训练集结束位置、最多保留的imf的个数、EMD分解的边界条件（默认测试集紧跟着训练集），输出窗口宽度逐渐加宽或者固定的EMD分解列表，包括nTest个EMD分解结果（然而实际上只有第一个需要保存完整的emd分解结果用于训练）。
### 另外需要注意的一点：为了保证只训练一次而非每步预测之前都要训练一次，每次分解获得的分量个数必须一致，目前采用的方法是先跑一次，记录各次EMD分解时imf数量最少为多少，然后再按照该最少数量再次进行EMD分解，以确保分解数量一致。
### INPUT
# data 原始序列
# nTest 测试集长度
# trainStartIndex 训练集起始位置
# trainEndIndex 训练集终止位置
# fix 布尔类型。默认F，EMD分解窗口的起点逐步后移，即窗口宽度固定为训练序列长度；为T时，EMD分解窗口的起点保持固定，即窗口宽度逐渐变宽
# plot 布尔类型。默认F，关闭emd绘图；为T时，开启emd绘图
# max.imf 控制分解到多少个imf就停止分解过程
# boundary EMD分解的边界条件
### Output
# 看情况添加
getEmdListAdvanced <- function(data, nTest, trainStartIndex, trainEndIndex, fix = T, plot = F, max.imf = 10, boundary = "none") {
  # 整形
  data = matrix(data, ncol = 1)
  # 存放结果列表
  emdList = vector("list", nTest)
  # 查看一共有多少个imf和residue分量
  nImf.sum = 0
  # 查看各次emd分解中的imf最少数量和最大数量
  nImf.max = 0
  nImf.min = Inf
  # 从trainStartIndex位置开始，直到trainEndIndex，窗口宽度固定向后平移，对窗口内的序列进行emd分解，共计进行nTest次emd分解
  for(count in 1:nTest) {
    # 打印信息
    print(paste("第", count, "/", nTest, "次EMD分解", sep = ""))
    
    # 根据fix控制EMD分解窗口的起点是否固定
    indexStart = trainStartIndex + count - 1
    indexEnd = trainEndIndex + count - 1
    if(fix) {
      indexStart = trainStartIndex
    }
    
    # 截取数据
    tmpData = data[indexStart:indexEnd, ]
    
    # 被分解序列的长度
    nUse = indexEnd - indexStart + 1
    
    # 对截取数据进行EMD分解
    tmpList = emd(xt = tmpData, tt = seq(1, nUse), boundary = boundary, max.imf = max.imf)
    
    # 保存imf数量
    nImf = tmpList$nimf
    
    # 累加imf数量（residue的数量为nTest，每进行1次EMD分解获得1个residue）
    nImf.sum = nImf.sum + nImf
    
    # 更新最大imf数量和最小imf数量
    nImf.max = ifelse((nImf.max < nImf), nImf, nImf.max)
    nImf.min = ifelse((nImf.min > nImf), nImf, nImf.min)
    
    # 更新结果列表
    emdList[[count]] = tmpList
    
    # 绘图
    if(plot) {
      # 绘图格式控制
      par(mfrow = c(nImf + 1, 1), mar = rep(0, 4))
      
      # 绘制各阶imf和residue
      for(i in 1:nImf) {
      plot(tmpList$imf[, i], type = "l")
      }
      plot(tmpList$residue, type = "l")
      
      # 关闭绘图格式控制
      par(mfrow = c(1, 1), mar = c(2, 2, 2, 2))
    }
  }
  
  # 打印信息
  print(paste("nImf.sum = ", nImf.sum, sep = ""))
  print(paste("nResidue.sum = ", nTest, sep = ""))
  print(paste("nImf.max = ", nImf.max, sep = ""))
  print(paste("nImf.min = ", nImf.min, sep = ""))
  
  # 返回结果
  return(list(
    emdList = emdList, 
    nImf.sum = nImf.sum,
    nImf.max = nImf.max,
    nImf.min = nImf.min
  ))
}


### 测试
# 计算
# emdList_TEST <- getEmdListAdvanced(data = maxTemperatureByDay, nTest = 3, trainStartIndex = 2901, trainEndIndex = 3000, fix = T, plot = F, max.imf = 1, boundary = "none")
