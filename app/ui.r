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
          h1("Project: Open Data NYC - an RShiny app development project"),
          br(),
          h2("Background"),
          p("We know a lot of New Yorkers are as picky as we are, especially when it comes to renting/buying an apartment. New York City is such a big apple glazed with hustle and bustle, which not only gives you convenience of living but also annoys you with its side effects, such as noises, rodents, and bugs."),
          h2("Project summary"),
          p("This project explores and visualizes the noise level in New York City by integrating analyses of the 311 complaints data in 2015 on NYC Open Data Portal, the geographical data of construction sites, fire stations, hospitals, and clubs in NYC. We created a Shiny App to help users navigate through our findings in 3 main tabs: Statistics, Map, and Data."),
          br(),
          p("   - ",strong("Statistics"), ": presents 3 visualizations of the noise data, inlcuding an interactive time series plot, heatmap of the numbers of noise complaints in NYC, and donut chart of noise complaint types."),
          p("   - ",strong("Map"),": enables users to pinpoint any location in New York City, and algorithms will automatically calculate and output geographical information and summary statistics of surrounding noise complaints of that location. Users can also customize display settings, choose radiuses they want to explore, and compare multiple location results."),
          p("   - ",strong("Data"),": contains the original 311 noise complaint data we used to conduct analysis and write algorithms. It also enables searching and sorting functions."),
          h2("Outlook"),
          p("Our next step is to provide a more well-rounded picture of living conditions by incorporating data of rodents/pests sightings into our app."),
          p("Hope this app will help New Yorkers find their peaceful land!")
        ),
        # footer
        div(class="footer", "Applied Data Science")
      ),
      
      # 2.STAT TAB
      tabPanel("Statistics",
        h2("Summary Statistics"),
        
        wellPanel(style = "overflow-y:scroll; height: 850px; max-height: 750px; background-color: #ffffff;",
          tabsetPanel(type="tabs",
            tabPanel(title="1. Complaints by week",
                     br(),
                     div(plotlyOutput("stat_plot_ts"), align="center")
            ),
            tabPanel(title="2. Complaints by 24 hours",
                     br(),
                     div(img(src="img/stat_time_distribution.png", width=800), align="center")
            ),
            tabPanel(title="3. Complaints geographical distribution",
                     br(),
                     div(img(src="img/stat_plot_heatmap.png", width="90%"), align="center" )
            ),
            tabPanel(title="4. Type of Complaints",
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
                               choices = c("Construction","Fire Station","Hospital"),
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
        div(width = 12,
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

