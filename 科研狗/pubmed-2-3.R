killDbConnections()
library(RMySQL)
con <- dbConnect(MySQL(),host="127.0.0.1",dbname="rdb",user="root",password="")
dbSendQuery(con,'SET NAMES utf8')
library(httr)
totalNum=563 
pageSize=10 
totalPage=ceiling(totalNum/pageSize) 
currentPage=1
term='(cell[TA]) AND 2017[DP]'
usehistory='Y'
querykey=''
webenv=''
postSearchUrl='https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi'
while(currentPage<=totalPage){
  retstart=(currentPage-1)*pageSize
  r <- POST(postSearchUrl, 
            body = list(db='pubmed',
                        term=term,
                        retmode='json',
                        retstart=retstart,
                        retmax=pageSize,
                        usehistory=usehistory,
                        rettype='uilist' 
            )
  )
  stop_for_status(r) #clear http status
  data=content(r, "parsed", "application/json")
  esearchresult=data$esearchresult
  querykey=esearchresult$querykey
  webenv=esearchresult$webenv
  idlist =esearchresult$idlist 
  n = length(idlist)
  pmid=c()
  i = 1
  while(i<=n){
    pmid=c(pmid, as.character(idlist[i][1]))
    i = i+1
  }
  article=data.frame('pmid'=pmid)
  append=TRUE
  dbWriteTable(con,"article",article,append=TRUE) 
  currentPage = currentPage + 1 
}
dbDisconnect(con)



#任务�?


library(RMySQL)
library(xml2)
library(httr)
killDbConnections()
con <- dbConnect(MySQL(),host="127.0.0.1",dbname="rdb",user="root",password="")
dbSendQuery(con,'SET NAMES utf8')
rs <- dbSendQuery(con, "SELECT * FROM article WHERE isdone=0")
while (!dbHasCompleted(rs)) {
  chunk <- dbFetch(rs, 10)
  pmidStr=""
  i=1
  n=nrow(chunk) 
  while (i<=n){
    pmidStr = paste(pmidStr,chunk[i,3],sep=",") 
    i = i + 1
  }
  pmidStr=substr(pmidStr,2,100000) 
  postFetchUrl='https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi'
  r2 <- POST(postFetchUrl, 
             body = list(
               db='pubmed',
               id=pmidStr,
               retmode='xml'
             )
  )
  stop_for_status(r2) #clear http status
  data2=content(r2, "parsed", "application/xml")
  article=xml_children(data2)
  count=length(article)
  cnt=1
  while(cnt<=count){
    title=xml_text(xml_find_first(article[cnt],".//ArticleTitle")) 
    abstract=xml_text(xml_find_first(article[cnt],".//AbstractText"))
    pmid=xml_text(xml_find_first(article[cnt],".//PMID"))
    title = gsub("'","",title)
    abstract = gsub("'","",abstract)
    sql=paste("UPDATE article SET title='",title,"',abstract='",abstract,"',isdone=1"," where pmid='",pmid,"'",sep="")
    con2 <- dbConnect(MySQL(),host="127.0.0.1",dbname="rdb",user="root",password="")
    dbSendQuery(con2,'SET NAMES utf8')
    dbSendQuery(con2,sql)
    dbDisconnect(con2)
    cnt = cnt + 1
    Sys.sleep(1)
  }
}
