library(shiny)
#install.packages("shinydashboard", dependencies = T)
library(shinydashboard)

setwd("C:\\Purdue University\\2017 Fall\\Using R for Analytics\\ProjectCar\\test4")
zipcode_table <- read.csv(file="zipcode_corrdinate.csv")


ui <- navbarPage("EcoCar",id="nav",
                 tabPanel("About EcoCar",
                          br(),
                          fluidRow(
                            column(4,
                                   h3("Want to buy a new car? EcoCar can help!"),
                                   p("Each person is different, and EcoCar celebrates that!"),
                                   br(),
                                   p("We will find the perfect car for you within your budget, car preferences and a new feature called Eco-Friendly!"),
                                   br(),
                                   p("Try to adapt your choices to more eco-friendly car, but if that's not your thing, we get it! We are here to help!"),
                                   br(),
                                   p("We will show not only the best maker and model for you, but where to find the closest dealer to buy it!"),
                                   br(),
                                   p("Thank you for trusting EcoCar!"))
                            
                          )
                 ),
                 
                 
                 tabPanel("Find your car",
                          
                          titlePanel("Finding a ideal car"),
                          
                          sidebarPanel(
                            sliderInput(inputId = "maxBudget", label = "What is your max budget?", 
                                        min = 15000, max=70000,
                                        value=20000),
                            sliderInput(inputId = "fuelCost", label = "What is your max annual fuel expenditure", 
                                        min = 700, max=4350, value= 1000),
                            checkboxGroupInput("ecoF", label = h3("How would you like your car to be eco-friendly?"), 
                                               choices = list("Natural Lover" = 1, "Green Car" = 2, "Kinda Green" = 3, "It's a monster" = 4),
                                               selected = 1),
                            sliderInput(inputId = "minCityMPG", label = "What is the min city mpg you want?", 
                                        min = 9, max=58,
                                        value=34, step=1),
                            sliderInput(inputId = "minHighwayMPG", label = "What is the min highway mpg you want?", 
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
                              
                              tabPanel("Dealer map",
                                       leafletOutput("map")
                              )
                            )
                          )
                 )
)






server <- function(input, output) {
  
  
  
  sliderValues <- reactive({
    data.frame(
      Name = c("MaxBudget",
               "minCitympg"),
      Value = as.character(c(input$maxBudget,
                             input$minCityMPG
                             )),
      stringsAsFactors = FALSE
    )
  })
  output$values <- renderTable({
    sliderValues()
  })
  
  
  
  
  output$map <- renderLeaflet({
    
    newVehicle <- read.csv(file="newV.csv")
    
    summary <- newVehicle[newVehicle$Price < input$maxBudget,]
    summary <- summary[summary$fuelCost08 < input$fuelCost,]
    summary <- summary[summary$city08 > input$minCityMPG,]
    summary <- summary[summary$highway08 > input$minHighwayMPG,]
    summary <- summary[summary$displ > input$displ,]
    
    
    
    ## Normalization
    mean_price <- mean(summary$Price)
    summary$normal_Price <- ((input$maxBudget - summary$Price) / mean_price)
    
    mean_fuel <- mean(summary$fuelCost08)
    summary$normal_fuel <- ((input$fuelCost - summary$fuelCost08) / mean_fuel)
    
    mean_cityMPG <- mean(summary$city08)
    summary$normal_cityMPG <- ((summary$city08 - input$minCityMPG) / mean_cityMPG)
    
    mean_highwayMPG <- mean(summary$highway08)
    summary$normal_highwayMPG <- ((summary$highway08 - input$minHighwayMPG) / mean_highwayMPG)
    
    summary$final_score <- summary$normal_Price**2 + summary$normal_fuel**2 + summary$normal_cityMPG**2 + summary$normal_highwayMPG**2
    summary <-summary[order(summary$final_score, decreasing = TRUE),]
    
    dealers <- read.csv(file="Dealer.csv")
    
    Recom_model <- summary$make[1]
    zipcode = 47906
    
    Dealer_zip <- dealers[dealers$Make == Recom_model,]
    Dealer_lat <- zipcode_table[zipcode_table$zip == Dealer_zip$Zipcode,][2]
    Dealer_lon <- zipcode_table[zipcode_table$zip == Dealer_zip$Zipcode,][3]
    Dealer_con <- dealers[dealers$Make == Recom_model,][3]
    
    
    latitude <- zipcode_table[zipcode_table$zip == zipcode,][2]
    longtitude <- zipcode_table[zipcode_table$zip == zipcode,][3]
    
    
    lat <- latitude$Latitude
    
    lon <- longtitude$Longitude
    
    leaflet() %>%
      addTiles() %>%
      setView(lon, lat, zoom = 10)%>%
      addPopups(lat = Dealer_lat$Latitude, lng = Dealer_lon$Longitude, Dealer_con$Content,
                options = popupOptions(closeButton = FALSE))
  })
}

shinyApp(ui = ui, server = server)
