require(data.table)
data<-fread("Cleaned-311-Noise.csv")
attach(data)
data.hour<-as.numeric(substr(Time,1,2))
data.test<-c(data,count.hour)
count.hour<-as.data.frame(table(data.hour))
#bar plot
ggplot(count.hour, aes(count.hour$data.hour,count.hour$Freq)) + geom_bar(stat = "identity",colour=factor(count.hour$data.hour))
#point and line plot
ggplot(count.hour,aes(data.hour,Freq)) + geom_point() + geom_line(group=1)+theme_bw() + labs(title="Total Complains Time Distribution",x="Hour",y="Number of Complain")
