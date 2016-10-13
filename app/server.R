library(shiny)
library(leaflet)
library(data.table)
library(ggmap)
library(plotly)
library(geosphere)


# 3 map tab


## Calculate distance between two locations given their lat and lng
complaints_within <- function(r,lng,lat){
  return( noise[distCosine(c(lng,lat), noise[,c("lng","lat")]) <= r, ] )
}
## test code
## distCosine(c(-73.8667758,40.7301094), noise[1:10,c("lng","lat")])
## distCosine(c(-73.949261,40.796914),c(-73.981882,40.768078))
## result: 4.22km. OMG it works!
## nrow(complaints_within(100,-73.957281,40.804097)) ## perfect!

## pallette for circle fill color
pal <- colorNumeric("Greys", c(0,1), na.color = "#000000")





shinyServer(function(input, output, session) {
  # 2.stat tab
  ## time series plot
  output$stat_plot_ts <- renderPlotly(stat_plots[['ts']])
  ## heat map plot
  ## output$stat_plot_heatmap <- renderImage()
  output$stat_plot_doughnut <- renderGvis(stat_plots[['doughnut']])
  
  
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
    # leafletProxy("map", data = markers_club) %>%
    #  addMarkers(~lng,~lat,popup=NULL,group="markers_club",options=marker_opt)
    
    leafletProxy("map") %>% hideGroup(c("markers_club"))
    m
  })
  output$click_complaints_per_day_area_colorbar <- renderImage(previewColors(pal, 0:10/10))

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
    # if("Club" %in% input$enable_markers) leafletProxy("map") %>% showGroup("markers_club")
    # else{leafletProxy("map") %>% hideGroup("markers_club")}
  }, ignoreNULL = FALSE)
  
  ## upon click, show circle around the location along with popups
  observeEvent(input$map_click, {
    # remove previous circles
    if(!input$click_multi) leafletProxy('map') %>% clearGroup(c("circles","centroids",paste(complaint$type,rep(1:24,each=7))))
    # Get the click info
    click <- input$map_click
    clat <- click$lat
    clng <- click$lng
    radius <- input$click_radius
    address <- NULL
    if(input$click_show_address) address <- revgeocode(c(clng,clat))

    
    ### Comment Down below are from Stackoverflow. AG ###
    ## Add the circle to the map proxy
    ## so you dont need to re-render the whole thing
    ## I also give the circles a group, "circles", so you can
    ## then do something like hide all the circles with hideGroup('circles')
    
    # output panel info
    ## text info
    output$click_coord <- renderText(paste("Lat:",round(clat,6),", Long:",round(clng,6)))
    output$click_address <- renderText(address)
    ## calculated noise info
    complaints_within_range <- complaints_within(input$click_radius, clng, clat)
    complaints_total <- nrow(complaints_within_range)
    complaints_per_day <- complaints_total / 365
    complaints_per_day_area <- complaints_per_day / (radius/100)^2

    output$click_complaints_total <- renderText(complaints_total)
    output$click_complaints_per_day <- renderText(round(complaints_per_day,2))
    output$click_complaints_per_day_area <- renderText(round(complaints_per_day_area, 2))
    if(input$click_enable_hours) output$click_complaints_hour <- renderText(paste(nrow(subset(complaints_within_range,hour==input$click_hours))," in ",complaints_total, " complaints (", input$click_hours,"h)",sep=""))
    
    ## 24h time distribution
    output$click_complaint_timedist <- renderPlotly({
      ds <- table(complaints_within_range$hour)
      ds <- ds[as.character(1:24)]
      ds[is.na(ds)] <- 0
      ds <- data.frame(hour=1:24,count=as.data.frame(ds)$Freq)
      plot_ly(x=ds$hour,y=ds$count, type='bar') %>%
        layout(title="Time distribution in 24h",
               xaxis=list(title="Hours",tickfont=list(size=9)),
               yaxis=list(title="Complaints",tickfont=list(size=9)))
    })
    
    # draw circles
    leafletProxy('map') %>%
      addCircles(lng=clng, lat=clat, group='circles',
                 stroke=T, radius=radius, popup=paste("NOISE LEVEL:",round(complaints_per_day_area,2), sep=" "),
                 color='black', opacity=1, weight=1,
                 fillColor=pal(complaints_per_day_area),fillOpacity=0.5) %>%
      addCircles(lng=clng, lat=clat, group='centroids', radius=1, weight=2, color='black',opacity=1,fillColor='black',fillOpacity=1)
    
    ## draw dots for every single complaint within range
    complaints_within_range <- merge(complaints_within_range,complaint,by=c("type","type"),all.y=F)
    leafletProxy('map', data=complaints_within_range) %>%
      addCircles(~lng, ~lat, group=~paste(type,hour),
                 stroke=F, radius=12, fillColor=~color,
                 fillOpacity=0.2)
    
    ## Complaint type pie chart
    output$click_complaint_pie <- renderPlotly({
      # an example
      if(input$click_enable_hours){
        ds <- table(subset(complaints_within_range, hour == input$click_hours)$type)
        pie_title <- paste("Noise complaint type ","(",input$click_hours,"h)",sep="")
      }
      else{
        ds <- table(complaints_within_range$type)
        pie_title <- "Noise complaint type (1h-24h)"
      }
      ds <- ds[complaint$type]
      ds[is.na(ds)] <- 0
      plot_ly(labels=complaint$type, values=ds, type = "pie",
              marker=list(colors=complaint$color)) %>%
        layout(title = pie_title,showlegend=F,
               xaxis=list(showgrid=F,zeroline=F,showline=F,autotick=T,ticks='',showticklabels=F),
               yaxis=list(showgrid=F,zeroline=F,showline=F,autotick=T,ticks='',showticklabels=F))
    })
    
  })

  ## show/hide complaint dots of specific group
  observeEvent(list(input$click_complaint_type, input$click_enable_hours, input$click_hours), {
    if(input$click_enable_hours){
      for(type in complaint$type){
        if(type %in% input$click_complaint_type) leafletProxy("map") %>% hideGroup(paste(type,1:24)) %>% showGroup(paste(type,input$click_hours))
        else{leafletProxy("map") %>% hideGroup(paste(type,1:24))}
      }
    }
    else{
      for(type in complaint$type){
        if(type %in% input$click_complaint_type) leafletProxy("map") %>% showGroup(paste(type,1:24))
        else{leafletProxy("map") %>% hideGroup(paste(type,1:24))}
      }
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
  
  ## complaints in diff hours
  observeEvent(input$click_enable_hours, {
    if(input$click_enable_hours){
      output$click_hours <-  renderUI({
        sliderInput("click_hours","Hours", min=1,max=24,value=1,step=1)
      })
      output$click_complaints_hour_text <- renderUI({
        p(strong(textOutput("click_complaints_hour", inline = T)))
      })
    }
    else{
      output$click_hours <-  renderUI({})
      output$click_complaints_hour_text <- renderUI({})
    }
  })

  ## clear all circles
  observeEvent(input$clear_circles, {
    leafletProxy('map') %>% clearGroup(c("circles","centroids",paste(complaint$type,rep(1:24,each=7))))
  })
  
  
  # 4.data tab
  output$table <- renderDataTable(noise311,
    options = list(pageLength = 10, lengthMenu = list(c(10)))
  )
})