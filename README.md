# Project: Open Data NYC - an RShiny app development project
### [Project Description](doc/project2_desc.md)

Term: Fall 2016

+ Team #8
+ Project title: Noises Around You
+ Team members
	+ Chen, Zheyuan
	+ Gao, Yinxiang
	+ Song, Shuli
	+ Zhang, Chi
	+ Zhang, Wanyi


### Background
    
   We know a lot of New Yorkers are as picky as we are, especially when renting/buying an apartment. New York City is such a big apple glazed with hustle and bustle, which not only gives you convenience of living in a big city but also annoys you with its side effects, such as, noises, rodents, and bugs.
   
### Project summary
   
   This project explores and visualizes the noise level in New York City by integrating analyses of the 311 complaints data in 2015 on [NYC Open Data Portal](https://nycopendata.socrata.com/Social-Services/311-Service-Requests-from-2010-to-Present/erm2-nwe9), the geographical data of construction sites, fire stations, hospitals, and clubs in NYC. We create a Shiny App to help users navigate through our findings in 3 main tabs: Statistics, Map and Data. 

   + Statistics: 
   This tab presents 3 visualizations of the noise data, inlcuding an interactive time series plot, heatmap of the numbers of noise complaints in NYC, and donut chart of noise complaint types.
   
   + Map: 
   This tab is an interactive map which enables users to pinpoint any location in New York City, and the algorithms will automatically calculate and output geographical information and summary statistics of surrounding noise complaints of that location. Users can also customize display settings, choose radius they want to explore, and compare multiple location results.
   
   + Data: 
   This tab contains the original 311 noise complaint data we used to conduct the analysis and write the algorithms. It also enables searching and sorting functions.
	
   Our next step is to provide more perspectives by incorporating data of rodents/pests sightings. We hope this app could help New Yorkers find their peaceful land!


![screenshot](doc/Screenshot_temp.png)


