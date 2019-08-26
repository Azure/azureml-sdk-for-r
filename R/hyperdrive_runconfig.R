#' Create configuration for a HyperDrive run
#' @param hyperparameter_sampling hyperparameter sampling option
#' @param primary_metric_name name of primary metric
#' @param primary_metric_goal goal of primary metric
#' @param max_total_runs maximum number of runs to queue
#' @param max_concurrent_runs maximum number of runs to start concurrently
#' @param max_duration_minutes maximum time to allow runs
#' @param policy termination policy
#' @param estimator estimator object (N/A if using run_config or pipeline)
#' @param run_config configuration from Run object (N/A if using estimator or pipeline)
#' @param pipeline pipeline object (N/A if using run_config or estimator)
#' @return HyperDrive config object
#' @export
create_hyperdrive_config <- function(hyperparameter_sampling, primary_metric_name,
                                     primary_metric_goal, max_total_runs,
                                     max_concurrent_runs = NULL, max_duration_minutes = 10080,
                                     policy = NULL, estimator = NULL,
                                     run_config = NULL, pipeline = NULL)
{
  
  azureml$train$hyperdrive$HyperDriveConfig(hyperparameter_sampling, primary_metric_name,
                                            primary_metric_goal, max_total_runs,
                                            max_concurrent_runs, max_duration_minutes,
                                            policy, estimatorL,
                                            run_config, pipeline)
}

#' Create Bandit policy for HyperDrive runs
#' @param slack_factor ratio of the allowed distance from best-performing run
#' @param slack_amount absolute allowed distance from the best-performing run
#' @param evaluation_interval frequency for applying policy
#' @param delay_evaluation how many intervals to delay the first evaluation
#' @return EarlyTerminationPolicy object
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
#' @return EarlyTerminationPolicy object
#' @export
create_median_stopping_policy <- function(evaluation_interval = 1, delay_evaluation = 0)
{
  azureml$train$hyperdrive$MedianStoppingPolicy(evaluation_interval, delay_evaluation)
}

#' Create Truncation Selection policy for HyperDrive runs
#' @param truncation_percentage percentage of lowest performing runs to terminate at each interval
#' @param evaluation_interval frequency for applying policy
#' @param delay_evaluation how many intervals to delay the first evaluation
#' @return EarlyTerminationPolicy object
#' @export
create_truncation_selection_policy <- function(truncation_percentage,
                                            evaluation_interval = 1, delay_evaluation = 0)
{
  azureml$train$hyperdrive$TruncationSelectionPolicy(truncation_percentage,
                                                     evaluation_interval,
                                                     delay_evaluation)
}

#' Define Random Parameter sampling over hyperparameter search space
#' @param parameter_space a named list containing each parameter and its distribution
#' @param properties a named list of additional properties for the algorithm
#' @return HyperParameterSampling object
#' @export
random_parameter_sampling <- function(parameter_space, properties = NULL)
{
  azureml$train$hyperdrive$RandomParameterSampling(parameter_space, properties)
}

#' Define Grid Parameter sampling over hyperparameter search space
#' @param parameter_space a named list containing each parameter and its distribution
#' @return HyperParameterSampling object
#' @export
grid_parameter_sampling <- function(parameter_space)
{
  azureml$train$hyperdrive$RandomParameterSampling(parameter_space)
}

#' Define Bayesian Parameter sampling over hyperparameter search space
#' @param parameter_space a named list containing each parameter and its distribution
#' @return HyperParameterSampling object
#' @export
bayesian_parameter_sampling <- function(parameter_space)
{
  azureml$train$hyperdrive$RandomParameterSampling(parameter_space)
}