library(httr)
baseUrl="https://eutils.ncbi.nlm.nih.gov/"
pubmedAction=list(
  base="entrez/eutils/index.fcgi",
  search="entrez/eutils/esearch.fcgi", #搜索接口
  fetch="entrez/eutils/efetch.fcgi", #获取数据接口
  summary="entrez/eutils/esummary.fcgi" #获取数据接口（fetch可返回多种数据格式）
)
#搜索文章的参数
searchArticleParam=list(
  retstart=0, #起始位置
  retmax=20, #每次取的数量
  usehistory='Y',#是否使用历史搜索
  querykey='',
  webenv='',
  term='(cell[TA]) AND 2017[DP]',#提交pubmed的词， 
  total_num=0, #总记录
  total_page=1, #总页数
  page_size=20, #每页数目
  current_page=1 #当前所在页数
)
postSearchUrl=paste(baseUrl,pubmedAction$search,sep="") #拼接搜索地址
r <- POST(postSearchUrl, 
          body = list(
            db='pubmed',
            term=searchArticleParam$term,
            retmode='json',
            retstart=searchArticleParam$retstart,
            retmax=searchArticleParam$retmax,
            usehistory=searchArticleParam$usehistory,
            rettype='uilist'
          )
)

stop_for_status(r) #清除http状态字符串
data=content(r, "parsed", "application/json") 
#data里面存储了所有数据
esearchresult=data$esearchresult
# $count=562,$retmax=20, $retstart=0,$querykey=1, $webenv=NCID_1_30290513_130.14.18.34_9001_1515165012_617859421_0MetA0_S_MegaStore_F_1
count = esearchresult$count
print(count)



#获得title和abstract
#这里使用了上面搜索返回的querkey,webnv，可以加快速度。下面的POST中可以不加上这参数
searchArticleParam$total_num=esearchresult$count
searchArticleParam$querykey=esearchresult$querykey
searchArticleParam$webenv=esearchresult$webenv

pubmedidStr="29275861,29275860"; #多个pubmedid之间用“,”连接
postFetchUrl=paste(baseUrl,pubmedAction$fetch,sep="")
r2 <- POST(postFetchUrl, 
           body = list(
             db='pubmed',
             id=pubmedidStr,
             retmode='xml', #返回xml格式的，这个接口不支持json格式
             usehistory=searchArticleParam$usehistory,
             querykey=searchArticleParam$querykey,
             webenv=searchArticleParam$webenv
           )
)

stop_for_status(r2)

library(xml2)
data2=content(r2, "parsed", "application/xml")
article=xml_children(data2)
#xml_length(article)为里面文章的数量
count=length(article)
cnt=1
while(cnt<=count){ #循环将title和abstract输出
  title=xml_find_first(article[cnt],".//ArticleTitle") #找到第一个ArticleTitle节点
  abstract=xml_find_first(article[cnt],".//AbstractText")
  print(xml_text(title))
  print(xml_text(abstract))
  cnt = cnt + 1
}
