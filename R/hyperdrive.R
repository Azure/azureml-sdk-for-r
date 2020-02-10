# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

### HyperDrive configuration ###

#' Create a configuration for a HyperDrive run
#'
#' @description
#' The HyperDrive configuration includes information about hyperparameter
#' space sampling, termination policy, primary metric, estimator, and
#' the compute target to execute the experiment runs on.
#'
#' To submit the HyperDrive experiment, pass the `HyperDriveConfig` object
#' returned from this method to `submit_experiment()`.
#' @param hyperparameter_sampling The hyperparameter sampling space.
#' Can be a `RandomParameterSampling`, `GridParameterSampling`, or
#' `BayesianParameterSampling` object.
#' @param primary_metric_name A string of the name of the primary metric
#' reported by the experiment runs.
#' @param primary_metric_goal The `PrimaryMetricGoal` object. This
#' parameter determines if the primary metric is to be minimized or
#' maximized when evaluating runs.
#' @param max_total_runs An integer of the maximum total number of runs
#' to create. This is the upper bound; there may be fewer runs when the
#' sample space is smaller than this value. If both `max_total_runs` and
#' `max_duration_minutes` are specified, the hyperparameter tuning experiment
#' terminates when the first of these two thresholds is reached.
#' @param max_concurrent_runs An integer of the maximum number of runs to
#' execute concurrently. If `NULL`, all runs are launched in parallel.
#' The number of concurrent runs is gated on the resources available in the
#' specified compute target. Hence, you need to ensure that the compute target
#' has the available resources for the desired concurrency.
#' @param max_duration_minutes An integer of the maximum duration of the
#' HyperDrive run. Once this time is exceeded, any runs still executing are
#' cancelled. If both `max_total_runs` and `max_duration_minutes` are specified,
#' the hyperparameter tuning experiment terminates when the first of these two
#' thresholds is reached.
#' @param policy The early termination policy to use. Can be either a
#' `BanditPolicy`, `MedianStoppingPolicy`, or `TruncationSelectionPolicy`
#' object. If `NULL` (the default), no early termination policy will be used.
#'
#' The `MedianStoppingPolicy` with `delay_evaluation of = 5` is a good
#' termination policy to start with. These are conservative settings that can
#' provide 25%-35% savings with no loss on primary metric
#' (based on our evaluation data).
#' @param estimator The `Estimator` object.
#' @return The `HyperDriveConfig` object.
#' @export
#' @examples
#' \dontrun{
#' # Load the workspace
#' ws <- load_workspace_from_config()
#'
#' # Get the compute target
#' compute_target <- get_compute(ws, cluster_name = 'mycluster')
#'
#' # Define the primary metric goal
#' goal = primary_metric_goal("MAXIMIZE")
#'
#' # Define the early termination policy
#' early_termination_policy = median_stopping_policy(evaluation_interval = 1L,
#'                                                   delay_evaluation = 5L)
#'
#' # Create the estimator
#' est <- estimator(source_directory = '.',
#'                  entry_script = 'train.R',
#'                  compute_target = compute_target)
#'
#' # Create the HyperDrive configuration
#' hyperdrive_run_config = hyperdrive_config(
#'                                    hyperparameter_sampling = param_sampling,
#'                                    primary_metric_name = 'accuracy',
#'                                    primary_metric_goal = goal,
#'                                    max_total_runs = 100,
#'                                    max_concurrent_runs = 4,
#'                                    policy = early_termination_policy,
#'                                    estimator = est)
#'
#' # Submit the HyperDrive experiment
#' exp <- experiment(ws, name = 'myexperiment')
#' run = submit_experiment(exp, hyperdrive_run_config)
#' }
#' @seealso
#' `submit_experiment()`
#' @md
hyperdrive_config <- function(hyperparameter_sampling,
                              primary_metric_name,
                              primary_metric_goal,
                              max_total_runs,
                              max_concurrent_runs = NULL,
                              max_duration_minutes = 10080L,
                              policy = NULL,
                              estimator = NULL) {

  azureml$train$hyperdrive$HyperDriveConfig(hyperparameter_sampling,
                                            primary_metric_name,
                                            primary_metric_goal,
                                            max_total_runs,
                                            max_concurrent_runs,
                                            max_duration_minutes,
                                            policy, estimator)
}

