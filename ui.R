

fluidPage(
  
  useShinyjs(),
    tags$style(HTML(".sum-km {
                    color: #1DACE8;
                    font-weight: bold;
                    font-size: 15px;}
                    
                    .stress {
                    color: #EDCB64;
                    font-weight: bold;
                    font-size: 15px;}
                    
                    ")),

    # Application title
    titlePanel("Strava Health"),
    

    
    #type = "tabs", 
    
    tabsetPanel(id = "tabs",

                tabPanel("Upload",
                         div(style = "margin-top:40px"),
                         
                         p("Please upload an .rds file with the combined
                           mental health, sleep and strava data."),
                         div(style = "margin-top:30px"),
                         
                         
                         fileInput("upload", "Upload a file"),
                ),
                
 #### Intro ####
                tabPanel("Intro",
                         div(style = "margin-top:40px"),
                         
                         column(6, align="center",
                                
                                p("Please select a given week, to display the different
                                  aggregated values for mental health, sports and sleep
                                  data", style = "text-align:left;"),
                                
                                div(style = "margin-top:40px"),
                                
                                selectInput("week_select","Select Week",unique(date(assessment$monday))),
                                plotlyOutput('group_score', width = "300px", height = "300")
                         ),

                         column(6, align="left",
                                p("Please select the desired amount of kilometers,
                                  you would like to run in a week, combined 
                                  with the expected quality of sleep."),
                                
                                div(style = "margin-top:40px"),
                                
                         p("Km ran in a week: ",
                           style = "font-weight: bold;"),
                         numericInput("distance_input", "", 60, min = 1, max = 100,
                                      width = '80px'),
                         div(style = "margin-top:40px"),
                        
                         p("Quality of Sleep: ",
                           style = "font-weight: bold;"),
                         sliderInput("sleep_input",
                                     label = div(style='width:300px;', 
                                                 div(style='float:left;', 'Terrible'),
                                                 div(style='float:right;', 'Excellent')), 
                                     ticks = F,
                                     min = 60, max = 98, value = 87, width = '300px'),
                         p("The week after, you might feel: ",
                           style = "font-weight: bold;"),
                         span(uiOutput("howamI"))
                                )
                

                ),
                


#### Overview ####
tabPanel("Overview",
         div(style = "margin-top:40px"),

fluidRow(
  
  column(2,
         div(class = "sum-km",
             p("In total you ran: "),
         textOutput("km_year"))
         ),
  column(2,
         div(class = "stress",
             p("You felt this stressed: "),
             textOutput("stress"))
  ),
  column(2,
         div(class = "stress",
             p("You felt this energetic: "),
             textOutput("energy"))
  ),
  column(2,
         div(class = "stress",
             p("You felt like this the most: "),
             textOutput("feeling"))
  )
  )),

#### Self Assessment ####
tabPanel("Self Assessment vs Distance", 
         div(style = "margin-top:40px"),

fluidRow(style = "height:200px;",
  column(4, plotlyOutput('stress_plot', width = "450px", height = "300px")),
  column(4, plotlyOutput('energy_plot', width = "450px", height = "300px")),
  column(4, plotlyOutput('feeling_plot', width = "450px", height = "300px"))
),

fluidRow(
         div(style = "margin-top:150px"),
         # Plotly Week Distance
         column(6,plotlyOutput('week_dist', height = "300px")),
         column(6,plotlyOutput('sleep_score', height = "300px"))
        )
      )
  )
)


