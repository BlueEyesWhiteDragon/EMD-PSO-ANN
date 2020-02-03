### 给定原始序列、nPredict、nUse，以窗口宽度为nUse，向后平移窗口，对窗口内的数据进行EMD分解
### INPUT
## data
## nPredict
## nUse
### Output
## emdList

### 改进1C
## EMD窗口不平移，而是逐渐增宽，将indexStart固定
## 修改emd边界条件为"symmetric"
getEmdList1C <- function(data, nPredict, nUse) {
  # 格式化原始数据
  data = matrix(data, ncol = 1)
  # 获取序列长度
  nData = nrow(data)
  # emd起始位置
  indexStart = nData - nPredict - nUse + 1
  # 存放结果列表
  emdList = vector("list", nPredict)
  # 查看一共有多少个imf和residue分量
  nImf = 0
  # 从indexStart位置开始，以宽度为nUse的窗口向后平移，对窗口内的序列进行emd分解，共计进行nPredict次emd分解
  for(count in 1:nPredict) {
    print(paste("开始进行第", count, "/", nPredict, "次EMD分解", sep = ""))
    # 截取数据
    tmpData = data[indexStart:(indexStart+nUse+count-2), ]
    # 对截取数据进行EMD分解
    tmpList = emd(tmpData, seq(1, (nUse+count-1)), boundary = "symmetric")
    
    # 累加imf和residue总数
    nImf = nImf + tmpList$nimf + 1
    
    # 更新列表
    emdList[[count]] = tmpList
    
    # 绘图格式控制
    # par(mfrow = c(tmpList$nimf + 1, 1), mar = rep(0, 4))
    
    # 绘制各阶imf和residue
    # for(i in 1:tmpList$nimf) {
    # plot(tmpList$imf[, i], type = "l")
    # }
    # plot(tmpList$residue, type = "l")
    
    # 关闭绘图格式控制
    # par(mfrow = c(1, 1), mar = c(2, 2, 2, 2))
    
    # 窗口起始位置平移
    # indexStart = indexStart + 1
  }
  
  print(paste("所有分量共计", nImf, "个", sep = ""))
  
  return(list(
    emdList = emdList, 
    nImf = nImf
  ))
}