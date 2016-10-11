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
          p(strong("-  "),a(em("311 Complaint data 2015"),href="https://data.cityofnewyork.us/Social-Services/311-Service-Requests-2015/hemm-82xw")),
          p(strong("-  "),a(em("somedata")),href=""),
          p(strong("-  "),a(em("somedata")),href=""),
          p(strong("-  "),a(em("somedata")),href="")
        ),
        # footer
        div(class="footer", "Applied Data Science")
      ),
      
      # 2.STAT TAB
      tabPanel("Statistics",
        h2("Summary Statistics"),
        
        wellPanel(style = "overflow-y:scroll; max-height: 750px; background-color: #ffffff;",
          tabsetPanel(type="tabs",
            tabPanel(title="1. NYC Weekly mean number of noise complaints",
                     br(),
                     div(plotlyOutput("stat_plot_ts"), align="center")
            ),
            tabPanel(title="2. NYC number of noise complaints heatmap",
                     br(),
                     div(img(src="img/stat_plot_heatmap.png", width="90%"), align="center" )
            ),
            tabPanel(title="3. Type of Complaints",
                     br(),
                     div(htmlOutput("stat_plot_doughnut"), align="center")
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
            top = 120, left = 20, right = "auto", bottom = "auto", width = 250, height = "auto",
            h3("Controls"),
            selectInput("map_color", "Map Color Theme", choices=c("Black & White"="Stamen.TonerLite", "Colored"="Hydda.Full")),
            checkboxGroupInput("enable_markers", "Add Markers for:",
                               choices = c("Construction","Fire Station","Hospital","Club"),
                               selected = c("Construction","Fire Station","Hospital")),
            sliderInput("click_radius", "Radius of selected area (meters)", min=100, max=1000, value=100, step=5),
            checkboxInput("click_show_address", "Show address of area centroid",value = T),
            checkboxInput("click_multi", "Compare among multiple locations",value = F),
            actionButton("clear_circles", "Clear all circles")
          ),

          # output panel
          absolutePanel(id = "controls", class = "panel panel-default", fixed= TRUE, draggable = TRUE,
            top = 120, left = "auto", right = 20, bottom = "auto", width = 320, height = "auto",
            h3("Outputs"),
            h4("Center Coordinate"),
            p(textOutput("click_coord")),
            h4("Center Address"),
            p(textOutput("click_address")),
            h4("Number of noise complaints"),
            p(strong(textOutput("click_complaints_total", inline = T)), " in total (year 2015)."),
            p(strong(textOutput("click_complaints_per_day", inline = T)), " per day."),
            p(strong("Noise level"), "(Number of complaints per day per 100m radius area):", strong(textOutput("click_complaints_per_day_area", inline = T))),
            h4("Noise Complaint Type"),
            plotlyOutput("click_complaint_pie",height="300")
          ),
          absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE, draggable = TRUE,
                        top=120, left=270, right='auto', bottom="auto", width=200, height="auto",
                        checkboxGroupInput("click_complaint_type", "Show complaint type",
                                           choices = complaint$type, selected = complaint$type),
                        actionButton("click_all_complaint_types", "Select ALL"),
                        actionButton("click_none_complaint_types", "Select NONE")
          ),
          # color bar panel
          absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE, draggable = TRUE,
                        top = 340, left = "auto", right = 340, bottom = "auto", width = 100, height = "auto",
                        h4("NOISE LEVEL colorbar"),
                        div(img(src="img/colorbar.png"), style="opacity: 0.65")
          )
          
        )
      ),
      
      # 4.DATA TAB
      tabPanel("Data",
        mainPanel(
          h1("311 Complaint Data (2015)"), # title for data tab
          br(),
          dataTableOutput('table')
        ),
        # footer
        div(class="footer", "Applied Data Science")
      )
      

    )
  )
)

