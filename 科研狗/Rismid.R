library(RISmed)
cell2017<-EUtilsSummary("cell[TA] AND 2017[DP]")
data<-QueryId(cell2017)
data #获得全部的ID
pmids<-paste(data,sep = "",collapse=",")
#pmids
library(RMySQL)
library(xml2)
library(httr)
postFetchUrl<-'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?'
r2 <- POST(postFetchUrl,body = list(db='pubmed',id=pmids,retmode='xml'))
stop_for_status(r2) 
data2=content(r2, "parsed")
article=xml_children(data2)
count=length(article)
cnt=1
a<-list()
b<-list()
while(cnt<=count){title=xml_find_first(article[cnt],".//ArticleTitle")
abstract=xml_find_first(article[cnt],".//AbstractText")
#write.table(xml_text(title),file='a.txt', row.names=F,quote=F,append=T)
a<-c(a,xml_text(title))
#write.table(print(xml_text(abstract)),file='b.txt',row.names=F,quote=F,append=T)
b<-c(b,xml_text(abstract))
#break
cnt = cnt + 1
}
c<-data
pmid<-c
title=a
abstract<-b
title = gsub("'","",title)
abstract = gsub("'","",abstract)
article<-data.frame(pmid,title,abstract)
con<-dbConnect(MySQL(),host="127.0.0.1",dbname="rdb",user="root",password="")
dbSendQuery(con,'SET NAMES utf8')
dbWriteTable(con,"article",article,append=TRUE) 
dbDisconnect(con)
