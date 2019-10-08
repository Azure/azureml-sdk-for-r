# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Get the metrics for run
#' @param run Run object
#' @return named list containing metrics associated with the run.
#' @export
get_run_metrics <- function(run) {
  run$get_metrics()
}

#' Wait for the completion of this run
#' @param run Run object
#' @param show_output print verbose output to console
#' @export
wait_for_run_completion <- function(run, show_output = TRUE) {
  tryCatch({
    run$wait_for_completion(show_output)
  },
  error = function(e) {
    if (show_output && grepl("UnicodeEncode", e$message, )) {
      invisible(wait_until_run_completes(run))
    } else {
      stop(message(e))
    }
  })
}

wait_until_run_completes <- function(run) {
  # print dots if we get here due to unicode error on windows rstudio console
  # terminals
  while (run$get_status() %in% azureml$core$run$RUNNING_STATES) {
    cat(".")
    Sys.sleep(1)
  }
}

#' Gets the context object for a run
#' @param allow_offline Allow the service context to fall back to offline mode
#' so that the training script can be tested locally without submitting a job
#' with the SDK.
#' @return The run object.
#' @export
get_current_run <- function(allow_offline = TRUE) {
  azureml$core$run$Run$get_context(allow_offline)
}

#' Cancel run
#' @param run run to be cancelled
#' @return TRUE if cancellation was successful, else FALSE
#' @export
cancel_run <- function(run) {
  run$cancel()
}

#' Gets the Run object from a given run id
#' @param experiment The containing experiment.
#' @param run_id The run id for the run.
#' @return The run object.
#' @export
get_run <- function(experiment, run_id) {
  run <- azureml$core$run$Run(experiment, run_id)
  invisible(run)
}

#' Download an associated file from storage.
#' @param run the run object
#' @param name The name of the artifact to be downloaded
#' @param output_file_path The local path where to store the artifact
#' @export
download_file_from_run <- function(run, name, output_file_path = NULL) {
  run$download_file(name, output_file_path)
  invisible(NULL)
}

#' Download files from a given storage prefix (folder name) or
#' the entire container if prefix is unspecified.
#' @param run the run object
#' @param prefix the filepath prefix within the container from
#' which to download all artifacts
#' @param output_directory optional directory that all artifact paths use
#' as a prefix
#' @param output_paths optional filepaths in which to store the downloaded
#' artifacts. Should be unique and match length of paths.
#' @param batch_size number of files to download per batch
#' @export
download_files_from_run <- function(run, prefix = NULL, output_directory = NULL,
                                    output_paths = NULL, batch_size = 100L) {
  run$download_files(prefix = prefix,
                     output_directory = output_directory,
                     output_paths = output_paths,
                     batch_size = batch_size)
  invisible(NULL)
}

#' Get the definition, status information, current log files and other details
#' of the run.
#' @param run the run object
#' @return Return the details for the run
#' @export
get_run_details <- function(run) {
  run$get_details()
}

#' Return run status including log file content.
#' @param run the run object
#' @return Returns the status for the run with log file contents
#' @export
get_run_details_with_logs <- function(run) {
  run$get_details_with_logs()
}

#' List the files that are stored in association with the run.
#' @param run the run object
#' @return The list of paths for existing artifacts
#' @export
get_run_file_names <- function(run) {
  run$get_file_names()
}

#' Get the secret values for a given list of secret names.
#' Get a dictionary of found and not found secrets for the list of names
#' provided.
#' @param run the run object
#' @param secrets List of secret names to retrieve the values for
#' @return Returns a dictionary of found and not found secrets
#' @export
get_secrets_from_run <- function(run, secrets) {
  run$get_secrets(secrets)
}

#' Log metric to run
#' @param name name of the metric
#' @param value value of the metric
#' @param run Run object. If not specified, will default to current run from
#' service context.
#' @export
log_metric_to_run <- function(name, value, run = NULL) {
  if (is.null(run)) {
    run <- get_current_run()
  }
  run$log(name, value)
  run$flush()
  invisible(NULL)
}

#' Log a accuracy table to the artifact store.
#' @param name The name of the accuracy table
#' @param value json containing name, version, and data properties
#' @param description An optional metric description
#' @param run Run object. If not specified, will default to current run from
#' service context.
#' @export
log_accuracy_table_to_run <- function(name, value, description = "",
                                      run = NULL) {
  if (is.null(run)) {
    run <- get_current_run()
  }
  run$log_accuracy_table(name, value, description)
  run$flush()
  invisible(NULL)
}

