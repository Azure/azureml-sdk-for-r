# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Create an Azure Machine Learning experiment
#' @description
#' An experiment is a grouping of many runs from a specified script.
#' @param workspace The `Workspace` object.
#' @param name A string of the experiment name. The name must be between
#' 3-36 characters, start with a letter or number, and can only contain
#' letters, numbers, underscores, and dashes.
#' @return The `Experiment` object.
#' @export
#' @examples
#' \dontrun{
#' ws <- load_workspace_from_config()
#' exp <- experiment(ws, name = 'myexperiment')
#' }
#' @seealso
#' `submit_experiment()`
#' @md
experiment <- function(workspace, name) {
  azureml$core$Experiment(workspace, name)
}

#' Submit an experiment and return the active created run
#' @description
#' `submit_experiment()` is an asynchronous call to Azure Machine Learning
#' service to execute a trial on local or remote compute. Depending on the
#' configuration, `submit_experiment()` will automatically prepare your
#' execution environments, execute your code, and capture your source code
#' and results in the experiment's run history.
#'
#' To submit an experiment you first need to create a configuration object
#' describing how the experiment is to be run. The configuration depends on
#' the type of trial required. For a script run, provide an `Estimator` object
#' to the `config` parameter. For a HyperDrive run for hyperparameter tuning,
#' provide a `HyperDriveConfig` to `config`.
#' @param experiment The `Experiment` object.
#' @param config The `Estimator` or `HyperDriveConfig` object.
#' @param tags A named list of tags for the submitted run, e.g.
#' `list("tag" = "value")`.
#' @return The `ScriptRun` or `HyperDriveRun` object.
#' @export
#' @examples
#' # This example submits an Estimator experiment
#' \dontrun{
#' ws <- load_workspace_from_config()
#' compute_target <- get_compute(ws, cluster_name = 'mycluster')
#' exp <- experiment(ws, name = 'myexperiment')
#' est <- estimator(source_directory = '.',
#'                  entry_script = 'train.R',
#'                  compute_target = compute_target)
#' run <- submit_experiment(exp, est)
#' }
#' @seealso
#' `estimator()`, `hyperdrive_config()`
#' @md
submit_experiment <- function(experiment, config, tags = NULL) {
  experiment$submit(config, tags = tags)
}

#' Return a generator of the runs for an experiment
#' @description
#' Return a generator of the runs for an experiment, in reverse
#' chronological order.
#' @param experiment The `Experiment` object.
#' @param type Filter the returned generator of runs by the provided type.
#' @param tags Filter runs by tags. A named list eg. list("tag" = "value").
#' @param properties Filter runs by properties. A named list
#' eg. list("property" = "value").
#' @param include_children By default, fetch only top-level runs.
#' Set to TRUE to list all runs.
#' @return The list of runs matching supplied filters.
#' @export
#' @md
get_runs_in_experiment <- function(experiment,
                                   type = NULL,
                                   tags = NULL,
                                   properties = NULL,
                                   include_children = FALSE) {
  experiment$get_runs(type = type,
                      tags = tags,
                      properties = properties,
                      include_children = include_children)
}

#' Create an interactive logging run
#' @description
#' Create an interactive run that allows the user to log
#' metrics and artifacts to a run locally.
#'
#' Any metrics that are logged during the interactive run session
#' are added to the run record in the experiment. If an output
#' directory is specified, the contents of that directory is
#' uploaded as run artifacts upon run completion.
#'
#' This method is useful if you would like to add experiment
#' tracking and artifact logging to the corresponding run record
#' in Azure ML for local runs without have to submit an experiment
#' run to a compute target with `submit_experiment()`.
#' @param experiment The `Experiment` object.
#' @param outputs (Optional) A string of the local path to an
#' outputs directory to track.
#' @param snapshot_directory (Optional) Directory to take snapshot of.
#' Setting to `NULL` will take no snapshot.
#' @return The `Run` object of the started run.
#' @export
#' @examples
#' \dontrun{
#' ws <- load_workspace_from_config()
#' exp <- experiment(ws, name = 'myexperiment')
#' run <- start_logging_run(exp)
#' log_metric_to_run("Accuracy", 0.9)
#' complete_run(run)
#' }
#' @seealso
#' `complete_run()`
#' @md
start_logging_run <- function(experiment,
                              outputs = NULL,
                              snapshot_directory = NULL) {
  experiment$start_logging(outputs = outputs,
                           snapshot_directory = snapshot_directory)
}
