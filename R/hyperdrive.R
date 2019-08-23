#' Create configuration for a HyperDrive run
#' @param estimator estimator object
#' @param param_sampling parameter sampling option
#' @param policy termination policy
#' @param primary_metric_name name of primary metric
#' @param primary_metric_goal goal of primary metric
#' @param max_total_runs maximum number of runs to queue
#' @param max_concurrent_runs maximum number of runs to start concurrently
#' @return HyperDrive config object
#' @export
create_hyperdrive_config <- function(estimator, param_sampling,
                                     primary_metric_name, primary_metric_goal,
                                     max_total_runs, max_concurrent_runs = NULL,
                                     policy = NULL)
{
  
  azureml$train$hyperdrive$HyperDriveConfig(estimator = estimator,
                                            hyperparameter_sampling = param_sampling,
                                            policy = policy,
                                            primary_metric_name = primary_metric_name,
                                            primary_metric_goal = primary_metric_goal,
                                            max_total_runs = max_total_runs,
                                            max_concurrent_runs = max_concurrent_runs)
}

#' Create Bandit policy for HyperDrive runs
#' @param slack_factor ratio of the allowed distance from best-performing run
#' @param slack_amount absolute allowed distance from the best-performing run
#' @param evaluation_interval frequency for applying policy
#' @param delay_evaluation how many intervals to delay the first evaluation
#' @return Early Termination Policy object
#' @export
create_bandit_policy <- function(slack_factor = NULL, slack_amount = NULL,
                              evaluation_interval = 1, delay_evaluation = 0)
{
  azureml$train$hyperdrive$BanditPolicy(slack_factor, slack_amount,
                                        evaluation_interval, delay_evaluation)
}

#' Create Median Stopping policy for HyperDrive runs
#' @param evaluation_interval frequency for applying policy
#' @param delay_evaluation how many intervals to delay the first evaluation
#' @return Early Termination Policy object
#' @export
create_median_stopping_policy <- function(evaluation_interval = 1, delay_evaluation = 0)
{
  azureml$train$hyperdrive$MedianStoppingPolicy(evaluation_interval, delay_evaluation)
}

#' Create Truncation Selection policy for HyperDrive runs
#' @param truncation_percentage percentage of lowest performing runs to terminate at each interval
#' @param evaluation_interval frequency for applying policy
#' @param delay_evaluation how many intervals to delay the first evaluation
#' @return Early Termination Policy object
#' @export
create_truncation_selection_policy <- function(truncation_percentage,
                                            evaluation_interval = 1, delay_evaluation = 0)
{
  azureml$train$hyperdrive$TruncationSelectionPolicy(truncation_percentage,
                                                     evaluation_interval,
                                                     delay_evaluation)
}