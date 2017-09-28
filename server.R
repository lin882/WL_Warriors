library(shiny)

function(input, output) {
  sliderValues <- reactive({
    data.frame(
      Name = c("MaxBudget",
               "minCitympg"),
      Value = as.character(c(input$maxBudget,
                             input$minCityMPG)),
      stringsAsFactors = FALSE
    )
  })
  output$values <- renderTable({
    sliderValues()
  })
}
  