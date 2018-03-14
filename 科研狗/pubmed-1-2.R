#任务1
library(RMySQL)
help(package="RMySQL") #查看RMySQL的说明文档，里面有RMySQL所有可用的方法  
#创建数据库连�? ，localhost代表本机，dbname就是上面创建的rdb，用户名一般是root
# password为空（如果你没设置的话一般都是这样的)
con <- dbConnect(MySQL(),host="127.0.0.1",dbname="rdb",user="root",password="")
dbSendQuery(con,'SET NAMES utf8')
#获取连接信息，查看database下所有表
#summary(con)  
#dbGetInfo(con)  
#dbListTables(con)  
#dbRemoveTable(con,"test")

#数据库连接删除函数，每个任务之前最好先清理所有的连接，调用此函数就可�?
killDbConnections <- function () {
  all_cons <- dbListConnections(MySQL())
  print(all_cons)
  for(con in all_cons)
      dbDisconnect(con)
  print(paste(length(all_cons), " connections killed."))
}

killDbConnections()

#任务2
con<-dbConnect(MySQL(),host="127.0.0.1",dbname="rdb",user="root",password="")
dbSendQuery(con,'SET NAMES utf8')
library(httr)
totalNum=562
pageSize=10
totalPage=ceiling(totalNum/pageSize)
currentPage=1
term='(cell[TA]) AND 2017[DP]'
Url='https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi'
while(currentPage<=totalPage){
  retstart=(currentPage-1)*pageSize
  r <- POST(Url, 
            body = list(
              db='pubmed',
              term=term,
              retmode='json',
              retstart=retstart,
              retmax=pageSize,
              #usehistory=usehistory,
              rettype='uilist'
            )
  )
  
  stop_for_status(r) 
  data=content(r, "parsed", "application/json")
  esearchresult=data$esearchresult
  idlist =esearchresult$idlist
  n = length(idlist)
  pmid=c()
  i = 1
  while(i<=n){
    pmid=c(pmid, as.character(idlist[i][1]))
    i = i+1
  }
  article=data.frame('pmid'=pmid)
  dbWriteTable(con,"article",article,append=TRUE) 
  currentPage = currentPage + 1
}
