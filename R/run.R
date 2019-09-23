# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Get the metrics for run
#' @param run Run object
#' @return named list containing metrics associated with the run.
#' @export
get_run_metrics <- function(run)
{
  run$get_metrics()
}

#' Wait for the completion of this run
#' @param run Run object
#' @param show_output print verbose output to console
#' @export
wait_for_run_completion <- function(run, show_output = TRUE)
{
  tryCatch(
  {
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
#' @param run Run object
#' @export
log_metric_to_run <- function(name, value, run)
{
  run$log(name, value)
  run$flush()
}

#' Cancel run
#' @param run run to be cancelled
#' @return TRUE if cancellation was successful, else FALSE
#' @export
cancel_run <- function(run)
{
  run$cancel()
}

#' Plot table of run details in Viewer
#' @param run run used for plotting
#' @export
view_run_details <- function(run) {
  status <- run$get_status()
  details <- run$get_details()
  web_view_link <- paste0('<a href="', run$get_portal_url(),'">',
                          "Link", "</a>")

  if (status == "Completed" || status == "Failed"){
    diff <- (parse_iso_8601(details$endTimeUtc) - 
             parse_iso_8601(details$startTimeUtc))
    duration <- paste(as.numeric(diff), "mins")
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
                    format(parsedate::parse_iso_8601(details$startTimeUtc),
                           format='%B %d %Y %H:%M:%S'),
                    duration,
                    details$runDefinition$target,
                    details$runDefinition$script,
                    toString(details$runDefinition$arguments),
                    web_view_link),
               nrow = 8,
               ncol = 2) 

  DT::datatable(df, escape=FALSE, rownames=FALSE, colnames=c(" ", " "),
                caption = paste(unlist(details$warnings), collapse='\r\n'),
                options = list(dom = 't', scrollY = TRUE))
}