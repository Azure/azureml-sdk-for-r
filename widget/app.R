suppressWarnings(library(shiny))
suppressMessages(library(DT))


server <- function(input, output, session){

  observe({
    invalidateLater(5000, session)

    # update values if auto-refresh activated
    if (input$checkbox == TRUE) {
      ws <- azureml::get_workspace(ws_name, subscription_id, rg)
      exp <- azuremlsdk::experiment(ws, exp_name)
      run <- azuremlsdk::get_run(exp, run_id)
      details <- azuremlsdk::get_run_details(run)

      if (run_details_plot$x$data$V2[[3]] == "-") {
        # update start time
        if (!is.null(details$startTimeUtc)) {
          start_date_time <- as.POSIXct(details$startTimeUtc,
                                        "%Y-%m-%dT%H:%M:%S",
                                        tz = "UTC")
          run_details_plot$x$data$V2[[3]] <<- format(start_date_time,
                                                     "%B %d, %Y %I:%M %p",
                                                     tz = Sys.timezone(),
                                                     use_tz = TRUE)
        }
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
      
      if (details$status == "Failed") {
        error <- details$error$error$message
        
        if (is.null(error)) {
          error <- "Detailed error not set on the Run. Please check
                    the logs for details."
        }
        run_details_plot <<- rbind(data.frame("Errors", error),
                                   run_details_plot)
      }
    }
  })

  output$runDetailsPlot <- renderDataTable({
    invalidateLater(2000)
    run_details_plot
  })
}

ui <- fluidPage(

  fluidRow(
    column(3, checkboxInput("checkbox", "Turn on auto-refresh", value = FALSE))
  ),
  h4(
    dataTableOutput("runDetailsPlot")
  )
)

suppressMessages(shiny::runApp(shinyApp(ui, server), port = 1234))