library(shiny)
#install.packages("shinydashboard", dependencies = T)
library(shinydashboard)
library(leaflet)

#newV <- read.csv(file = "newV.csv")


#add zipcode

zipcode_table <- read.csv("zipcode_corrdinate.csv")


dealers <- read.csv(file="Dealer.csv")


navbarPage("EcoCar",id="nav",
  tabPanel("About EcoCar"),
           
           
  tabPanel("Find your car",
           
           titlePanel("Finding a ideal car"),
           
           sidebarPanel(
             sliderInput(inputId = "maxBudget", label = h4("What is your max budget?"), 
                min = 15000, max=70000,
                value=20000),
             sliderInput(inputId = "fuelCost", label = h4("What is your max annual fuel cost?"), 
                min = 700, max=4350, value= 1000),
             checkboxGroupInput("ecoF", label = h4("How would you like your car to be eco-friendly?"), 
                       choices = list("Nature Lover" = 1, "Green Car" = 2, 
                                      "Kinda Green" = 3, "It's a Monster!" = 4),
                       selected = 1),
             sliderInput(inputId = "minCityMPG", label = h4("What is the min city mpg you want?"), 
                min = 9, max=58,
                value=34, step=1),
             sliderInput(inputId = "minHighayMPG", label = h3("What is the min highway mpg you want?"), 
                min = 11, max=59,
                value=34, step=1),
             sliderInput(inputId = "displ", label = h4("Minimun engine displacement?"), 
                min = 0.9, max=8.4,
                value=6.0),
             selectInput("cly", label = h4("Cylinders"), 
                         choices = list("3" = 3, "4" = 4, "5" = 5,"6" = 6,
                                        "8" = 8, "10" = 10, "12" = 12, "16" = 16), 
                         selected = 6),
             checkboxGroupInput("fuel", label = h4("Vehicles Fuel Type"),
                         choices = list("Diesel" = 1, "Midgrade Gasoline" = 2,
                                               "Premium Gasoline" = 3, "Regular Gasoline" = 4,
                                               selected = 4)),
                                
             checkboxGroupInput("drive", label = h4("Drive"), 
                                                   choices = list("4-wheel Drive" = 1, "All-wheel Drive" = 2, 
                                                                  "Front-wheel Drive" = 3, "Part-time 4-wheel Drive" = 4,
                                                                  "Rear-wheel Drive" = 5),
                                                   selected = 3),
             
             
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
      
      tabPanel("Dealer Map",
               leafletOutput("map")
                   )
                   )
               )
    )
)


