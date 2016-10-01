##### clean data #####

# script left for data cleaning purpose

'
library(data.table)
library(dplyr)

req2015 <- fread("../data/311_Service_Requests_from_2015.csv")
names(req2015)
str(req2015)

head(req2015)
'