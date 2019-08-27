#' Get the metrics for run
#' @param run Run object
#' @return named list containing metrics associated with the run.
#' @export
get_run_metrics <- function(run)
{
  run$get_metrics()
}

#' Show run status in viewer pane
#' @param run Run object
#' @export
show_run_status <- function(run) {
  viewer <- getOption("viewer")
  if (!is.null(viewer))
  {
    library(DT)

    details = run$get_details()

    web_view_link = paste0('<a href="',run$get_portal_url(),'">', "Link" ,"</a>")
    df <- data.frame(names = c("Run Id",
                               "Status",
                               "Start Time",
                               "Target",
                               "Script Name",
                               "Arguments",
                               "Web View"),
                     values = c(run$id,
                                run$status,
                                toString(Sys.time()), #TODO: use details$startTimeUtc,
                                details$runDefinition$target,
                                details$runDefinition$script,
                                toString(details$runDefinition$arguments),
                                web_view_link))

    datatable(df,
              escape = FALSE,
              rownames = FALSE,
              caption = paste(unlist(details$warnings), collapse='\r\n'),
              options = list(dom = 't'))
  }
}

#' Wait for the completion of this run
#' @param run run object
#' @param show_output print verbose output to console
#' @export
wait_for_run_completion <- function(run, show_output = TRUE)
{
  tryCatch(
  {
    show_run_status(run)
    run$wait_for_completion(show_output)
  },
  error = function(e) {
    if (show_output && grepl("UnicodeEncode", e$message, ))
    {
      invisible(wait_until_run_completes(run))
    }
    else
    {
      stop(message(e))
    }
  })
}

wait_until_run_completes <- function(run)
{
  # print dots if we get here due to unicode error on windows rstudio console terminals
  while (run$get_status() %in% azureml$core$run$RUNNING_STATES)
  {
    cat(".")
    Sys.sleep(1)
  }
}

#' Gets the context object for a run
#' @param allow_offline Allow the service context to fall back to offline mode so that the training script
#' can be tested locally without submitting a job with the SDK.
#' @return get current run
#' @export
get_current_run <- function(allow_offline=TRUE)
{
  azureml$core$run$Run$get_context(allow_offline)
}

#' Log metric to run
#' @param name name of the metric
#' @param value value of the metric
#' @param run run object
#' @export
log_metric_to_run <- function(name, value, run)
{
  run$log(name, value)
  run$flush()
}

