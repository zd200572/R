install.packages("httr")
install.packages("xml2")
library(httr)
library(xml2)
baseUrl="https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?"

searchArticleParam=list(retstart=0,retmax=20,usehistory='Y',querykey='',webenv='',term='(cell[TA]) AND 2017[DP]',total_num=0,total_page=1,  page_size=20, current_page=1) 
r<-POST(baseUrl,body=list(db='pubmed',term=searchArticleParam$term,retmode='json',retstart=searchArticleParam$retstart,retmax=searchArticleParam$retmax,usehistory=searchArticleParam$usehistory,
                          rettype='uilist'))
stop_for_status(r)
data=content(r, "parsed","application/json")
#data
esearchresult=data$esearchresult
count=esearchresult$count
print(count)