#' Log a confusion matrix to the artifact store.
#' @param name The name of the confusion matrix
#' @param value json containing name, version, and data properties
#' @param description An optional metric description
#' @param run Run object. If not specified, will default to current run from
#' service context.
#' @export
log_confusion_matrix_to_run <- function(name, value, description = "",
                                        run = NULL) {
  if (is.null(run)) {
    run <- get_current_run()
  }
  run$log_confusion_matrix(name, value, description)
  run$flush()
  invisible(NULL)
}

#' Log an image metric to the run record.
#' @param name The name of metric
#' @param path The path or stream of the image
#' @param plot The plot to log as an image
#' @param description An optional metric description
#' @param run Run object. If not specified, will default to current run from
#' service context.
#' @export
log_image_to_run <- function(name, path = NULL, plot = NULL,
                             description = "", run = NULL) {
  if (is.null(run)) {
    run <- get_current_run()
  }
  run$log_image(name, path = path, plot = plot, description = description)
  run$flush()
  invisible(NULL)
}

#' Log a list metric value to the run with the given name.
#' @param name The name of metric
#' @param value The value of the metric
#' @param description An optional metric description
#' @param run Run object. If not specified, will default to current run from
#' service context.
#' @export
log_list_to_run <- function(name, value, description = "", run = NULL) {
  if (is.null(run)) {
    run <- get_current_run()
  }
  run$log_list(name, value, description)
  run$flush()
  invisible(NULL)
}

#' Log a predictions to the artifact store.
#' @param name The name of the predictions
#' @param value json containing name, version, and data properties
#' @param description An optional metric description
#' @param run Run object. If not specified, will default to current run from
#' service context.
#' @export
log_predictions_to_run <- function(name, value, description = "", run = NULL) {
  if (is.null(run)) {
    run <- get_current_run()
  }
  run$log_predictions(name, value, description)
  run$flush()
  invisible(NULL)
}

#' Log a residuals to the artifact store.
#' @param name The name of the predictions
#' @param value json containing name, version, and data properties
#' @param description An optional metric description
#' @param run Run object. If not specified, will default to current run from
#' service context.
#' @export
log_residuals_to_run <- function(name, value, description = "", run = NULL) {
  if (is.null(run)) {
    run <- get_current_run()
  }
  run$log_residuals(name, value, description)
  run$flush()
  invisible(NULL)
}

#' Log a row metric to the run with the given name.
#' @param name The name of metric
#' @param description An optional metric description
#' @param run Run object. If not specified, will default to current run from
#' service context.
#' @param ... Each named parameter generates a column with the value specified.
#' @export
log_row_to_run <- function(name, description = "", run = NULL, ...) {
  if (is.null(run)) {
    run <- get_current_run()
  }
  run$log_row(name, description = description, ...)
  run$flush()
  invisible(NULL)
}

#' Log a table metric to the run with the given name.
#' @param name The name of metric
#' @param value The table value of the metric (dictionary where keys are
#' columns to be posted to the service)
#' @param description An optional metric description
#' @param run Run object. If not specified, will default to current run from
#' service context.
#' @export
log_table_to_run <- function(name, value, description = "", run = NULL) {
  if (is.null(run)) {
    run <- get_current_run()
  }
  run$log_table(name, value, description)
  run$flush()
  invisible(NULL)
}

#' Plot table of run details in Viewer
#' @param run run used for plotting
#' @export
view_run_details <- function(run) {
  status <- run$get_status()
  details <- run$get_details()
  web_view_link <- paste0('<a href="', run$get_portal_url(), '">',
                          "Link", "</a>")

  if (status == "Completed" || status == "Failed") {
    diff <- (parsedate::parse_iso_8601(details$endTimeUtc) -
               parsedate::parse_iso_8601(details$startTimeUtc))
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
                           format = "%B %d %Y %H:%M:%S"),
                    duration,
                    details$runDefinition$target,
                    details$runDefinition$script,
                    toString(details$runDefinition$arguments),
                    web_view_link),
               nrow = 8,
               ncol = 2)

  DT::datatable(df, escape = FALSE, rownames = FALSE, colnames = c(" ", " "),
                caption = paste(unlist(details$warnings), collapse = "\r\n"),
                options = list(dom = "t", scrollY = TRUE))
}
