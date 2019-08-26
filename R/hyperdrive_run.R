#' Return the best performing run amongst all completed runs
#' @param hyperdrive_run HyperDriveRun object
#' @param include_failed whether to include failed runs
#' @param include_canceled whether to include canceled runs
#' @return Run object
#' @export
get_best_run_by_primary_metric <- function(hyperdrive_run, include_failed = TRUE,
                                           include_canceled = TRUE)
{
  hyperdrive_run$get_best_run_by_primary_metric(include_failed, include_canceled)
}

#' Return the child runs sorted in descending order by best primary metric
#' @param hyperdrive_run HyperDriveRun object
#' @param top number of top children to be returned, deafult value of 0 will return all
#' @param reverse reverse the sorting order
#' @param discard_no_metric whether to include children without the primary metric
#' @return named list of child runs
#' @export
get_children_sorted_by_primary_metric <- function(hyperdrive_run, top = 0,
                                                  reverse = FALSE, discard_no_metric = FALSE)
{
  hyperdrive_run$get_children_sorted_by_primary_metric(top, reverse,
                                                       discard_no_metric)
}

#' Return hyperparameters for all child runs
#' @param hyperdrive_run HyperDriveRun object
#' @return named list of hyperparameters grouped by run_id
#' @export
get_children_hyperparameters <- function(hyperdrive_run)
{
  hyperdrive_run$get_hyperparameters(hyperdrive_run)
}

#' Return metrics from all child runs
#' @param hyperdrive_run HyperDriveRun object
#' @return name list of metrics grouped by run_id
#' @export
get_children_metrics <- function(hyperdrive_run)
{
  hyperdrive_run$get_metrics()
}