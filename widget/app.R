suppressMessages(library(shiny))
suppressMessages(library(DT))


server <- function(input, output, session) {
  
  values <- reactiveValues(INITIALIZED = FALSE,
                           curr_run = NULL,
                           RUN_TERMINATED = FALSE)

  # retrieve run object once initialized
  observeEvent((values$INITIALIZED), {
    ws <- azuremlsdk::get_workspace(ws_name, subscription_id, rg)
    exp <- azuremlsdk::experiment(ws, exp_name)
    values$curr_run <- azuremlsdk::get_run(exp, run_id)
  },
  ignoreInit = TRUE,
  once = TRUE)

  # stop app when run reaches terminal state
  observeEvent((values$RUN_TERMINATED), {
    shiny::stopApp()
  },
  ignoreInit = TRUE)

  # stop app if user closes session
  session$onSessionEnded(function() {
    shiny::stopApp()
  })

  plot <- function() {
    if (!is.null(values$curr_run)) {
      if (isolate(values$curr_run$status) %in% c("Failed", "Completed", "Canceled")) {
        print("Your run has reached a terminal state. The widget will close now.")
        isolate(values$RUN_TERMINATED <- TRUE)
      }

      run_details_plot <- azuremlsdk::view_run_details(values$curr_run,
                                                       auto_refresh = FALSE)
    } else {
      # initialize auto-refresh 10 seconds after job submitted
      if (isolate(!values$INITIALIZED) &&
          difftime(Sys.time(), start_time, units = "secs") > 10) {
        isolate(values$INITIALIZED <- TRUE)
      }      
    }

    return(run_details_plot)
  }
  
  output$runDetailsPlot <- DT::renderDataTable({
    invalidateLater(10000, session)
    plot()
  })
}

ui <- fluidPage(
  shinycssloaders::withSpinner(DT::dataTableOutput("runDetailsPlot"),
                               5,
                               color = "#4287f5",
                               size = 0.5)
)

suppressMessages(shiny::runApp(shinyApp(ui, server), port = port))
