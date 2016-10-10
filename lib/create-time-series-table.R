#For time series plot

require(data.table)
require(dplyr)

noise <- fread("~/Google Drive/Columbia/5243 ADS/Project 2/Fall2016-Proj2-grp8/data/Cleaned-311-Noise-Date.csv")
df=data.frame(table(noise$Date))
names(df)<-c("Date","Freq")

# add columns of Months, Weeks, and Weekdays (Day)
df$Date <- as.Date(df$Date,format="%m/%d/%y") #convert to standard Date format
df$Day <- format(df$Date,"%a") #Add Day column
df$Month <- as.Date(cut(df$Date,breaks = "month"))
df <- mutate(df,Month=substr(Month,6,7)) #Add Month column
df$Week <- as.Date(cut(df$Date,breaks = "week",start.on.monday = T)) # Add Week column

write.table(df,file="time-series-table.csv")
list.files()

WeekMean=summarise(group_by(df,Week),round(mean(Freq)))
DayMean=summarise(group_by(df,Day),round(mean(Freq)))

