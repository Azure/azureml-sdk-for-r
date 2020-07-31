# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Get the metrics logged to a run
#' @description
#' Retrieve the metrics logged to a run that were logged with
#' the `log_*()` methods.
#' @param run The `Run` object.
#' @param name The name of the metric.
#' @param recursive If specified, returns runs matching specified *"property"* or {*"property"*: *"value"*}.
#' @param run_type run type
#' @param populate Boolean indicating whether to fetch the contents of external data linked to the metric.
#' @return A named list of the metrics associated with the run,
#' e.g. `list("metric_name" = metric)`.
#' @export
#' @section Examples:
#' ```
#' ws <- load_workspace_from_config()
#' exp <- experiment(ws, name = 'myexperiment')
#' run <- get_run(exp, run_id = "myrunid")
#' metrics <- get_run_metrics(run)
#' ```
#' @md
get_run_metrics <- function(run,
                            name = NULL,
                            recursive = FALSE,
                            run_type = NULL,
                            populate = FALSE) {
    run$get_metrics(name, recursive, run_type, populate)
}

#' Wait for the completion of a run
#' @description
#' Wait for the run to reach a terminal state. Typically called
#' after submitting an experiment run with `submit_experiment()`.
#' @param run The `Run` object.
#' @param show_output If `TRUE`, print verbose output to console.
#' @return None
#' @export
#' @seealso [submit_experiment()]
#' @md
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

#' Get the context object for a run
#' @description
#' This function is commonly used to retrieve the authenticated
#' run object inside of a script to be submitted for execution
#' via `submit_experiment()`. Note that the logging functions
#' (`log_*` methods, `upload_files_to_run()`, `upload_folder_to_run()`)
#' will by default log the specified metrics or files to the
#' run returned from `get_current_run()`.
#' @param allow_offline If `TRUE`, allow the service context to
#' fall back to offline mode so that the training script can be
#' tested locally without submitting a job with the SDK.
#' @return The `Run` object.
#' @export
#' @md
get_current_run <- function(allow_offline = TRUE) {
  azureml$core$run$Run$get_context(allow_offline)
}

#' Cancel a run
#' @description
#' Cancel an ongoing run.
#' @param run The `Run` object.
#' @return `TRUE` if cancellation was successful, else `FALSE`.
#' @export
#' @md
cancel_run <- function(run) {
  run$cancel()
}

#' Get an experiment run
#' @description
#' Given the associated experiment and run ID, return the
#' run object for a previously submitted/tracked run.
#' @param experiment The `Experiment` object.
#' @param run_id A string of the run ID for the run.
#' @return The `Run` object.
#' @export
#' @md
get_run <- function(experiment, run_id) {
  run <- azureml$core$run$Run(experiment, run_id)
  invisible(run)
}

#' Download a file from a run
#' @description
#' Download a file from the run record. You can download any file that
#' was uploaded to the run record via `upload_files_to_run()` or
#' `upload_folder_to_run()`, or any file that was written out to
#' the `./outputs` or `./logs` folders during a run.
#'
#' You can see what files are available to download from the run record
#' by calling `get_run_file_names()`.
#' @param run The `Run` object.
#' @param name A string of the name of the artifact to be downloaded.
#' @param output_file_path A string of the local path where to download
#' the artifact to.
#' @return None
#' @export
#' @seealso [download_files_from_run()]
#' @md
download_file_from_run <- function(run, name, output_file_path = NULL) {
  run$download_file(name, output_file_path)
  invisible(NULL)
}

#' Download files from a run
#' @description
#' Download files from the run record. You can download any files that
#' were uploaded to the run record via `upload_files_to_run()` or
#' `upload_folder_to_run()`, or any files that were written out to
#' the `./outputs` or `./logs` folders during a run.
#' @param run The `Run` object.
#' @param prefix A string of the the filepath prefix (folder name) from
#' which to download all artifacts. If not specified, all the artifacts
#' in the run record will be downloaded.
#' @param output_directory (Optional) A string of the directory that all
#' artifact paths use as a prefix.
#' @param output_paths (Optional) A list of strings of the local filepaths
#' where the artifacts will be downloaded to.
#' @param batch_size An int of the number of files to download per batch.
#' @return None
#' @export
#' @seealso [download_file_from_run()]
#' @md
download_files_from_run <- function(run, prefix = NULL, output_directory = NULL,
                                    output_paths = NULL, batch_size = 100L) {
  run$download_files(prefix = prefix,
                     output_directory = output_directory,
                     output_paths = output_paths,
                     batch_size = batch_size)
  invisible(NULL)
}