### Specifying metric goal ###

#' Define supported metric goals for hyperparameter tuning
#'
#' @description
#' A metric goal is used to determine whether a higher value for a metric
#' is better or worse. Metric goals are used when comparing runs based on
#' the primary metric. For example, you may want to maximize accuracy or
#' minimize error.
#'
#' The primary metric name and goal are specified to `hyperdrive_config()`
#' when you configure a HyperDrive run.
#' @param goal A string of the metric goal (either "MAXIMIZE" or "MINIMIZE").
#' @return The `PrimaryMetricGoal` object.
#' @export
#' @md
primary_metric_goal <- function(goal) {
  azureml$train$hyperdrive$PrimaryMetricGoal(goal)
}

### Specifying early termination policy ###

#' Define a Bandit policy for early termination of HyperDrive runs
#'
#' @description
#' Bandit is an early termination policy based on slack factor/slack amount
#' and evaluation interval. The policy early terminates any runs where the
#' primary metric is not within the specified slack factor/slack amount with
#' respect to the best performing training run.
#' @param slack_factor A double of the ratio of the allowed distance from
#' the best performing run.
#' @param slack_amount A double of the absolute distance allowed from the
#' best performing run.
#' @param evaluation_interval An integer of the frequency for applying policy.
#' @param delay_evaluation An integer of the number of intervals for which to
#' delay the first evaluation.
#' @return The `BanditPolicy` object.
#' @export
#' @section Details:
#' The Bandit policy takes the following configuration parameters:
#' * `slack_factor` or `slack_amount`: The slack allowed with respect to
#' the best performing training run. `slack_factor` specifies the
#' allowable slack as a ration. `slack_amount` specifies the allowable
#' slack as an absolute amount, instead of a ratio.
#' * `evaluation_interval`: Optional. The frequency for applying the policy.
#' Each time the training script logs the primary metric counts as one
#' interval.
#' * `delay_evaluation`: Optional. The number of intervals to delay the
#' policy evaluation. Use this parameter to avoid premature termination
#' of training runs. If specified, the policy applies every multiple of
#' `evaluation_interval` that is greater than or equal to `delay_evaluation`.
#'
#' Any run that doesn't fall within the slack factor or slack amount of the
#' evaluation metric with respect to the best performing run will be
#' terminated.
#'
#' Consider a Bandit policy with `slack_factor = 0.2` and
#' `evaluation_interval = 100`. Assume that run X is the currently best
#' performing run with an AUC (performance metric) of 0.8 after 100 intervals.
#' Further, assume the best AUC reported for a run is Y. This policy compares
#' the value `(Y + Y * 0.2)` to 0.8, and if smaller, cancels the run.
#' If `delay_evaluation = 200`, then the first time the policy will be applied
#' is at interval 200.
#'
#' Now, consider a Bandit policy with `slack_amount = 0.2` and
#' `evaluation_interval = 100`. If run 3 is the currently best performing run
#' with an AUC (performance metric) of 0.8 after 100 intervals, then any run
#' with an AUC less than 0.6 (`0.8 - 0.2`) after 100 iterations will be
#' terminated. Similarly, the `delay_evaluation` can also be used to delay the
#' first termination policy evaluation for a specific number of sequences.
#' @examples
#' # In this example, the early termination policy is applied at every interval
#' # when metrics are reported, starting at evaluation interval 5. Any run whose
#' # best metric is less than (1 / (1 + 0.1)) or 91\% of the best performing run will
#' # be terminated
#' \dontrun{
#' early_termination_policy = bandit_policy(slack_factor = 0.1,
#'                                          evaluation_interval = 1L,
#'                                          delay_evaluation = 5L)
#' }
#' @md
bandit_policy <- function(slack_factor = NULL,
                          slack_amount = NULL,
                          evaluation_interval = 1L,
                          delay_evaluation = 0L) {
  azureml$train$hyperdrive$BanditPolicy(evaluation_interval,
                                        slack_factor,
                                        slack_amount,
                                        delay_evaluation)
}

