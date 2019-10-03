# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Create an Azure Machine Learning Experiment
#' @param workspace The workspace object that would contain the experiment.
#' @param name The experiment name.
#' @return experiment object
#' @export
experiment <- function(workspace, name) {
  azureml$core$Experiment(workspace, name)
}

#' Submit an experiment and return the active created run
#' @param experiment experiment object
#' @param config runconfig or estimator
#' @param tags Tags to be added to the submitted run. A named list
#' eg. list("tag" = "value")
#' @return run object
#' @export
submit_experiment <- function(experiment, config, tags = NULL) {
  experiment$submit(config, tags = tags)
}

#' Return a generator of the runs for this experiment
#' @param experiment experiment object
#' @param type Filter the returned generator of runs by the provided type.
#' @param tags Filter runs by tags. A named list eg. list("tag" = "value")
#' @param properties Filter runs by properties. A named list 
#' eg. list("property" = "value")
#' @param include_children By default, fetch only top-level runs. 
#' Set to TRUE to list all runs
#' @return The list of runs matching supplied filters
#' @export
get_runs_in_experiment <- function(experiment, type = NULL, tags = NULL,
                                   properties = NULL, include_children = FALSE) {
  experiment$get_runs(type = type,
                      tags = tags,
                      properties = properties,
                      include_children = include_children)
}
