suppressMessages(library(DT))
suppressMessages(library(shiny))


server <- function(input, output, session){
  # rehydrate run
  ws <- azuremlsdk::get_workspace(ws_name, subscription_id, rg)
  exp <- azuremlsdk::experiment(ws, exp_name)
  run <- azuremlsdk::get_run(exp, run_id)

  plot <- reactive({
    invalidateLater(10000)

    # update plot table if changed
    if (!identical(details, azuremlsdk::get_run_details(run))) {
      details <- azuremlsdk::get_run_details(run)
      
      if (run_details_plot$x$data$V2[[3]] == "-" &&
          !is.null(details$startTimeUtc)) {
        start_date_time <- as.POSIXct(details$startTimeUtc,
                                      "%Y-%m-%dT%H:%M:%S",
                                      tz = "UTC")
        run_details_plot$x$data$V2[[3]] <<- format(start_date_time,
                                                   "%B %d, %Y %I:%M %p",
                                                   tz = Sys.timezone(),
                                                   use_tz = TRUE)
      }
      
      # update duration
      if (details$status %in% c("Failed", "Completed", "Canceled")) {
        start_date_time <- as.POSIXct(details$startTimeUtc,
                                      "%Y-%m-%dT%H:%M:%S",
                                      tz = "UTC")
        end_date_time <- as.POSIXct(details$endTimeUtc,
                                    "%Y-%m-%dT%H:%M:%S",
                                    tz = "UTC")
        run_details_plot$x$data$V2[[4]] <<- 
          paste(round(as.numeric(difftime(end_date_time,
                                          start_date_time,
                                          units = "mins")),
                      digits = 2), "mins")
      }
      
      # update run status
      run_details_plot$x$data$V2[[2]] <<- details$status
      
      # show error info if failed run
      if (details$status == "Failed" &&
          !("Errors" %in% run_details_plot$x$data$V1)) {
        error <- details$error$error$message
        
        if (is.null(error)) {
          error <- "Detailed error not set on the Run. Please check
                        the logs for details."
        }
        run_details_plot$x$data <<- rbind(run_details_plot$x$data,
                                          data.frame(V1 = "Errors",
                                                     V2 = error))
      }
    }
    
    return(run_details_plot)
  })
  

  output$runDetailsPlot <- renderDataTable({
    plot()
  })
}

ui <- fluidPage(
  shinycssloaders::withSpinner(dataTableOutput("runDetailsPlot"),
              type = 1,
              color="#487EDB")
)

shiny::runApp(shinyApp(ui, server), port = 1234)