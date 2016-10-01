library(shiny)
library(leaflet)
library(shinydashboard)


shinyUI(

  div(id="canvas",
  
    # mabye we'll use a shinydashboard page, it looks better but really, it's nothing special and everybody uses it.
    navbarPage(strong("TITLE",style="color: white;"), theme="styles.css",
      # 1.INTRO TAB
      tabPanel("Intro",
        mainPanel(width=12,
          h1("TITLE"),
          h2("Introduction"),
          p("This is a small shiny app that illustrate the", strong("noise and pest"), "problem in NYC."),
          p("It aims to help those who are picky about where they would buy or rent an apartment."),
          h2("Data Source"),
          p(em("some url"))
        ),
        # footer
        div(class="footer", "Applied Data Science")
      ),
      
      # 2.STAT TAB
      tabPanel("Statistics",
        h2("Summary Statistics"),
        dashboardBody(
          # Boxes need to be put in a row (or column)
          fluidRow(
            column("Controls", width=4, height=250,
                dateRangeInput("date_range","Time Period",start="2015-01-01",end="2015-12-31",min="2015-01-01",max="2015-12-31")
            ),
            column("some plot", width=8,
              plotOutput("plot1")
            )
  
          )
        ),
        # footer
        div(class="footer", "Applied Data Science")
      ),
      
      # 3.MAP TAB
      tabPanel("Map",
        div(class="outer",
          # lealfet map
          leafletOutput("map", width="100%", height="100%"),
          
          # control panel
          absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE, draggable = TRUE,
            top = 140, left = 30, right = "auto", bottom = "auto", width = 300, height = "auto",
            h2("blabla"),
            selectInput("map_color", "Map Color Theme", choices=c("Black & White"="Stamen.TonerLite", "Colored"="Hydda.Full"))
          )
        )
      ),
      
      # 4.DATA TAB
      tabPanel("Data",
         # footer
         div(class="footer", "Applied Data Science")
      )
      
                     
      
  
    )
  )
)