#' Get the details of a run
#' @description
#' Get the definition, status information, current log files, and
#' other details of the run.
#' @param run The `Run` object.
#' @return A named list of the details for the run.
#' @export
#' @details
#' The returned list contains the following named elements:
#' * *runId*: ID of the run.
#' * *target*: The compute target of the run.
#' * *status*: The run's current status.
#' * *startTimeUtc*: UTC time of when the run was started, in ISO8601.
#' * *endTimeUtc*: UTC time of when the run was finished (either
#' Completed or Failed), in ISO8601. This element does not exist if
#' the run is still in progress.
#' * *properties*: Immutable key-value pairs associated with the run.
#' * *logFiles*: Log files from the run.
#' @seealso [get_run_details_with_logs()]
#' @md
get_run_details <- function(run) {
  run$get_details()
}

#' Get the details of a run along with the log files' contents
#' @param run The `Run` object.
#' @return A named list of the run details and log file contents.
#' @export
#' @seealso [get_run_details()]
#' @md
get_run_details_with_logs <- function(run) {
  run$get_details_with_logs()
}

#' List the files that are stored in association with a run
#' @description
#' Get the list of files stored in a run record.
#' @param run The `Run` object.
#' @return A list of strings of the paths for existing artifacts
#' in the run record.
#' @export
#' @seealso [download_file_from_run()] [download_files_from_run()]
#' @md
get_run_file_names <- function(run) {
  run$get_file_names()
}

#' Get secrets from the keyvault associated with a run's workspace
#'
#' @description
#' From within the script of a run submitted using
#' `submit_experiment()`, you can use `get_secrets_from_run()`
#' to get secrets that are stored in the keyvault of the associated
#' workspace.
#'
#' Note that this method is slightly different than `get_secrets()`,
#' which first requires you to instantiate the workspace object.
#' Since a submitted run is aware of its workspace,
#' `get_secrets_from_run()` shortcuts workspace instantiation and
#' returns the secret value directly.
#'
#' Be careful not to expose the secret(s) values by writing or
#' printing them out.
#' @param run The `Run` object.
#' @param secrets A vector of strings of secret names to retrieve
#' the values for.
#' @return A named list of found and not found secrets.
#' If a secret was not found, the corresponding element will be `NULL`.
#' @export
#' @seealso [set_secrets()]
#' @md
get_secrets_from_run <- function(run, secrets) {
  run$get_secrets(secrets)
}

#' Log a metric to a run
#' @description
#' Log a numerical or string value with the given metric name
#' to the run. Logging a metric to a run causes that metric to
#' be stored in the run record in the experiment. You can log
#' the same metric multiple times within a run, the result being
#' considered a vector of that metric.
#' @param name A string of the name of the metric.
#' @param value The value of the metric.
#' @param run The `Run` object. If not specified, will default
#' to the current run from the service context.
#' @return None
#' @export
#' @section Examples:
#' ```
#' log_metric_to_run("Accuracy", 0.95)
#' ```
#' @md
log_metric_to_run <- function(name, value, run = NULL) {
  if (is.null(run)) {
    run <- get_current_run()
  }
  run$log(name, value)
  run$flush()
  invisible(NULL)
}

