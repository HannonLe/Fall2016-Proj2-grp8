##### clean all data #####

# script left for data cleaning purpose

library(dplyr)
library(stringr)

# 311 data with time
noise311 <- read.csv("../data/Cleaned-311-Noise.csv",stringsAsFactors = F)
str(noise311)
table(noise311$Descriptor)
table(noise311$Complaint.Type)
table(noise311$Location.Type)

# noise311$Descriptor <- str_replace(noise311$Descriptor, "(Noise\\: )|(Noise\\, )", "")
# noise311$Descriptor <- str_replace(noise311$Descriptor, " \\(N.+\\)", "")
# noise311 <- filter(noise311,
#                   Descriptor != "Loud Music/Daytime (Mark Date And Time)",
#                   Descriptor != "Loud Music/Nighttime(Mark Date And Time)",
#                   Descriptor != "Air Condition/Ventilation Equip, Commercial",
#                   Descriptor != "Other Noise Sources (Use Comments)" )
noise <- with(noise311[noise311$Location.Type != "",], data.frame(time=Time, hour=as.numeric(str_match(Time,"\\d\\d")), type=Location.Type, lat=Latitude, lng=Longitude))

# hospital
hospital <- read.csv("../data/NYC_Health_and_Hospitals_Corporation_Facilities.csv",stringsAsFactors = F)
str(hospital)
temp <- unlist(str_match_all(str_match(hospital$Location.1, "\\(.+\\)"), "[\\d|\\.|\\-]+"))
markers_hospital <- data.frame(name=hospital$Facility.Name,
                       lat=temp[1:(length(temp)/2)*2-1],
                       lng=temp[1:(length(temp)/2)*2],
                       address=str_sub(str_match(str_replace_all(hospital$Location.1, "\\n", " "), "[^\\()]+"), 1,-2))
rm(temp)

# 311 data with date
noise_date <- read.csv("../data/Cleaned-311-Noise-Date.csv")

# fire station
fire <- read.csv("../data/Fire Station.csv",stringsAsFactors = F)
markers_fire_station <- data.frame(name="", lat=fire$lat, lng=fire$lng, address="")

# club
club <- read.csv("../data/club_location.csv",stringsAsFactors = F)
markers_club <- data.frame(name="", lat=club$Latitude, lng=club$Longitude,
                           address=paste(club$Actual.Address.of.Premises..Address1.,", NY ",club$Zip,sep=""))
# construction
construct <- read.csv("../data/Projects_in_construction.csv",stringsAsFactors = F)
str(construct)
construct <- construct[-(1:17),]
temp <- unlist(str_extract_all(str_extract(construct$Location.1, "\\(.+\\)"), "[\\d|\\.|\\-]+"))
markers_construction <- data.frame(name=construct$projdesc,
                                   lat=temp[1:(length(temp)/2)*2-1],
                                   lng=temp[1:(length(temp)/2)*2],
                                   address=str_sub(str_match(str_replace_all(construct$Location.1, "\\n", " "), "[^\\()]+"), 1,-2))
rm(temp)

# include both date and time
noise311 <- noise311 %>% 
  mutate(Date=noise_date$Date) %>% 
  select(Date, Time, Complaint.Type,Location.Type,Descriptor,Latitude,Longitude)

### done cleaning

# save to www folder
save(noise311, noise, noise_date, markers_construction,markers_fire_station,markers_hospital,markers_club, file="../app/www/all_data.RData")

# test
load("../app/www/all_data.RData")
