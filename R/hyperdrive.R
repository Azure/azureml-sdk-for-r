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
create_hyperdrive_config <- function(estimator, param_sampling, policy,
                                     primary_metric_name, primary_metric_goal,
                                     max_total_runs, max_concurrent_runs = NULL)
{
  
  azureml$train$hyperdrive$HyperDriveConfig(estimator = estimator,
                                            hyperparameter_sampling = param_sampling,
                                            policy = policy,
                                            primary_metric_name = primary_metric_name,
                                            primary_metric_goal = primary_metric_goal,
                                            max_total_runs = max_total_runs,
                                            max_concurrent_runs = max_concurrent_runs)
}

#' Get early termination policy for HyperDrive runs
#' @param policy_type one of "truncation", "bandit", "median_stopping", "no_policy"
#' @return Early Termination Policy object
get_termination_policy <- function(policy_type)
{
  policies <- c(azureml$train$hyperdrive$TruncationSelectionPolicy,
               azureml$train$hyperdrive$BanditPolicy,
               azureml$train$hyperdrive$MedianStoppingPolicy,
               NULL)
  names(policies) <- c("truncation", "bandit", "median_stopping", "no_policy")
  
  policies[policy_type]
}

#' Get early termination policy for HyperDrive runs
#' @param policy_type one of "random", "grid", "bayesian"
#' @return Parameter sampling object
get_param_sampling <- function(sampling_type) 
{
  samplings <- c(azureml$train$hyperdrive$RandomParameterSampling,
                azureml$train$hyperdrive$GridParameterSampling,
                azureml$train$hyperdrive$BayesianParameterSampling)
  names(samplings) <- c("random", "grid", "bayesian")
  
  samplings[sampling_type]
}