#' Log an accuracy table metric to a run
#' @description
#' The accuracy table metric is a multi-use non-scalar metric that can be
#' used to produce multiple types of line charts that vary continuously
#' over the space of predicted probabilities. Examples of these charts are
#' ROC, precision-recall, and lift curves.
#' @param name A string of the name of the metric.
#' @param value A named list containing name, version, and data properties.
#' @param description (Optional) A string of the metric description.
#' @param run The `Run` object. If not specified, will default
#' to the current run from the service context.
#' @return None
#' @export
#' @details
#' The calculation of the accuracy table is similar to the calculation of
#' an ROC curve. An ROC curve stores true positive rates and false positive
#' rates at many different probability thresholds. The accuracy table stores
#' the raw number of true positives, false positives, true negatives, and
#' false negatives at many probability thresholds.
#'
#' There are two methods used for selecting thresholds: "probability" and
#' "percentile." They differ in how they sample from the space of predicted
#' probabilities.
#'
#' Probability thresholds are uniformly spaced thresholds between 0 and 1.
#' If NUM_POINTS were 5 the probability thresholds would be
#' c(0.0, 0.25, 0.5, 0.75, 1.0).
#'
#' Percentile thresholds are spaced according to the distribution of predicted
#' probabilities. Each threshold corresponds to the percentile of the data at
#' a probability threshold. For example, if NUM_POINTS were 5, then the first
#' threshold would be at the 0th percentile, the second at the 25th percentile,
#' the third at the 50th, and so on.
#'
#' The probability tables and percentile tables are both 3D lists where the
#' first dimension represents the class label, the second dimension represents
#' the sample at one threshold (scales with NUM_POINTS), and the third dimension
#' always has 4 values: TP, FP, TN, FN, and always in that order.
#'
#' The confusion values (TP, FP, TN, FN) are computed with the one vs. rest
#' strategy. See the following link for more details:
#' https://en.wikipedia.org/wiki/Multiclass_classification.
#'
#' N = # of samples in validation dataset (200 in example),
#' M = # thresholds = # samples taken from the probability space (5 in example),
#' C = # classes in full dataset (3 in example)
#'
#' Some invariants of the accuracy table:
#' * TP + FP + TN + FN = N for all thresholds for all classes
#' * TP + FN is the same at all thresholds for any class
#' * TN + FP is the same at all thresholds for any class
#' * Probability tables and percentile tables have shape (C, M, 4)
#'
#' Note: M can be any value and controls the resolution of the charts.
#' This is independent of the dataset, is defined when calculating metrics,
#' and trades off storage space, computation time, and resolution.
#'
#' Class labels should be strings, confusion values should be integers,
#' and thresholds should be doubles.
#' @md
log_accuracy_table_to_run <- function(name, value, description = "",
                                      run = NULL) {
  if (is.null(run)) {
    run <- get_current_run()
  }
  run$log_accuracy_table(name, value, description)
  run$flush()
  invisible(NULL)
}

#' Log a confusion matrix metric to a run
#' @param name A string of the name of the metric.
#' @param value A named list containing name, version, and data properties.
#' @param description (Optional) A string of the metric description.
#' @param run The `Run` object. If not specified, will default
#' to the current run from the service context.
#' @return None
#' @export
#' @md
log_confusion_matrix_to_run <- function(name, value, description = "",
                                        run = NULL) {
  if (is.null(run)) {
    run <- get_current_run()
  }
  run$log_confusion_matrix(name, value, description)
  run$flush()
  invisible(NULL)
}

#' Log an image metric to a run
#' @description
#' Log an image to the run with the give metric name. Use
#' `log_image_to_run()` to log an image file or ggplot2 plot to the
#' run. These images will be visible and comparable in the run
#' record.
#' @param name A string of the name of the metric.
#' @param path A string of the path or stream of the image.
#' @param plot The ggplot2 plot to log as an image.
#' @param description (Optional) A string of the metric description.
#' @param run The `Run` object. If not specified, will default
#' to the current run from the service context.
#' @return None
#' @export
#' @md
log_image_to_run <- function(name, path = NULL, plot = NULL,
                             description = "", run = NULL) {
  if (!is.null(path) && !is.null(plot)) {
    stop(paste0("Invalid parameters, path and plot were both provided,",
                " only one at a time is supported"))
  }

  delete_path <- FALSE
  if (is.null(run)) {
    run <- get_current_run()
  }
  if (!is.null(plot)) {
    path <- paste0(name, "_", as.integer(Sys.time()), ".png")
    ggplot2::ggsave(filename = path, plot = plot)
    plot <- NULL
    delete_path <- TRUE
  }
  run$log_image(name, path = path, plot = plot, description = description)
  if (delete_path) {
    unlink(path)
  }
  run$flush()
  invisible(NULL)
}