#' Define a median stopping policy for early termination of HyperDrive runs
#'
#' @description
#' Median stopping is an early termination policy based on running averages of
#' primary metrics reported by the runs. This policy computes running averages
#' across all training runs and terminates runs whose performance is worse than
#' the median of the running averages. Specifically, a run will be canceled at
#' interval N if its best primary metric reported up to interval N is worse than
#' the median of the running averages for intervals 1:N across all runs.
#' @param evaluation_interval An integer of the frequency for applying policy.
#' @param delay_evaluation An integer of the number of intervals for which to
#' delay the first evaluation.
#' @return The `MedianStoppingPolicy` object.
#' @export
#' @section Details:
#' The median stopping policy takes the following optional configuration
#' parameters:
#' * `evaluation_interval`: Optional. The frequency for applying the policy.
#' Each time the training script logs the primary metric counts as one
#' interval.
#' * `delay_evaluation`: Optional. The number of intervals to delay the
#' policy evaluation. Use this parameter to avoid premature termination
#' of training runs. If specified, the policy applies every multiple of
#' `evaluation_interval` that is greater than or equal to `delay_evaluation`.
#'
#' This policy is inspired from the research publication
#' [Google Vizier: A Service for Black-Box Optimization](https://ai.google/research/pubs/pub46180).
#'
#' If you are looking for a conservative policy that provides savings without
#' terminating promising jobs, you can use a `MedianStoppingPolicy` with
#' `evaluation_interval = 1` and `delay_evaluation = 5`. These are conservative
#' settings that can provide approximately 25%-35% savings with no loss on
#' the primary metric (based on our evaluation data).
#' @examples
#' # In this example, the early termination policy is applied at every
#' # interval starting at evaluation interval 5. A run will be terminated at
#' # interval 5 if its best primary metric is worse than the median of the
#' # running averages over intervals 1:5 across all training runs
#' \dontrun{
#' early_termination_policy = median_stopping_policy(evaluation_interval = 1L,
#'                                                   delay_evaluation = 5L)
#' }
#' @md
median_stopping_policy <- function(evaluation_interval = 1L,
                                   delay_evaluation = 0L) {
  azureml$train$hyperdrive$MedianStoppingPolicy(evaluation_interval,
                                                delay_evaluation)
}

#' Define a truncation selection policy for early termination of HyperDrive runs
#'
#' @description
#' Truncation selection cancels a given percentage of lowest performing runs at
#' each evaluation interval. Runs are compared based on their performance on the
#' primary metric and the lowest X% are terminated.
#'
#' @param truncation_percentage An integer of the percentage of lowest
#' performing runs to terminate at each interval.
#' @param evaluation_interval An integer of the frequency for applying policy.
#' @param delay_evaluation An integer of the number of intervals for which to
#' delay the first evaluation.
#' @return The `TruncationSelectionPolicy` object.
#' @export
#' @section Details:
#' This policy periodically cancels the given percentage of runs that rank the
#' lowest for their performance on the primary metric. The policy strives for
#' fairness in ranking the runs by accounting for improving model performance
#' with training time. When ranking a relatively young run, the policy uses the
#' corresponding (and earlier) performance of older runs for comparison.
#' Therefore, runs aren't terminated for having a lower performance because they
#' have run for less time than other runs.
#'
#' The truncation selection policy takes the following configuration parameters:
#' * `truncation_percentage`: An integer of the percentage of lowest performing
#' runs to terminate at each evaluation interval.
#' * `evaluation_interval`: Optional. The frequency for applying the policy.
#' Each time the training script logs the primary metric counts as one
#' interval.
#' * `delay_evaluation`: Optional. The number of intervals to delay the
#' policy evaluation. Use this parameter to avoid premature termination
#' of training runs. If specified, the policy applies every multiple of
#' `evaluation_interval` that is greater than or equal to `delay_evaluation`.
#'
#' For example, when evaluating a run at a interval N, its performance is only
#' compared with the performance of other runs up to interval N even if they
#' reported metrics for intervals greater than N.
#' @examples
#' # In this example, the early termination policy is applied at every interval
#' # starting at evaluation interval 5. A run will be terminated at interval 5
#' # if its performance at interval 5 is in the lowest 20% of performance of all
#' # runs at interval 5
#' \dontrun{
#' early_termination_policy = truncation_selection_policy(
#'                                                  truncation_percentage = 20L,
#'                                                  evaluation_interval = 1L,
#'                                                  delay_evaluation = 5L)
#' }
#' @md
truncation_selection_policy <- function(truncation_percentage,
                                        evaluation_interval = 1L,
                                        delay_evaluation = 0L) {
  azureml$train$hyperdrive$TruncationSelectionPolicy(truncation_percentage,
                                                     evaluation_interval,
                                                     delay_evaluation)
}

