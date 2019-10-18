library(shiny)
library(DT)
library(azureml)
library(here)
library(utils)


path <- here::here("R/run.R")
source(path)

runDetailsWidget <- shinyApp(
  server = function(input, output){
    
    parsed_url <- strsplit(run_url, "/")[[1]]
    
    ws <- azureml$core$Workspace$get(name = parsed_url[12], 
                                     subscription_id = parsed_url[6],
                                     resource_group = parsed_url[8])
    exp <- azureml$core$Experiment(ws, parsed_url[14])
    run <- azureml$core$run$Run(exp, parsed_url[16])
    
    output$runDetails <- renderDataTable({
      invalidateLater(1000)
      create_run_details_plot(run, rstudio_server)
    })
  },
  ui = basicPage(
    h4(
      dataTableOutput("runDetails")
    )
  )
)

runGadget(runDetailsWidget)