#' Log a vector metric value to a run
#' @description
#' Log a vector with the given metric name to the run.
#' @param name A string of the name of metric.
#' @param value The vector of elements to log.
#' @param description (Optional) A string of the metric description.
#' @param run The `Run` object. If not specified, will default
#' to the current run from the service context.
#' @return None
#' @export
#' @section Examples:
#' ```
#' log_list_to_run("Accuracies", c(0.6, 0.7, 0.87))
#' ```
#' @md
log_list_to_run <- function(name, value, description = "", run = NULL) {
  if (is.null(run)) {
    run <- get_current_run()
  }
  run$log_list(name, value, description)
  run$flush()
  invisible(NULL)
}

#' Log a predictions metric to a run
#' @description
#' `log_predictions_to_run()` logs a metric score that can be used to
#' compare the distributions of true target values to the distribution
#' of predicted values for a regression task.
#'
#' The predictions are binned and standard deviations are calculated
#' for error bars on a line chart.
#' @param name A string of the name of the metric.
#' @param value A named list containing name, version, and data properties.
#' @param description (Optional) A string of the metric description.
#' @param run The `Run` object. If not specified, will default
#' to the current run from the service context.
#' @return None
#' @export
#' @section Examples:
#' ```
#' data <- list("bin_averages" = c(0.25, 0.75),
#'              "bin_errors" = c(0.013, 0.042),
#'              "bin_counts" = c(56, 34),
#'              "bin_edges" = c(0.0, 0.5, 1.0))
#' predictions <- list("schema_type" = "predictions",
#'                     "schema_version" = "v1",
#'                     "data" = data)
#' log_predictions_to_run("mypredictions", predictions)
#' ```
#' @md
log_predictions_to_run <- function(name, value, description = "", run = NULL) {
  if (is.null(run)) {
    run <- get_current_run()
  }
  run$log_predictions(name, value, description)
  run$flush()
  invisible(NULL)
}

#' Log a residuals metric to a run
#' @description
#' `log_residuals_to_run()` logs the data needed to display a histogram
#' of residuals for a regression task. The residuals are `predicted - actual`.
#'
#' There should be one more edge than the number of counts.
#' @param name A string of the name of the metric.
#' @param value A named list containing name, version, and data properties.
#' @param description (Optional) A string of the metric description.
#' @param run The `Run` object. If not specified, will default
#' to the current run from the service context.
#' @return None
#' @export
#' @section Examples:
#' ```
#' data <- list("bin_edges" = c(50, 100, 200, 300, 350),
#'              "bin_counts" = c(0.88, 20, 30, 50.99))
#' residuals <- list("schema_type" = "residuals",
#'                     "schema_version" = "v1",
#'                     "data" = data)
#' log_predictions_to_run("myresiduals", predictions)
#' ```
#' @md
log_residuals_to_run <- function(name, value, description = "", run = NULL) {
  if (is.null(run)) {
    run <- get_current_run()
  }
  run$log_residuals(name, value, description)
  run$flush()
  invisible(NULL)
}

#' Log a row metric to a run
#' @description
#' Using `log_row_to_run()` creates a metric with multiple columns
#' as described in `...`. Each named parameter generates a column
#' with the value specified. `log_row_to_run()` can be called once
#' to log an arbitrary tuple, or multiple times in a loop to generate
#' a complete table.
#' @param name A string of the name of metric.
#' @param description (Optional) A string of the metric description.
#' @param run The `Run` object. If not specified, will default
#' to the current run from the service context.
#' @param ... Each named parameter generates a column with the value
#' specified.
#' @return None
#' @export
#' @section Examples:
#' Log an arbitrary tuple:
#' ```
#' log_row_to_run("Y over X", x = 1, y = 0.4)
#' ```
#'
#' Log the complete table:
#' ```
#' citrus <- c("orange", "lemon", "lime")
#' sizes <- c(10, 7, 3)
#' for (i in seq_along(citrus)) {
#'     log_row_to_run("citrus", fruit = citrus[i], size = sizes[i])
#' }
#' ```
#' @md
log_row_to_run <- function(name, description = "", run = NULL, ...) {
  if (is.null(run)) {
    run <- get_current_run()
  }
  run$log_row(name, description = description, ...)
  run$flush()
  invisible(NULL)
}

