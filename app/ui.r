library(shiny)
library(leaflet)
library(data.table)
library(plotly)


shinyUI(

  div(id="canvas",
  
    # mabye we'll use a shinydashboard page, it looks better but really, it's nothing special and everybody uses it.
    navbarPage(strong("Noises Around You",style="color: white;"), theme="styles.css",
      # 1.INTRO TAB
      tabPanel("Intro",
        mainPanel(width=12,
          h1("Project: Open Data NYC"),
          br(),
          h2("Introduction"),
          p("This is a small shiny app that illustrate the", strong("noise"), "problem in NYC."),
          p("It aims to help those who are picky about where they would buy or rent an apartment by providing noise information in a selected area."),
          h2("Data Source"),
          p(strong("-  "),a(em("311 Complaint data 2015"),href="https://data.cityofnewyork.us/dataset/311-Service-Requests-From-2015/57g5-etyj")),
          p(strong("-  "),a(em("somedata")),href="")
        ),
        # footer
        div(class="footer", "Applied Data Science")
      ),
      
      # 2.STAT TAB
      tabPanel("Statistics",
        h2("Summary Statistics"),
        br(),

        # Boxes need to be put in a row (or column)
        fluidRow(
          column("Controls", width=4, height=250,
            dateRangeInput("stats_date_range","Time Period",start="2015-01-01",end="2015-12-31",min="2015-01-01",max="2015-12-31"),
            sliderInput("stats_hours","Hours",min=strptime("00:00:00","%H:%M:%S"),max=strptime("23:59:59","%H:%M:%S"),strptime("00:00:00","%H:%M:%S"),timeFormat="%T",
                        animate=animationOptions(interval=500,playButton="Play"))
          ),
          column("some plot", width=8,
            plotOutput("stats_plot1")
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
            top = 150, left = 30, right = "auto", bottom = "auto", width = 250, height = "auto",
            h2("Controls"),
            selectInput("map_color", "Map Color Theme", choices=c("Black & White"="Stamen.TonerLite", "Colored"="Hydda.Full")),
            checkboxGroupInput("enable_markers", "Add Markers for:",
                               choices = c("School","Hospital","Contruction","Club","Pub","Subway"),
                               selected = c("School","Hospital")),
            sliderInput("click_radius", "Radius of selected area (meters)", min=100, max=500, value=100, step=5),
            checkboxInput("click_show_address", "Show address of area centroid",value = T),
            checkboxInput("click_show_centroid", "Show centroid point",value = T),
            checkboxInput("click_multi", "Compare among multiple locations",value = F),
            actionButton("clear_circles", "Clear all circles")
          ),
          # output panel
          absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE, draggable = TRUE,
            top = "auto", left = "auto", right = 40, bottom = 60, width = 320, height = "auto",
            h2("Outputs"),
            h3("Center Coordinate"),
            p(textOutput("click_coord")),
            h3("Center Address"),
            p(textOutput("click_address")),
            h3("Noise Level"),
            p(textOutput("click_noise")),
            h3("Noise Complaint Type"),
            plotlyOutput("click_complaint_pie",height="320px")

          )
        )
      ),
      
      # 4.DATA TAB
      tabPanel("Data",
        mainPanel(
          h1("Data"), # title for data tab
          br(),
          column(12,
            dataTableOutput('table')
          )
        ),
        # footer
        div(class="footer", "Applied Data Science")
      )
      

    )
  )
)