### Specifying sampling space ###

#' Define random sampling over a hyperparameter search space
#'
#' @description
#' In random sampling, hyperparameter values are randomly selected from the
#' defined search space. Random sampling allows the search space to include
#' both discrete and continuous hyperparameters.
#' @param parameter_space A named list containing each parameter and its
#' distribution, e.g. `list("parameter" = distribution)`.
#' @param properties A named list of additional properties for the algorithm.
#' @return The `RandomParameterSampling` object.
#' @export
#' @section Details:
#' In this sampling algorithm, parameter values are chosen from a set of
#' discrete values or a distribution over a continuous range. Functions you can
#' use include:
#' `choice()`, `randint()`, `uniform()`, `quniform()`, `loguniform()`,
#' `qloguniform()`, `normal()`, `qnormal()`, `lognormal()`, and `qlognormal()`.
#' @examples
#' \dontrun{
#' param_sampling <- random_parameter_sampling(list("learning_rate" = normal(10, 3),
#'                                                  "keep_probability" = uniform(0.05, 0.1),
#'                                                  "batch_size" = choice(c(16, 32, 64, 128))))
#' }
#' @seealso
#' `choice()`, `randint()`, `uniform()`, `quniform()`, `loguniform()`,
#' `qloguniform()`, `normal()`, `qnormal()`, `lognormal()`, `qlognormal()`
#' @md
random_parameter_sampling <- function(parameter_space, properties = NULL) {
  azureml$train$hyperdrive$RandomParameterSampling(parameter_space, properties)
}

#' Define grid sampling over a hyperparameter search space
#'
#' @description
#' Grid sampling performs a simple grid search over all feasible values in
#' the defined search space. It can only be used with hyperparameters
#' specified using `choice()`.
#' @param parameter_space A named list containing each parameter and its
#' distribution, e.g. `list("parameter" = distribution)`.
#' @return The `GridParameterSampling` object.
#' @export
#' @examples
#' \dontrun{
#' param_sampling <- grid_parameter_sampling(list("num_hidden_layers" = choice(c(1, 2, 3)),
#'                                                "batch_size" = choice(c(16, 32))))
#' }
#' @seealso
#' `choice()`
#' @md
grid_parameter_sampling <- function(parameter_space) {
  azureml$train$hyperdrive$GridParameterSampling(parameter_space)
}

