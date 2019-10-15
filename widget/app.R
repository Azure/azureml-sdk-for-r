library(shiny)
library(DT)
library(azureml)
library(parsedate)

server <- function(input, output){

  parsed_url <- strsplit(run_url, "/")[[1]]
  
  ws <- azureml$core$Workspace$get(name = parsed_url[12], 
                                   subscription_id = parsed_url[6],
                                   resource_group = parsed_url[8])
  exp <- azureml$core$Experiment(ws, parsed_url[14])
  run <- azureml$core$run$Run(exp, parsed_url[16])

  details <- run$get_details()
  web_view_link <- paste0('<a href="',
                          run$get_portal_url(), '">',
                          "here", "</a>")

  if (rstudio_server) {
    link_caption <- paste("Ctrl + click", web_view_link,
                           "to view run details in the Web Portal",
                           collapse = "\r\n")
  } else {
    link_caption <- paste("Click", web_view_link,
                           "to view run details in the Web Portal",
                           collapse = "\r\n")
  }

  output$runDetails <- renderDataTable({
    
    invalidateLater(2000)
    
    status <- run$get_status()

    if (status == "Queued") {
      start_time <- "-"
    }
    else {
      start_time <- format(parsedate::parse_iso_8601(details$startTimeUtc, ""),
                           format = "%B %d, %Y %I:%M:%S %p")
    }
    
    if (status == "Completed" || status == "Failed") {
      diff <- (parsedate::parse_iso_8601(details$endTimeUtc) -
               parsedate::parse_iso_8601(details$startTimeUtc))
      duration <- paste(round(as.numeric(diff), digits = 2), "mins")
    }
    else {
      duration <- "-"
    }

    df <- matrix(list("Run Id",
                      "Status",
                      "Start Time",
                      "Duration",
                      "Target",
                      "Script Name",
                      "Arguments",
                      "Web View",
                      run$id,
                      status,
                      start_time,
                      duration,
                      details$runDefinition$target,
                      details$runDefinition$script,
                      toString(details$runDefinition$arguments),
                      link_caption),
                 nrow = 8,
                 ncol = 2) 
    
    DT::datatable(df,
              escape = FALSE,
              rownames = FALSE,
              colnames = c(" ", " "),
              caption = "Run Details",
              options = list(dom = 't', scrollY = TRUE))
  })
}

ui <- basicPage(
  h4(
    dataTableOutput("runDetails")
  )
)

runApp(shinyApp(ui, server), port = 8000)