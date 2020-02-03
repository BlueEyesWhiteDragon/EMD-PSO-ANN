### 判定序列是否平稳，原假设是非平稳，所以只要有证据表明平稳，就可以认为平稳
isStationary <- function(data, maxLag = 3) {
  typeVec = c("nc", "c", "ct")
  flag = FALSE
  for(i in 1:maxLag) {
    for(j in 1:length(typeVec)) {
      adfTestResult = adfTest(data, lag = i, type = typeVec[j])
      pValue = adfTestResult@test$p.value
      if(pValue < 0.05) {
        print(paste(pValue, i, typeVec[j], sep = ", "))
        flag = TRUE
      }
    }
  }
  return(flag)
}