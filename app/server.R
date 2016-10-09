library(shiny)
library(leaflet)
library(data.table)
library(ggmap)
library(plotly)


shinyServer(function(input, output) {
  # 3.map tab
  ## Base map + test markers
  marker_opt <- markerOptions(opacity=0.8,riseOnHover=T)
  test_markers_School <- data.frame(name=c("Columbia University","New York University"), lng=c(-73.9625,-73.996182), lat=c(40.80754,40.7295825))
  test_markers_Hospital <- data.frame(name=c("Mt Sinai St. Luke's"),lng=c(-73.9612585),lat=c(40.8056236))
  
  output$map <- renderLeaflet({
    m <- leaflet() %>%  addProviderTiles("Stamen.TonerLite") %>% setView(-73.983,40.7639,zoom = 13) # default map, base layer
    
    leafletProxy("map", data = test_markers_School) %>%
      addMarkers(~lng,~lat,popup=~name,group="base_School",options=marker_opt)
    leafletProxy("map", data = test_markers_Hospital) %>%
      addMarkers(~lng,~lat,popup=~name,group="base_Hospital",options=marker_opt,icon=list(iconUrl='icon/hospital.png',iconSize=c(40,40)))
    
    m
  })

  ## change map color theme
  observeEvent(input$map_color, {
    leafletProxy("map") %>% addProviderTiles(input$map_color)
  })
  
  ## enable/disable markers of specific group
  observeEvent(input$enable_markers, {
    # Schools
    if("School" %in% input$enable_markers) leafletProxy("map") %>% showGroup("base_School")
    else{leafletProxy("map") %>% hideGroup("base_School")}
    # Hospitals
    if("Hospital" %in% input$enable_markers) leafletProxy("map") %>% showGroup("base_Hospital")
    else{leafletProxy("map") %>% hideGroup("base_Hospital")}
  })
  
  ## show circle around a clicked point, along with popups
  observeEvent(input$map_click, {
    # remove previous circles
    if(!input$click_multi) leafletProxy('map') %>% clearGroup("circles") %>% clearGroup("centroids")
    # Get the click info
    click <- input$map_click
    clat <- click$lat
    clng <- click$lng
    address <- NULL
    if(input$click_show_address){
      address <- revgeocode(c(clng,clat))
    }

    # output panel info
    ## text info
    output$click_coord <- renderText(paste("Lat:",round(clat,6),", Long:",round(clng,6)))
    output$click_address <- renderText(address)
    ## calculated noise info
    noise <- "some calculated output of noise level here, e.g. avg/total num of complaints"
    output$click_noise <- renderText(noise)
    ## Complaint type pie chart
    output$click_complaint_pie <- renderPlotly({
      # an example
      ds <- data.frame(labels = c("A", "B", "C"),values = c(runif(1)*10, runif(1)*10, runif(1)*10))
      plot_ly(labels=ds$labels, values=ds$values, type = "pie") %>%
        layout(title = "Example, randomly generated")
    })
    
    
    ### Comment Down below are from Stackoverflow. AG ###
    ## Add the circle to the map proxy
    ## so you dont need to re-render the whole thing
    ## I also give the circles a group, "circles", so you can
    ## then do something like hide all the circles with hideGroup('circles')
    
    # draw circles
    leafletProxy('map') %>%
      addCircles(lng=clng, lat=clat, group='circles',
                 stroke=F, radius=input$click_radius, fillColor='red',
                 popup=address, fillOpacity=0.5, opacity=0.9) %>%
      addCircles(lng=clng, lat=clat, group='centroids', radius=1, weight=2, color='black',opacity=1,fillColor='black',fillOpacity=1)
  })
  
  ## hide/show centroid point
  observeEvent(input$click_show_centroid, {
    if(!input$click_show_centroid) leafletProxy('map') %>% hideGroup("centroids")
    else{ leafletProxy('map') %>% showGroup("centroids")}
  })
  
  ## clear all circles
  observeEvent(input$clear_circles, {
    leafletProxy('map') %>% clearGroup("circles") %>% clearGroup("centroids")
  })
  
  
  # 4.data tab
  output$table <- renderDataTable(iris,
    options = list(pageLength = 10)
  )
})