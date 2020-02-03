### 输入一个hclust函数的系统聚类结果，输入想要分成几类，输出能够分成这么多类的截取高度
### INPUT
## data.hclust 由hclust函数给出的系统聚类结果
## nType 准备将数据分成多少类
### OUTPUT
## height 截取的高度
setHeightByNType <- function(data.hclust = NULL, nType = 2) {
  heightsVec = data.hclust$height
  len = length(heightsVec)
  height = (heightsVec[len - (nType - 2)] + heightsVec[len - (nType - 1)]) / 2
}