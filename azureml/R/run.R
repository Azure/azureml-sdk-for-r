#' Get the metrics for run
#' @param run Run object
#' @return named list containing metrics associated with the run.
#' @export
get_run_metrics <- function(run)
{
  run$get_metrics()
}

#' Wait for the completion of this run
#' @param run run object
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
  while (run$get_status() %in% aml$core$run$RUNNING_STATES)
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
  aml$core$run$Run$get_context(allow_offline)
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