library(jsonlite)
library(dplyr)
salary107<-fromJSON("salary107.json")
salary104<-fromJSON("http://ipgod.nchc.org.tw/dataset/b6f36b72-0c4a-4b60-9254-1904e180ddb1/resource/63ecb4a9-f634-45f4-8b38-684b72cf95ba/download/0df38b73f75962d5468a11942578cce5.json")
names(salary104)[13]<-"研究所-薪資"
names(salary104)[14]<-"研究所-女/男"
salary104$大職業別 <- gsub("部門|、", "", salary104$大職業別)
salary104$大職業別 <- gsub("營造業", "營建工程", salary104$大職業別)
salary104$大職業別 <- gsub("資訊及通訊傳播業", "出版、影音製作、傳播及資通訊服務業", salary104$大職業別)
salary104$大職業別 <- gsub("教育服務業", "教育業", salary104$大職業別)
salary104$大職業別 <- gsub("醫療保健服務業", "醫療保健業", salary104$大職業別)
salary107$大職業別 <- gsub("_", "", salary107$大職業別)
for (i in 3:14) {
  names(salary104)[i] <- paste0("104", names(salary104)[i])
  names(salary107)[i] <- paste0("107", names(salary107)[i])
}
salary104 <- subset(salary104, select = -年度)
salary107 <- subset(salary107, select = -年度)
salarydf <- full_join(salary104, salary107, by = "大職業別")

###Q1薪資比較
salarydf$`104大學-薪資` <- gsub("—","",salarydf$`104大學-薪資`)
salarydf$`107大學-薪資` <- gsub("—|…","",salarydf$`107大學-薪資`)
salarydf$`104大學-薪資`<-as.numeric(salarydf$`104大學-薪資`)
salarydf$`107大學-薪資`<-as.numeric(salarydf$`107大學-薪資`)
salarydf$rate <- salarydf$`107大學-薪資`/salarydf$`104大學-薪資`
head(salarydf[order(salarydf$rate, decreasing = T),],10)

###
RateH <- filter(salarydf, salarydf$rate>1.05)%>%
  select("大職業別","rate")

###
Main_Job <- strsplit(RateH$大職業別, "-")
for (i in 1:53) {
  Main_Job[i] <- Main_Job[[i]][1]
}
Main_Job = as.vector(unlist(Main_Job))
sort(table(Main_Job), decreasing = T)

###Q2同工不同酬
salarydf$`104大學-女/男` <- gsub("—|…","",salarydf$`104大學-女/男`)
salarydf$`107大學-女/男` <- gsub("—|…","",salarydf$`107大學-女/男`)
salarydf$`104大學-女/男`<-as.numeric(salarydf$`104大學-女/男`)
salarydf$`107大學-女/男`<-as.numeric(salarydf$`107大學-女/男`)
B104 <- filter(salarydf, salarydf$`104大學-女/男`<100)%>%
  select("大職業別", "104大學-女/男")
B107 <- filter(salarydf, salarydf$`107大學-女/男`<100)%>%
  select("大職業別", "107大學-女/男")
head(B104[order(B104$`104大學-女/男`, decreasing = F),],10)
head(B107[order(B107$`107大學-女/男`, decreasing = F),],10)

###
G104 <- filter(salarydf, salarydf$`104大學-女/男`>100|salarydf$`104大學-女/男`==100)%>%
  select("大職業別", "104大學-女/男")
G107 <- filter(salarydf, salarydf$`107大學-女/男`>100|salarydf$`107大學-女/男`==100)%>%
  select("大職業別", "107大學-女/男")
head(G104[order(G104$`104大學-女/男`, decreasing = T),],10)
head(G107[order(G107$`107大學-女/男`, decreasing = T),],10)

###研究所薪資差異
names(salarydf)[26]<-"107大學薪資/104大學薪資"
salarydf$`107研究所-薪資` <- gsub("—|…","", salarydf$`107研究所-薪資`)
salarydf$`107研究所-薪資` <- as.numeric(salarydf$`107研究所-薪資`)
is.numeric(salarydf$`107研究所-薪資`)
salarydf$`107研究所/大學` <- salarydf$`107研究所-薪資`/salarydf$`107大學-薪資`
head(salarydf[order(salarydf$`107研究所/大學`, decreasing = T),c(1,22,24,27)],10)

#我有興趣的職業別薪資狀況分析
Mine <- filter(salarydf,大職業別 %in% c("服務業-技術員及助理專業人員",
                            "金融及保險業-技術員及助理專業人員",
                            "出版、影音製作、傳播及資通訊服務業-專業人員",
                            "出版、影音製作、傳播及資通訊服務業-技術員及助理專業人員",
                            "藝術娛樂及休閒服務業-專業人員")) %>% select(c(1,22,24,27))
Mine$`薪資漲幅` <- Mine$`107研究所-薪資`-Mine$`107大學-薪資`




