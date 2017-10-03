library(shiny)
#install.packages("shinydashboard", dependencies = T)
library(shinydashboard)


navbarPage("EcoCar",id="nav",
  tabPanel("About EcoCar"),
           
           
  tabPanel("Find your car",
           
           titlePanel("Finding a ideal car"),
           
           sidebarPanel(
             sliderInput(inputId = "maxBudget", label = "What is your max budget?", 
                min = 15000, max=70000,
                value=20000),
             sliderInput(inputId = "fuelCost", label = "What is your max annual fuel expenditure", 
                min = 700, max=4350, value= 1000),
             checkboxGroupInput("ecoF", label = h3("How would you like your car to be eco-friendly?"), 
                       choices = list("Nature lover" = 1, "Not concern" = 2, "Not at all" = 3),
                       selected = 1),
             sliderInput(inputId = "minCityMPG", label = "What is the min city mpg you want?", 
                min = 9, max=58,
                value=34, step=1),
             sliderInput(inputId = "minHighayMPG", label = "What is the min highway mpg you want?", 
                min = 11, max=59,
                value=34, step=1),
             sliderInput(inputId = "displ", label = "Minimun engine displacement?", 
                min = 0.9, max=8.4,
                value=6.0),
             selectInput("cly", label = h3("Cylinders"), 
                         choices = list("3" = 3, "4" = 4, "5" = 5,"6" = 6,
                                        "8" = 8, "10" = 10, "12" = 12, "16" = 16), 
                         selected = 6),
             tags$head(
               tags$style(paste0(
                 "body:before { ",
                 "  content: ''; ",
                 "  height: 100%; width: 100%; ",
                 "  position: fixed; ",
                 "  z-index: -1; ",
                 "  background: url(https://ppt.cc/fx3f2x) no-repeat center center fixed; ",
                 "  background-size: cover; ",
                 "  filter: grayscale(50%); ",
                 "  -webkit-filter: grayscale(50%); }")))
             ),
  mainPanel(
    tabsetPanel(
      tabPanel("Model list",
               h4("Recommendation"),
               dashboardBody(
                 box(tableOutput("values"))
               )
               ),
      
      tabPanel("Dealer map"
               )
      )
    )
)
)