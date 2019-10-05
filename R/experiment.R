# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Create an Azure Machine Learning experiment
#'
#' @description
#' An experiment is a grouping of many runs from a specified script.
#'
#' @param workspace The `Workspace` object.
#' @param name A string of the experiment name. The name must be between
#' 3-36 characters, start with a letter or number, and can only contain
#' letters, numbers, underscores, and dashes.
#' @return The `Experiment` object.
#' @export
#' @section Examples:
#' ```
#' ws <- load_workspace_from_config()
#' exp <- experiment(ws, name = 'myexperiment')
#' ```
#' @seealso
#' `submit_experiment()`
#' @md
experiment <- function(workspace, name) {
  azureml$core$Experiment(workspace, name)
}

#' Submit an experiment and return the active created run
#'
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
#' @section Examples:
#' The following example submits an Estimator experiment.
#' ```
#' ws <- load_workspace_from_config()
#' compute_target <- get_compute(ws, cluster_name = 'mycluster')
#' exp <- experiment(ws, name = 'myexperiment')
#' est <- estimator(source_directory = '.',
#'                  entry_script = 'train.R',
#'                  compute_target = compute_target)
#' run <- submit_experiment(exp, est)
#' ```
#'
#' For an example of submitting a HyperDrive experiment, see the
#' "Examples" section of `hyperdrive_config()`.
#' @seealso
#' `estimator()`, `hyperdrive_config()`
#' @md
submit_experiment <- function(experiment, config, tags = NULL) {
  experiment$submit(config, tags = tags)
}

#' Return a generator of the runs for an experiment
#'
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
