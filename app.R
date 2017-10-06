library(shiny)
library(leaflet)
library(shinythemes)
library(Rcpp)
library(RInside)
library(DT)

zipcode_table <- read.csv(file="data/zipcode_corrdinate.csv")


ui <- navbarPage(theme = shinytheme("united"),
                 "EcoCar",id="nav",
                 tabPanel(theme = shinytheme("superhero"),
                          "About EcoCar",
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
                            
                          ),
                          tags$head(
                            tags$style(paste0(
                              "body:before { ",
                              "  content: ''; ",
                              "  height: 100%; width: 100%; ",
                              "  position: fixed; ",
                              "  z-index: -1; ",
                              "  background: url(https://ppt.cc/fx3f2x) no-repeat center center fixed; ",
                              "  background-size: cover; ",
                              "  filter: opacity(30%); ",
                              "  -webkit-filter: opacity(30%); }")))
                 ),
                 
                 
                 
                 tabPanel(
                   "Find your car",
                   
                   titlePanel("Finding your ideal car"),
                   
                   sidebarPanel(
                     sliderInput(inputId = "maxBudget", label = h4("What is your max budget?"), 
                                 min = 15000, max=70000,
                                 value=60000),
                     sliderInput(inputId = "fuelCost", label = h4("What is your max annual fuel cost?"), 
                                 min = 700, max=4350, value= 4000),
                     sliderInput(inputId = "ecoF", label = h4("How would you like your car to be eco-friendly?(1 is the most eco friendly)"), 
                                 min = 1, max=3, value= 3),
                     sliderInput(inputId = "minCityMPG", label = h4("What is the min city mpg you want?"), 
                                 min = 9, max=58,
                                 value=12, step=1),
                     sliderInput(inputId = "minHighwayMPG", label = h4("What is the min highway mpg you want?"), 
                                 min = 11, max=59,
                                 value=12, step=1),
                     sliderInput(inputId = "displ", label = h4("Minimun engine displacement"), 
                                 min = 0.9, max=8.4,
                                 value=3.0),
                     numericInput("zipcode",label = h4("Input your Zipcode"), value = 47906)
                     
                   ),
                   mainPanel(
                     tabsetPanel(
                       id = 'dataset',
                       tabPanel("Model List",
                                h3("Top 10 Best Models for You"),
                                helpText('Here we are showing the top 10 vehicles for you. Make means the automaker, and Model means the model names.'), 
                                tableOutput("values"),
                                fluidRow(
                                  DT::dataTableOutput("Recom")
                                )
                                
                       ),
                       
                       tabPanel("Dealer on Map",
                                h3("Further informatoin of the recommended car"),
                                leafletOutput("map"),
                                fluidRow(
                                  column(8,
                                         verbatimTextOutput("text"))
                                  
                                )
                                
                       )
                     )
                   )
                 )
)






newVehicle = read.csv(file="data/newV.csv")


server <- function(input, output) {
  
  select <- reactive({
    
    summary <- newVehicle[newVehicle$Price < input$maxBudget,]
    summary <- summary[summary$fuelCost08 < input$fuelCost,]
    summary <- summary[summary$city08 > input$minCityMPG,]
    summary <- summary[summary$highway08 > input$minHighwayMPG,]
    summary <- summary[summary$displ > input$displ,]
    
    if (input$ecoF == 1){
      summary <- summary[summary$ecoFriendly == "Nature Lover",]
    } else if (input$ecoF == 2){
      summary <- summary[summary$ecoFriendly == "Nature Lover" |summary$ecoFriendly == "Green Car" |summary$ecoFriendly == "Kinda Green" ,]
    } else {
      summary <- summary
    }
    
    
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
    summary.final <-summary[order(summary$final_score, decreasing = TRUE),]
    
    
    
  })
  
  output$Recom <- DT::renderDataTable({
    
    Select_DT = as.data.frame(select())
    rownames(Select_DT) <- NULL
    DT::datatable(Select_DT[1:11,2:3])
  })
  
  
  output$map <- renderLeaflet({
    
    dealers <- read.csv(file="data/Dealer.csv")
    
    Recom_model <- as.character(select()$make[1])
    zipcode = input$zipcode
    
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
  
  output$text <- renderText({
    dealers <- read.csv(file="data/Dealer.csv")
    Recom_model <- as.character(select()$make[1])
    Dealer_con <- dealers[dealers$Make == Recom_model,][3]
    Select_DT = as.data.frame(select())
    
    
    paste0("The automaker for the best model is" ," ",Select_DT[1,2], "\n","Above information is the dealer information near your location")
    
    
    
  })
  
  
}

shinyApp(ui = ui, server = server)
