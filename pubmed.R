install.packages("httr")
install.packages("xml2")
library(httr)
library(xml2)
search<-'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=cell[journal]+AND+2018[pdat])'
data<-POST(search)
print(data)
summary(data)
