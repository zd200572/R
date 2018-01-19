library('rvest')
web1<-read_html("https://movie.douban.com/top250",encoding="UTF-8")
web2<-read_html("https://book.douban.com/top250?icn=index-book250-all",encoding="UTF-8")
#content > div > div.article > div > table:nth-child(2) > tbody > tr > td:nth-child(2) > p.pl
#<p class="pl">[��] ���յ¡������� / ��̺� / �Ϻ���������� / 2006-5 / 29.00Ԫ</p>
position<-web2 %>% html_nodes("p.pl2") %>% html_text() 

install.packages("meme")
install.packages("installr")
library(installr)
updateR()

library(yyplot)
term <- c('"thiobencarb"')
pm <- pubmed_trend(term, year=2001:2017)
plot(pm)