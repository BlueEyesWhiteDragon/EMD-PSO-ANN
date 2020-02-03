### 输入一个一维时间序列，进行白噪声检验，如果序列为白噪声，则返回TRUE，否则返回FALSE
isWhiteNoise <- function(data, maxLag = 12) {
  for(i in seq(1, maxLag)) {
    boxTest = Box.test(data, type = "Ljung-Box", lag = i)
    boxTest.pValue = boxTest$p.value
    if(boxTest.pValue < 0.05) {
      print(paste(i, "阶延迟时，白噪声检验的p值：", boxTest.pValue, " < 0.05，原序列不是白噪声序列。", sep = ""))
      return(FALSE)
    }
    else if( i == maxLag) {
      print("没有明显证据表明该序列不是一个白噪声序列。")
      return(TRUE)
    }
  }
}