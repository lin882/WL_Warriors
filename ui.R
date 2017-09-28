library(shiny)

fluidPage(
  
  titlePanel("Finding a ideal car"),
  
  sidebarPanel(
    
    sliderInput(inputId = "maxBudget", label = "What is your max budget?", 
                min = 15000, max=70000,
                value=20000),
    sliderInput(inputId = "minCityMPG", label = "What is the min city mpg you want?", 
                min = 9, max=58,
                value=34, step=1),
    sliderInput(inputId = "minHighayMPG", label = "What is the min highway mpg you want?", 
                min = 11, max=59,
                value=34, step=1),
    sliderInput(inputId = "displ", label = "Minimun engine displayment?", 
                min = 0.9, max=8.4,
                value=6.0),
    sliderInput(inputId = "fuelCost", label = "What is your max annual fuel expenditure", 
                min = 700, max=4350, value= 1000)
    
  ),
  mainPanel(
    tableOutput("values")
  )
)
