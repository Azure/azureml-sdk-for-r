library(shiny)
library(DT)
library(htmltools)

server <- function(input, output){
  output$runDetails <- renderDataTable({
    invalidateLater(2000) # refresh every 2 seconds
    DT::datatable(run_details_plot,
                  escape = FALSE,
                  rownames = FALSE,
                  colnames = c(" ", " "),
                  caption = htmltools::tags$caption(
                    style = 'caption-side: top;
                             text-align: center;
                             font-size: 125%;
                             color:#3490D7;
                           ','Run Details'),
                  options = list(dom = 't',
                                 scrollY = '800px',
                                 pageLength = 1000)) %>% 
      formatStyle(columns = c("V1"), fontWeight = "bold")
  })
}

ui <- basicPage(
  h4(
    dataTableOutput("runDetails")
  ) 
)

shiny::runApp(shinyApp(ui, server), port = 1234)