#' Define Bayesian sampling over a hyperparameter search space
#'
#' @description
#' Bayesian sampling is based on the Bayesian optimization algorithm and makes
#' intelligent choices on the hyperparameter values to sample next. It picks
#' the sample based on how the previous samples performed, such that the new
#' sample improves the reported primary metric.
#' @param parameter_space A named list containing each parameter and its
#' distribution, e.g. `list("parameter" = distribution)`.
#' @return The `BayesianParameterSampling` object.
#' @export
#' @section Details:
#' When you use Bayesian sampling, the number of concurrent runs has an impact
#' on the effectiveness of the tuning process. Typically, a smaller number of
#' concurrent runs can lead to better sampling convergence, since the smaller
#' degree of parallelism increases the number of runs that benefit from
#' previously completed runs.
#'
#' Bayesian sampling only supports `choice()`, `uniform()`, and `quniform()`
#' distributions over the search space.
#'
#' Bayesian sampling does not support any early termination policy. When
#' using Bayesian parameter sampling, `early_termination_policy` must be
#' `NULL`.
#' @examples
#' \dontrun{
#' param_sampling <- bayesian_parameter_sampling(list("learning_rate" = uniform(0.05, 0.1),
#'                                                    "batch_size" = choice(c(16, 32, 64, 128))))
#' }
#' @seealso
#' `choice()`, `uniform()`, `quniform()`
#' @md
bayesian_parameter_sampling <- function(parameter_space) {
  azureml$train$hyperdrive$BayesianParameterSampling(parameter_space)
}

### Parameter expressions for describing search space ###

#' Specify a discrete set of options to sample from
#'
#' @description
#' Specify a discrete set of options to sample the hyperparameters
#' from.
#' @param options A vector of values to choose from.
#' @return A list of the stochastic expression.
#' @export
#' @seealso
#' `random_parameter_sampling()`, `grid_parameter_sampling()`,
#' `bayesian_parameter_sampling()`
#' @md
choice <- function(options) {
  azureml$train$hyperdrive$choice(options)
}

#' Specify a set of random integers in the range `[0, upper)`
#'
#' @description
#' Specify a set of random integers in the range `[0, upper)`
#' to sample the hyperparameters from.
#'
#' The semantics of this distribution is that there is no more
#' correlation in the loss function between nearby integer values,
#' as compared with more distant integer values. This is an
#' appropriate distribution for describing random seeds, for example.
#' If the loss function is probably more correlated for nearby integer
#' values, then you should probably use one of the "quantized" continuous
#' distributions, such as either `quniform()`, `qloguniform()`, `qnormal()`,
#' or `qlognormal()`.
#' @param upper An integer of the upper bound for the range of
#' integers (exclusive).
#' @return A list of the stochastic expression.
#' @seealso
#' `random_parameter_sampling()`, `grid_parameter_sampling()`,
#' `bayesian_parameter_sampling()`
#' @export
#' @md
randint <- function(upper) {
  azureml$train$hyperdrive$randint(upper)
}

#' Specify a uniform distribution of options to sample from
#'
#' @description
#' Specify a uniform distribution of options to sample the
#' hyperparameters from.
#' @param min_value A double of the minimum value in the range
#' (inclusive).
#' @param max_value A double of the maximum value in the range
#' (inclusive).
#' @return A list of the stochastic expression.
#' @seealso
#' `random_parameter_sampling()`, `grid_parameter_sampling()`,
#' `bayesian_parameter_sampling()`
#' @export
#' @md
uniform <- function(min_value, max_value) {
  azureml$train$hyperdrive$uniform(min_value, max_value)
}

#' Specify a uniform distribution of the form
#' `round(uniform(min_value, max_value) / q) * q`
#'
#' @description
#' Specify a uniform distribution of the form
#' `round(uniform(min_value, max_value) / q) * q`.
#'
#' This is suitable for a discrete value with respect to which the objective
#' is still somewhat "smooth", but which should be bounded both above and below.
#' @param min_value A double of the minimum value in the range (inclusive).
#' @param max_value A double of the maximum value in the range (inclusive).
#' @param q An integer of the smoothing factor.
#' @return A list of the stochastic expression.
#' @seealso
#' `random_parameter_sampling()`, `grid_parameter_sampling()`,
#' `bayesian_parameter_sampling()`
#' @export
#' @md
quniform <- function(min_value, max_value, q) {
  azureml$train$hyperdrive$quniform(min_value, max_value, q)
}

