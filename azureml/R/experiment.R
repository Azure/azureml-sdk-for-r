#' Create an Azure Machine Learning Experiment
#' @param workspace The workspace object that would contain the experiment.
#' @param name The experiment name.
#' @return experiment object
#' @export
get_or_create_experiment <- function(workspace, name)
{
  aml$core$Experiment(workspace, name)
}

#' Submit experiment
#' @param config runconfig or estimator
#' @param experiment experiment object
#' @param tags Tags to be added to the submitted run. A named list eg. list("tag" = "value")
#' @return run object
#' @export
submit_experiment <- function(config, experiment, tags = NULL)
{
  experiment$submit(config, tags = tags)
}
