```{r setup}
noise_data <- read.csv("/Users/celiachen/Downloads/Fall2016-Proj2-grp8-master/data/Cleaned-311-Noise.csv")
library(googleVis)
library(dplyr)
library(data.table)
```

```{r cars}
vars <- c("Club/Bar/Restaurant","Residential Building/House","Street/Sidewalk", "Store/Commercial","Park/Playground","House of Worship","Above Address")

club <- as.numeric(count(noise_data, noise_data$Location.Type == "Club/Bar/Restaurant")[2,2])
house <- as.numeric(count(noise_data, noise_data$Location.Type == "Residential Building/House")[2,2])
Street <- as.numeric(count(noise_data, noise_data$Location.Type == "Street/Sidewalk")[2,2])
Commercial <- as.numeric(count(noise_data, noise_data$Location.Type == "Store/Commercial")[2,2])
Park <- as.numeric(count(noise_data, noise_data$Location.Type == "Park/Playground")[2,2])
Worship <- as.numeric(count(noise_data, noise_data$Location.Type == "House of Worship")[2,2])
other <- as.numeric(count(noise_data, noise_data$Location.Type == "Above Address")[2,2])

```

##Here is the Donut


dat <- data.frame(party=c("Club/Bar/Restaurant","Residential Building/House","Street/Sidewalk",
                          "Store/Commercial","Park/Playground","House of Worship","Above Address"),
                  members.of.parliament=c(20813, 205810, 70048, 
                                          22723, 3993, 1056, 1493))

doughnut <- gvisPieChart(dat, 
                         options=list(
                           width=500,
                           height=500, slices="{0: {offset: 0.1},
                           1: {offset: 0.1},
                           2: {offset: 0.1}, 3: {offset: 0.1}, 4: {offset: 0.1}, 5: {offset: 0.1}, 6: {offset: 0.1}, 7: {offset: 0.1}}",
                           title(main =list('Noise Complaint Type Distribution', cex = 1.5, font = 10)), 
                           legend= 'none',
                           colors="['red','orange','green','blue','purple','yellow','grey']",
                           pieSliceText=' ',
                           pieHole=0.5, chartid="doughnut"))
plot(doughnut)