#' Specify a log uniform distribution
#'
#' @description
#' Specify a log uniform distribution.
#'
#' A value is drawn according to `exp(uniform(min_value, max_value))` so that
#' the logarithm of the return value is uniformly distributed. When optimizing,
#' this variable is constrained to the interval
#' `[exp(min_value), exp(max_value)]`.
#' @param min_value A double where the minimum value in the range will be
#' `exp(min_value)` (inclusive).
#' @param max_value A double where the maximum value in the range will be
#' `exp(min_value)` (inclusive).
#' @return A list of the stochastic expression.
#' @seealso
#' `random_parameter_sampling()`, `grid_parameter_sampling()`,
#' `bayesian_parameter_sampling()`
#' @export
#' @md
loguniform <- function(min_value, max_value) {
  azureml$train$hyperdrive$loguniform(min_value, max_value)
}

#' Specify a uniform distribution of the form
#' `round(exp(uniform(min_value, max_value) / q) * q`
#'
#' @description
#' Specify a uniform distribution of the form
#' `round(exp(uniform(min_value, max_value) / q) * q`.
#'
#' This is suitable for a discrete variable with respect to which the objective
#' is "smooth", and gets smoother with the size of the value, but which should
#' be bounded both above and below.
#' @param min_value A double of the minimum value in the range (inclusive).
#' @param max_value A double of the maximum value in the range (inclusive).
#' @param q An integer of the smoothing factor.
#' @return A list of the stochastic expression.
#' @seealso
#' `random_parameter_sampling()`, `grid_parameter_sampling()`,
#' `bayesian_parameter_sampling()`
#' @export
#' @md
qloguniform <- function(min_value, max_value, q) {
  azureml$train$hyperdrive$qloguniform(min_value, max_value, q)
}

#' Specify a real value that is normally-distributed with mean `mu` and standard
#' deviation `sigma`
#'
#' @description
#' Specify a real value that is normally-distributed with mean `mu` and
#' standard deviation `sigma`.
#'
#' When optimizing, this is an unconstrained variable.
#' @param mu A double of the mean of the normal distribution.
#' @param sigma A double of the standard deviation of the normal distribution.
#' @return A list of the stochastic expression.
#' @seealso
#' `random_parameter_sampling()`, `grid_parameter_sampling()`,
#' `bayesian_parameter_sampling()`
#' @export
#' @md
normal <- function(mu, sigma) {
  azureml$train$hyperdrive$normal(mu, sigma)
}

#' Specify a normal distribution of the `form round(normal(mu, sigma) / q) * q`
#'
#' @description
#' Specify a normal distribution of the form `round(normal(mu, sigma) / q) * q`.
#'
#' Suitable for a discrete variable that probably takes a value around `mu`,
#' but is fundamentally unbounded.
#' @param mu A double of the mean of the normal distribution.
#' @param sigma A double of the standard deviation of the normal distribution.
#' @param q An integer of the smoothing factor.
#' @return A list of the stochastic expression.
#' @seealso
#' `random_parameter_sampling()`, `grid_parameter_sampling()`,
#' `bayesian_parameter_sampling()`
#' @export
#' @md
qnormal <- function(mu, sigma, q) {
  azureml$train$hyperdrive$qnormal(mu, sigma, q)
}

#' Specify a normal distribution of the form `exp(normal(mu, sigma))`
#'
#' @description
#' Specify a normal distribution of the form `exp(normal(mu, sigma))`.
#'
#' The logarithm of the return value is normally distributed. When optimizing,
#' this variable is constrained to be positive.
#' @param mu A double of the mean of the normal distribution.
#' @param sigma A double of the standard deviation of the normal distribution.
#' @return A list of the stochastic expression.
#' @seealso
#' `random_parameter_sampling()`, `grid_parameter_sampling()`,
#' `bayesian_parameter_sampling()`
#' @export
#' @md
lognormal <- function(mu, sigma) {
  azureml$train$hyperdrive$lognormal(mu, sigma)
}

