library(shiny)
library(leaflet)

shinyServer(function(input, output) {
  mark_opt <- markerOptions(,opacity=0.8,riseOnHover=T)
  output$map <- renderLeaflet({
    m <- leaflet() %>% addProviderTiles(input$map_color) %>% setView(-73.983,40.7639,zoom = 13)
    m <- m %>% 
      addMarkers(-73.9625,40.80754,popup="Columbia University",options=mark_opt) %>%
      addMarkers(-73.996182,40.7295825,popup="New York University",options=mark_opt)
    m
  })
})