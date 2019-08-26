#' Return the best performing run amongst all completed runs
#' @param include_failed whether to include failed runs
#' @param include_canceled whether to include canceled runs
#' @return Run object
#' @export
get_best_run_by_primary_metric <- function(include_failed = TRUE, include_canceled = TRUE)
{
  azureml$train$hyperdrive$get_best_run_by_primary_metric(include_failed, include_canceled)
}

#' Return the child runs sorted in descending order by best primary metric
#' @param top number of top children to be returned, deafult value of 0 will return all
#' @param reverse reverse the sorting order
#' @param discard_no_metric whether to include children without the primary metric
#' @return **TODO: (find exact type of list)** Run object
#' @export
get_children_sorted_by_primary_metric <- function(top = 0, reverse = FALSE, discard_no_metric = FALSE)
{
  azureml$train$hyperdrive$get_children_sorted_by_primary_metric(top, reverse, discard_no_metric)
}

#' Return the child runs sorted in descending order by best primary metric
#' @param top number of top children to be returned, deafult value of 0 will return all
#' @param reverse reverse the sorting order
#' @param discard_no_metric whether to include children without the primary metric
#' @return **TODO: (find exact type of list)** Run object
#' @export
get_children_sorted_by_primary_metric <- function(top = 0, reverse = FALSE, discard_no_metric = FALSE)
{
  azureml$train$hyperdrive$get_children_sorted_by_primary_metric(top, reverse, discard_no_metric)
}