#' Log a table metric to a run
#' @description
#' Log a table metric with the given metric name to the run. The
#' table value is a named list where each element corresponds to
#' a column of the table.
#' @param name A string of the name of metric.
#' @param value The table value of the metric (a named list where the
#' element name corresponds to the column name).
#' @param description (Optional) A string of the metric description.
#' @param run The `Run` object. If not specified, will default
#' to the current run from the service context.
#' @return None
#' @export
#' @section Examples:
#' ```
#' log_table_to_run("Y over X",
#'                  list("x" = c(1, 2, 3), "y" = c(0.6, 0.7, 0.89)))
#' ```
#' @md
log_table_to_run <- function(name, value, description = "", run = NULL) {
  if (is.null(run)) {
    run <- get_current_run()
  }
  run$log_table(name, value, description)
  run$flush()
  invisible(NULL)
}

#' Generate table of run details
#'
#' @description
#' Plot a table of run details including
#'  * ID
#'  * Status
#'  * Start Time
#'  * Duration
#'  * Script Name
#'  * Arguments
#'  * Link to Web Portal view
#'  * Errors
#'
#' @param run The `Run` object.
#' @return Datatable containing run details
#' @export
#' @md
plot_run_details <- function(run) {
  handle_null <- function(arg, placeholder = "-") {
    if (is.list(arg) && !length(arg) || arg == "" || is.null(arg)) {
      placeholder
    } else {
      arg
    }
  }

  web_portal_link <- paste0('<a href="',
                            run$get_portal_url(),
                            '" target="_blank">Link</a>')

  details <- run$get_details()

  # get general run properties
  script_name <- handle_null(details$runDefinition$script)
  arguments <- handle_null(toString(details$runDefinition$arguments))
  start_time <- "-"
  duration <- "-"

  # get run time details
  if (handle_null(details$startTimeUtc) != "-") {
    start_date_time <- as.POSIXct(details$startTimeUtc, "%Y-%m-%dT%H:%M:%S",
                                  tz = "UTC")
    start_time <- format(start_date_time, "%B %d, %Y %I:%M %p",
                         tz = Sys.timezone(),
                         use_tz = TRUE)

    if (handle_null(details$endTimeUtc) != "-") {
      end_date_time <- as.POSIXct(details$endTimeUtc, "%Y-%m-%dT%H:%M:%S",
                                  tz = "UTC")
      duration <- paste(round(as.numeric(difftime(end_date_time,
                                                  start_date_time,
                                                  units = "mins")),
                              digits = 2), "mins")
    }
  }

  df_keys <- list("Run Id",
                  "Status",
                  "Start Time",
                  "Duration",
                  "Script Name",
                  "Arguments",
                  "Web View")
  df_values <- list(run$id,
                    run$get_status(),
                    start_time,
                    duration,
                    script_name,
                    arguments,
                    web_portal_link)

  # add warnings and errors if applicable
  if (handle_null(details$warnings) != "-") {
    df_keys <- c(df_keys, paste(unlist(details$warnings), collapse = "\r\n"))
    df_values <- c(df_values, "Warnings")
  }

  if (run$status == "Failed") {
    error <- details$error$error$message
    error <- handle_null(error,
                         "Detailed error not set on the Run. Please check
                         the logs for details.")
    df_keys <- c(df_keys, "Errors")
    df_values <- c(df_values, error)
  }

  run_details_plot <- matrix(c(df_keys, df_values),
                             nrow = length(df_keys),
                             ncol = 2)

  dt <- DT::datatable(run_details_plot,
                      escape = FALSE,
                      rownames = FALSE,
                      colnames = c(" ", " "),
                      caption = htmltools::tags$caption(
                        style = "caption-side: top;
                        text-align: center;
                        font-size: 125%",
                        "Run Details"),
                      options = list(dom = "t",
                                     scrollY = "800px",
                                     pageLength = 1000))
  DT::formatStyle(dt, columns = c("V1"), fontWeight = "bold")
}

#' Initialize run details widget
#' @description
#' Initializes a ShinyApp in RStudio Viewer (or the default browser if Viewer
#' is unavailable) showing details of the submitted run. If using RStudio, the
#' plot will auto-update with information collected from the server. For more
#' details about the run, click the web view link. The widget will stop running
#' once the run has reached a terminal state: "Failed", "Completed", or
#' "Canceled".
#'
#' If you are running this method from an RMarkdown file, the
#' run details table will show up in the code chunk output
#' instead of the Viewer.
#' @param run Run object
#' @param auto_refresh Boolean indicating whether or not widget should update
#' run details automatically. The default is TRUE when using RStudio.
#' @md
view_run_details <- function(run, auto_refresh = TRUE) {
  .Deprecated()
  if (rstudioapi::isAvailable() &&
      auto_refresh) {

    # select random available registered port
    port <- servr::random_port(NULL)

    # import objects needed for Shiny app
    widget_obj_names <- list("subscription_id",
                             "rg",
                             "ws_name",
                             "exp_name",
                             "run_id",
                             "run_details_plot",
                             "port",
                             "shiny",
                             "shinycssloaders",
                             "start_time")
    widget_obj_vals <- list(run$experiment$workspace$subscription_id,
                            run$experiment$workspace$resource_group,
                            run$experiment$workspace$name,
                            run$experiment$name,
                            run$id,
                            plot_run_details(run),
                            port,
                            shinycssloaders::withSpinner,
                            shiny::shinyOptions,
                            Sys.time())

    .envir <- as.environment(1)

    lapply(seq_along(widget_obj_names),
           function(x) {
             assign(widget_obj_names[[x]],
                    widget_obj_vals[[x]],
                    envir = .envir)
           }
    )

    # stop and remove any existing widget job before submitting script
    # nolint start
    existing_job_id <- Sys.getenv("AZUREML_RSTUDIO_WIDGET_JOB")

    if (existing_job_id != "") {
      try(rstudioapi::jobSetState(existing_job_id, "succeeded"),
          silent = TRUE)
      try(rstudioapi::jobRemove(existing_job_id), silent = TRUE)
    }

    path <- system.file("widget", "app.R", package = "azuremlsdk")
    current_job_id <- rstudioapi::jobRunScript(path,
                                               name = "AzureML Widget",
                                               importEnv = TRUE)
    Sys.setenv(AZUREML_RSTUDIO_WIDGET_JOB = current_job_id)
    # nolint end

    # check if using notebook vm/CI and assign host
    info_file_path <- "~/../../mnt/azmnt/.nbvm"
    if (file.exists(info_file_path)) {
      info_file <- readLines(info_file_path, warn = FALSE)
      if (length(info_file) == 3) { # NBVM files containe blank first line
        instance_name <- gsub("instance=", "", info_file[2])
        domain_suffix <- gsub("domainsuffix=", "", info_file[3])
      }
      if (length(info_file) == 2) { # CI files are 2 lines
        instance_name <- gsub("instance=", "", info_file[1])
        domain_suffix <- gsub("domainsuffix=", "", info_file[2])
      }

      host <- paste0("https://", instance_name, "-", port, ".", domain_suffix)
      Sys.sleep(1) # server requires longer to connect to host
    } else {
      host <- paste0("http://localhost:", port)
    }

    # initialize viewer pane or browser
    viewer <- getOption("viewer")
    if (!is.null(viewer)) {
      viewer(host)
    } else {
      utils::browseURL(host)
    }
  } else {
    plot_run_details(run)
  }
}

#' Upload files to a run
#' @description
#' Upload files to the run record.
#'
#' Note: Runs automatically capture files in the specified output
#' directory, which defaults to "./outputs". Use `upload_files_to_run()`
#' only when additional files need to be uploaded or an output directory
#' is not specified.
#' @param names A character vector of the names of the files to upload.
#' @param paths A character vector of relative local paths to the files
#' to be upload.
#' @param timeout_seconds An int of the timeout in seconds for uploading
#' the files.
#' @param run The `Run` object.
#' @return None
#' @export
#' @section Examples:
#' ```
#' ws <- load_workspace_from_config()
#' exp <- experiment(ws, name = 'myexperiment')
#'
#' # Start an interactive logging run
#' run <- start_logging_run(exp)
#'
#' # Upload files to the run record
#' filename1 <- "important_file_1"
#' filename2 <- "important_file_2"
#' upload_files_to_run(names = c(filename1, filename2),
#'                     paths = c("path/on/disk/file_1.txt", "other/path/on/disk/file_2.txt"))
#'
#' # Download a file from the run record
#' download_file_from_run(filename1, "file_1.txt")
#' ```
#' @seealso [upload_folder_to_run()] [download_file_from_run()] [download_files_from_run()]
#' @md
upload_files_to_run <- function(names, paths, timeout_seconds = NULL,
                                run = NULL) {
  if (is.null(run)) {
    run <- get_current_run()
  }

  run$upload_files(
    names = names,
    paths = paths,
    timeout_seconds = timeout_seconds)

  invisible(NULL)
}

#' Upload a folder to a run
#' @description
#' Upload the specified folder to the given prefix name to the run
#' record.
#'
#' Note: Runs automatically capture files in the specified output
#' directory, which defaults to "./outputs". Use `upload_folder_to_run()`
#' only when additional files need to be uploaded or an output directory
#' is not specified.
#' @param name A string of the name of the folder of files to upload.
#' @param path A string of the relative local path to the folder to upload.
#' @param run The `Run` object.
#' @return None
#' @export
#' @section Examples:
#' ```
#' ws <- load_workspace_from_config()
#' exp <- experiment(ws, name = 'myexperiment')
#'
#' # Start an interactive logging run
#' run <- start_logging_run(exp)
#'
#' # Upload folder to the run record
#' upload_folder_to_run(name = "important_files",
#'                      path = "path/on/disk")
#'
#' # Download a file from the run record
#' download_file_from_run("important_files/existing_file.txt", "local_file.txt")
#' ```
#' @seealso [upload_files_to_run()] [download_file_from_run()] [download_files_from_run()]
#' @md
upload_folder_to_run <- function(name, path, run = NULL) {
  if (is.null(run)) {
    run <- get_current_run()
  }

  run$upload_folder(name, path)

  invisible(NULL)
}

#' Mark a run as completed.
#' @description
#' Mark the run as completed. Use for an interactive logging run.
#' @param run The `Run` object.
#' @return None
#' @export
#' @seealso [start_logging_run()]
#' @md
complete_run <- function(run) {
  run$complete()

  invisible(NULL)
}

#' Create a child run
#'
#' @description
#' Create a child run. This is used to isolate part of a run into a subsection.
#' @param parent_run The parent `Run` object.
#' @param name An optional name for the child run, typically specified for a "part"
#' @param run_id An optional run ID for the child, otherwise it is auto-generated.
#' Typically this parameter is not set.
#' @param outputs Optional outputs directory to track for the child.
#' @return The child run, a `Run` object.
#' @export
#' @md
create_child_run <- function(parent_run,
                             name = NULL,
                             run_id = NULL,
                             outputs = NULL) {
  parent_run$child_run(name, run_id, outputs)
}

#' Create one or many child runs
#'
#' @description
#' Create one or many child runs.
#' @param parent_run The parent `Run` object.
#' @param count An optional number of children to create.
#' @param tag_key An optional key to populate the Tags entry in all created children.
#' @param tag_values An optional list of values that will map onto Tags for the list of runs created.
#' @return The list of child runs, `Run` objects.
#' @export
#' @md
create_child_runs <- function(parent_run,
                              count = NULL,
                              tag_key = NULL,
                              tag_values = NULL) {
  parent_run$create_children(count, tag_key, tag_values)
}

#' Submit an experiment and return the active child run
#'
#' @description
#' Submit an experiment and return the active child run.
#' @param parent_run The parent `Run` object.
#' @param config The `RunConfig` object
#' @param tags Tags to be added to the submitted run, e.g., {"tag": "value"}.
#' @return A `Run` object.
#' @md
submit_child_run <- function(parent_run,
                             config = NULL,
                             tags = NULL) {
  parent_run$submit_child(config, tags)
}

#' Get all children for the current run selected by specified filters
#'
#' @description
#' Get all children for the current run selected by specified filters.
#' @param parent_run The parent `Run` object.
#' @param recursive Boolean indicating whether to recurse through all descendants.
#' @param tags If specified, returns runs matching specified "tag" or list(tag = value).
#' @param properties If specified, returns runs matching specified "property" or list(property = value).
#' @param type If specified, returns runs matching this type.
#' @param status If specified, returns runs with status specified "status".
#' @return A list of child runs, `Run` objects.
#' @export
#' @md
get_child_runs <- function(parent_run,
                           recursive = FALSE,
                           tags = NULL,
                           properties = NULL,
                           type = NULL,
                           status = NULL) {
  reticulate::iterate(parent_run$get_children(recursive,
                                              tags,
                                              properties,
                                              type,
                                              status))
}
