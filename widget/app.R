suppressMessages(library(shiny))
suppressMessages(library(DT))


server <- function(input, output, session) {
  
  values <- reactiveValues(widget_state = "initializing",
                           current_run = NULL)

  # retrieve run object once widget_state
  observeEvent(values$widget_state == "streaming", {
    ws <- azuremlsdk::get_workspace(ws_name, subscription_id, rg)
    exp <- azuremlsdk::experiment(ws, exp_name)
    values$current_run <- azuremlsdk::get_run(exp, run_id)
  },
  ignoreInit = TRUE,
  once = TRUE)

  # stop app if user closes session
  session$onSessionEnded(function() {
    shiny::stopApp()
  })
  
  plot <- function() {
    if (!is.null(values$current_run)) {
      if (isolate(values$current_run$status) %in% 
          c("Failed", "Completed", "Canceled")) {
        print("Your run has reached a terminal state. The widget will close now.")
        Sys.sleep(3)
        shiny::stopApp()
      }

      run_details_plot <- azuremlsdk::view_run_details(values$current_run,
                                                       auto_refresh = FALSE)
    } else {
      # initialize auto-refresh 10 seconds after job submitted
      if (isolate(values$widget_state == "initializing") &&
          difftime(Sys.time(), start_time, units = "secs") > 10) {
        values$widget_state <- "streaming"
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
