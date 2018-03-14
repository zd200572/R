library(RISmed)
paper <-function(keyword="Hello World", start_date=2000, end_date=2017 )
{
  tally <-array()
  x<-1
  for(i in start_date:end_date ){
    Sys.sleep(1)
    r <-EUtilsSummary(keyword, type="esearch",db='pubmed', mindate=i, maxdate=i)
    tally[x] <-QueryCount(r)
    x <-x +1
  }
  names(tally)<-start_date:end_date
  tally
}
iPS <-paper("gut microbiome", 2000,2017)

organ <-paper("organoid",2000,2017)

crispr <-paper("CRISPR", 2000, 2017)

snp <-paper("SNP",2000,2017)

##绘制柱状图

barplot(iPS, las=2, ylim=c(0,max(iPS)+50),col="purple", ylab="PaperNumber",xlab="Year", main="iPSC")

barplot(crispr, las=2, ylim=c(0,max(crispr)+50),col="purple", ylab="PaperNumber",xlab="Year", main="CRISPR")

barplot(organ, las=2, ylim=c(0,max(organ)+50),col="purple", ylab="PaperNumber",xlab="Year", main="Organoids")

barplot(snp, las=2, ylim=c(0,max(snp)+50),col="purple", ylab="PaperNumber",xlab="Year", main="SNP")

##使用forecast软件包来实现

library(forecast)

myts <-ts(iPS[1:16], start=2000, end=2017, frequency=1)

fit <-auto.arima(myts)


##  预测之后5年文章的数量


my_pre<-predict(fit,n.ahead=5)

plot(seq(2000, 2015),iPS,ylim=c(0,2500),xlim=c(2000,2020), pch=19, col="blue",las=2, main="Trands of CRISPR Paper Number", xlab="Year",ylab="PaperNumber")

points(my_pre$pred,col="red",pch=19)

lines(myts)

lines(my_pre$pred)