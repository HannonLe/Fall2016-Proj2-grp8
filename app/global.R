##### global file #####

## Read all data, including 311 complaint data and all markers data
all_data <- load("www/all_data.RData")
## VARIABLES: noise, markers_construction, markers_fire_station, markers_hospital, markers_club
print(ls())

# complaint type and corresponding color
complaint <- data.frame(type=c("Club/Bar/Restaurant","Residential Building/House","Street/Sidewalk",
                               "Store/Commercial","Park/Playground","House of Worship","Above Address"),
                        color=c('red','orange','green','blue','purple','yellow','grey'), stringsAsFactors = F)


# 2 stat tab
## Genreating plots for statistics tab
## code given by Wanyi Zhang/Zheyuan Chen. See "lib/plots.Rmd"

generate_plots <- function(){
  #Data preparation for time series plot
  
  require(data.table)
  require(dplyr)
  
  
  df=data.frame(table(noise_date$Date))
  names(df)<-c("Date","Freq")
  
  # add columns of Months, Weeks, and Weekdays (Day)
  df$Date <- as.Date(df$Date,format="%m/%d/%y") #convert to standard Date format
  df$Day <- format(df$Date,"%a") #Add Day column
  df$Month <- as.Date(cut(df$Date,breaks = "month"))
  df <- mutate(df,Month=substr(Month,6,7)) #Add Month column
  df$Week <- as.Date(cut(df$Date,breaks = "week",start.on.monday = T)) # Add Week column
  
  WeekMean=summarise(group_by(df,Week),round(mean(Freq)))
  DayMean=summarise(group_by(df,Day),round(mean(Freq)))
  w=c("Mon","Tue","Wed", "Thu","Fri","Sat","Sun")
  DayM=DayMean[match(w,DayMean$Day),]
  names(DayM)[2]<-"Mean_Complaints"
  
  # Time Series Plotly
  require(plotly)
  plot1 <- plot_ly(WeekMean, x = ~Week) %>%
    add_lines(y = ~`round(mean(Freq))`) %>%
    layout(
      title = "NYC Weekly Mean Number of Noise Complaints 2015",
      xaxis = list(title="Weeks",
                   rangeselector = list(
                     buttons = list(
                       list(count = 3,label = "3 mo",step = "month",stepmode = "backward"),
                       list(count = 6,label = "6 mo",step = "month",stepmode = "backward"),
                       list(count = 1,label = "1 yr",step = "year",stepmode = "backward"),
                       list(count = 1,label = "YTD",step = "year",stepmode = "todate"),
                       list(step = "all"))),
                   rangeslider = list(type = "date"),
                   showbackground = F),
      yaxis = list(title = "Weekly Mean of Noise Complaints"),
      paper_bgcolor = rgb(1,1,1,0)
    )
  
  # dou
  
  library(googleVis)
  library(dplyr)
  library(data.table)
  
  ##Here is the Donut
  dat <- data.frame(party=c("Club/Bar/Restaurant","Residential Building/House","Street/Sidewalk",
                            "Store/Commercial","Park/Playground","House of Worship","Above Address"),
                    members.of.parliament=c(20813, 205810, 70048, 
                                            22723, 3993, 1056, 1493))
  
  doughnut <- gvisPieChart(dat, 
                           options=list(
                             width=700,
                             height=700, slices="{0: {offset: 0.1},
                             1: {offset: 0.1},
                             2: {offset: 0.1}, 3: {offset: 0.1}, 4: {offset: 0.1}, 5: {offset: 0.1}, 6: {offset: 0.1}, 7: {offset: 0.1}}",
                             legend= 'none',
                             colors="['red','orange','green','blue','purple','yellow','grey']",
                             pieSliceText=' ',
                             pieHole=0.5, chartid="doughnut"))

  
  return(list(ts=plot1, doughnut=doughnut))
}
stat_plots <- generate_plots()
rm(generate_plots)



