library(shiny)
library(leaflet)
library(data.table)
library(ggmap)
library(plotly)
library(geosphere)

# Read all data, including 311 complaint data and all markers data
all_data <- load("www/all_data.RData")
### VARIABLES: noise, markers_construction, markers_fire_station, markers_hospital, markers_club
print(ls())

# Calculate distance between two locations given their lat and lng
complaints_within <- function(r,lng,lat){
  return( noise[distCosine(c(lng,lat), noise[,c("lng","lat")]) <= r, ] )
}
# pallette for circle fill color
complaint <- data.frame(type=c("Club/Bar/Restaurant","Residential Building/House","Street/Sidewalk",
                               "Store/Commercial","Park/Playground","House of Worship","Above Address"),
                        color=c('red','orange','green','blue','purple','yellow','grey'),stringsAsFactors = F)

### test code
# distCosine(c(-73.8667758,40.7301094), noise[1:10,c("lng","lat")])
# distCosine(c(-73.949261,40.796914),c(-73.981882,40.768078))
# result: 4.22km. OMG it works!
# nrow(complaints_within(100,-73.957281,40.804097)) ## perfect!

shinyServer(function(input, output, session) {
  # 3.map tab
  ## Base map + test markers
  marker_opt <- markerOptions(opacity=0.8,riseOnHover=T)
  output$map <- renderLeaflet({
    m <- leaflet() %>%  addProviderTiles("Stamen.TonerLite") %>% setView(-73.983,40.7639,zoom = 13) # default map, base layer
    
    leafletProxy("map", data = markers_construction) %>%
      addMarkers(~lng,~lat,popup=~name,group="markers_construction",options=marker_opt,icon=list(iconUrl='icon/construction.png',iconSize=c(25,25)))
    leafletProxy("map", data = markers_fire_station) %>%
      addMarkers(~lng,~lat,popup=NULL,group="markers_fire_station",options=marker_opt,icon=list(iconUrl='icon/fire_station.png',iconSize=c(25,25)))
    leafletProxy("map", data = markers_hospital) %>%
      addMarkers(~lng,~lat,popup=~name,group="markers_hospital",options=marker_opt,icon=list(iconUrl='icon/hospital.png',iconSize=c(25,25)))
    leafletProxy("map", data = markers_club) %>%
      addMarkers(~lng,~lat,popup=NULL,group="markers_club",options=marker_opt)
    
    leafletProxy("map") %>% hideGroup(c("markers_club"))
    m
  })

  ## change map color theme
  observeEvent(input$map_color, {
    leafletProxy("map") %>% addProviderTiles(input$map_color)
  })
  
  ## enable/disable markers of specific group
  observeEvent(input$enable_markers, {
    if("Construction" %in% input$enable_markers) leafletProxy("map") %>% showGroup("markers_construction")
    else{leafletProxy("map") %>% hideGroup("markers_construction")}
    if("Fire Station" %in% input$enable_markers) leafletProxy("map") %>% showGroup("markers_fire_station")
    else{leafletProxy("map") %>% hideGroup("markers_fire_station")}
    if("Hospital" %in% input$enable_markers) leafletProxy("map") %>% showGroup("markers_hospital")
    else{leafletProxy("map") %>% hideGroup("markers_hospital")}
    if("Club" %in% input$enable_markers) leafletProxy("map") %>% showGroup("markers_club")
    else{leafletProxy("map") %>% hideGroup("markers_club")}
  }, ignoreNULL = FALSE)
  
  ## upon click, show circle around the location along with popups
  observeEvent(input$map_click, {
    # remove previous circles
    if(!input$click_multi) leafletProxy('map') %>% clearGroup(c("circles","centroids",complaint$type))
    # Get the click info
    click <- input$map_click
    clat <- click$lat
    clng <- click$lng
    address <- NULL
    if(input$click_show_address) address <- revgeocode(c(clng,clat))

    
    ### Comment Down below are from Stackoverflow. AG ###
    ## Add the circle to the map proxy
    ## so you dont need to re-render the whole thing
    ## I also give the circles a group, "circles", so you can
    ## then do something like hide all the circles with hideGroup('circles')
    
    # draw circles
    leafletProxy('map') %>%
      addCircles(lng=clng, lat=clat, group='circles',
                 stroke=F, radius=input$click_radius, fillColor="#8c8c8c",
                 popup=address, fillOpacity=0.5) %>%
      addCircles(lng=clng, lat=clat, group='centroids', radius=1, weight=2, color='black',opacity=1,fillColor='black',fillOpacity=1)
    
    # output panel info
    ## text info
    output$click_coord <- renderText(paste("Lat:",round(clat,6),", Long:",round(clng,6)))
    output$click_address <- renderText(address)
    ## calculated noise info
    complaints_within_range <- complaints_within(input$click_radius, clng, clat)
    complaints_total <- nrow(complaints_within_range)
    complaints_per_day <- complaints_total / 365

    output$click_complaints_per_day <- renderText(round(complaints_per_day,3))
    
    ## draw dots for every single complaint within range
    complaints_within_range <- merge(complaints_within_range,complaint,by=c("type","type"),all.y=F)
    leafletProxy('map', data=complaints_within_range) %>%
      addCircles(~lng, ~lat, group=~type,
                 stroke=F, radius=12, fillColor=~color,
                 fillOpacity=0.2)
    
    ## Complaint type pie chart
    output$click_complaint_pie <- renderPlotly({
      # an example
      ds <- table(complaints_within_range$type)
      ds <- ds[complaint$type]
      ds[is.na(ds)] <- 0
      plot_ly(labels=complaint$type, values=ds, type = "pie",
              marker=list(colors=complaint$color)) %>%
        layout(title = NULL,showlegend=F,
               xaxis=list(showgrid=F,zeroline=F,showline=F,autotick=T,ticks='',showticklabels=F),
               yaxis=list(showgrid=F,zeroline=F,showline=F,autotick=T,ticks='',showticklabels=F))
    })
    
  })

  ## show/hide complaint dots of specific group
  observeEvent(input$click_complaint_type, {
    for(type in complaint$type){
      if(type %in% input$click_complaint_type) leafletProxy("map") %>% showGroup(type)
      else{leafletProxy("map") %>% hideGroup(type)}
    }
  }, ignoreNULL = FALSE)
  
  ## all/none complaint types
  observeEvent(input$click_all_complaint_types, {
    updateCheckboxGroupInput(session, "click_complaint_type",
                             choices = complaint$type,
                             selected = complaint$type)
  })
  observeEvent(input$click_none_complaint_types, {
    updateCheckboxGroupInput(session, "click_complaint_type",
                             choices = complaint$type,
                             selected = NULL)
  })
  
  ## clear all circles
  observeEvent(input$clear_circles, {
    leafletProxy('map') %>% clearGroup(c("circles","centroids",complaint$type))
  })
  
  
  # 4.data tab
  output$table <- renderDataTable(iris,
    options = list(pageLength = 10)
  )
})