#' Specify a normal distribution of the form
#' `round(exp(normal(mu, sigma)) / q) * q`
#'
#' @description
#' Specify a normal distribution of the form
#' `round(exp(normal(mu, sigma)) / q) * q`.
#'
#' Suitable for a discrete variable with respect to which the objective is
#' smooth and gets smoother with the size of the variable, which is bounded
#' from one side.
#' @param mu A double of the mean of the normal distribution.
#' @param sigma A double of the standard deviation of the normal distribution.
#' @param q An integer of the smoothing factor.
#' @return A list of the stochastic expression.
#' @seealso
#' `random_parameter_sampling()`, `grid_parameter_sampling()`,
#' `bayesian_parameter_sampling()`
#' @export
#' @md
qlognormal <- function(mu, sigma, q) {
  azureml$train$hyperdrive$qlognormal(mu, sigma, q)
}

### Retrieving run metrics ###

#' Return the best performing run amongst all completed runs
#'
#' @description
#' Find and return the run that corresponds to the best performing run
#' amongst all the completed runs.
#'
#' The best performing run is identified solely based on the primary metric
#' parameter specified in the `HyperDriveConfig` (`primary_metric_name`).
#' The `PrimaryMetricGoal` governs whether the minimum or maximum of the
#' primary metric is used. To do a more detailed analysis of all the
#' run metrics launched by this HyperDrive run, use `get_child_run_metrics()`.
#' Only one of the runs is returned from `get_best_run_by_primary_metric()`,
#' even if several of the runs launched by this HyperDrive run reached
#' the same best metric.
#' @param hyperdrive_run The `HyperDriveRun` object.
#' @param include_failed If `TRUE`, include the failed runs.
#' @param include_canceled If `TRUE`, include the canceled runs.
#' @return The `Run` object.
#' @export
#' @md
get_best_run_by_primary_metric <- function(hyperdrive_run,
                                           include_failed = TRUE,
                                           include_canceled = TRUE) {
  hyperdrive_run$get_best_run_by_primary_metric(include_failed,
                                                include_canceled)
}

#' Get the child runs sorted in descending order by
#' best primary metric
#'
#' @description
#' Return a list of child runs of the HyperDrive run sorted by their best
#' primary metric. The sorting is done according to the primary metric and
#' its goal: if it is maximize, then the child runs are returned in descending
#' order of their best primary metric. If `reverse = TRUE`, the order is
#' reversed. Each child in the result has run id, hyperparameters, best primary
#' metric value, and status.
#'
#' Child runs without the primary metric are discarded when
#' `discard_no_metric = TRUE`. Otherwise, they are appended to the list behind
#' other child runs with the primary metric. Note that the reverse option has no
#' impact on them.
#' @param hyperdrive_run The `HyperDriveRun` object.
#' @param top An integer of the number of top child runs to be returned. If `0`
#' (the default value), all child runs will be returned.
#' @param reverse If `TRUE`, the order will be reversed. This sorting only
#' impacts child runs with the primary metric.
#' @param discard_no_metric If `FALSE`, child runs without the primary metric
#' will be appended to the list returned.
#' @return The named list of child runs.
#' @export
#' @md
get_child_runs_sorted_by_primary_metric <- function(hyperdrive_run,
                                                    top = 0L,
                                                    reverse = FALSE,
                                                    discard_no_metric = FALSE) {
  hyperdrive_run$get_children_sorted_by_primary_metric(top, reverse,
                                                       discard_no_metric)
}

#' Get the hyperparameters for all child runs
#'
#' @description
#' Return the hyperparameters for all the child runs of the
#' HyperDrive run.
#' @param hyperdrive_run The `HyperDriveRun` object.
#' @return The named list of hyperparameters where element name
#' is the run_id, e.g. `list("run_id" = hyperparameters)`.
#' @export
#' @md
get_child_run_hyperparameters <- function(hyperdrive_run) {
  hyperdrive_run$get_hyperparameters()
}

#' Get the metrics from all child runs
#'
#' @description
#' Return the metrics from all the child runs of the
#' HyperDrive run.
#' @param hyperdrive_run The `HyperDriveRun` object.
#' @return The named list of metrics where element name is
#' the run_id, e.g. `list("run_id" = metrics)`.
#' @export
#' @md
get_child_run_metrics <- function(hyperdrive_run) {
  hyperdrive_run$get_metrics()
}
