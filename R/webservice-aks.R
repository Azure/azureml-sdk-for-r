# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Create a deployment config for deploying an AKS web service
#' @description
#' Deploy a web service to Azure Kubernetes Service for high-scale
#' prodution deployments. Provides fast response time and autoscaling
#' of the deployed service. Using GPU for inference when deployed as a
#' web service is only supported on AKS.
#'
#' Deploy to AKS if you need one or more of the following capabilities:
#' * Fast response time
#' * Autoscaling of the deployed service
#' * Hardware acceleration options
#' @param autoscale_enabled If `TRUE` enable autoscaling for the web service.
#' Defaults to `TRUE` if `num_replicas = NULL`.
#' @param autoscale_min_replicas An int of the minimum number of containers
#' to use when autoscaling the web service. Defaults to `1`.
#' @param autoscale_max_replicas An int of the maximum number of containers
#' to use when autoscaling the web service. Defaults to `10`.
#' @param autoscale_refresh_seconds An int of how often in seconds the
#' autoscaler should attempt to scale the web service. Defaults to `1`.
#' @param autoscale_target_utilization An int of the target utilization
#' (in percent out of 100) the autoscaler should attempt to maintain for
#' the web service. Defaults to `70`.
#' @param auth_enabled If `TRUE` enable key-based authentication for the
#' web service. Defaults to `TRUE`.
#' @param cpu_cores The number of cpu cores to allocate for
#' the web service. Can be a decimal. Defaults to `0.1`.
#' @param memory_gb The amount of memory (in GB) to allocate for
#' the web service. Can be a decimal. Defaults to `0.5`.
#' @param enable_app_insights If `TRUE` enable AppInsights for the web service.
#' Defaults to `FALSE`.
#' @param scoring_timeout_ms An int of the timeout (in milliseconds) to
#' enforce for scoring calls to the web service. Defaults to `60000`.
#' @param replica_max_concurrent_requests An int of the number of maximum
#' concurrent requests per node to allow for the web service. Defaults to `1`.
#' @param max_request_wait_time An int of the maximum amount of time a request
#' will stay in the queue (in milliseconds) before returning a 503 error.
#' Defaults to `500`.
#' @param num_replicas An int of the number of containers to allocate for the
#' web service. If this parameter is not set then the autoscaler is enabled by
#' default.
#' @param primary_key A string of the primary auth key to use for the web service.
#' @param secondary_key A string of the secondary auth key to use for the web
#' service.
#' @param tags A named list of key-value tags for the web service,
#' e.g. `list("key" = "value")`.
#' @param properties A named list of key-value properties for the web
#' service, e.g. `list("key" = "value")`. These properties cannot
#' be changed after deployment, but new key-value pairs can be added.
#' @param description A string of the description to give the web service
#' @param gpu_cores An int of the number of gpu cores to allocate for the
#' web service. Defaults to `1`.
#' @param period_seconds An int of how often in seconds to perform the
#' liveness probe. Default to `10`. Minimum value is `1`.
#' @param initial_delay_seconds An int of the number of seconds after
#' the container has started before liveness probes are initiated.
#' Defaults to `310`.
#' @param timeout_seconds An int of the number of seconds after which the
#' liveness probe times out. Defaults to `2`. Minimum value is `1`.
#' @param success_threshold An int of the minimum consecutive successes
#' for the liveness probe to be considered successful after having failed.
#' Defaults to `1`. Minimum value is `1`.
#' @param failure_threshold An int of the number of times Kubernetes will try
#' the liveness probe when a Pod starts and the probe fails, before giving up.
#' Defaults to `3`. Minimum value is `1`.
#' @param namespace A string of the Kubernetes namespace in which to deploy the web service:
#' up to 63 lowercase alphanumeric ('a'-'z', '0'-'9') and hyphen ('-') characters. The first
#'  last characters cannot be hyphens.
#' @param token_auth_enabled If `TRUE`, enable token-based authentication for the web service.
#' If enabled, users can access the web service by fetching an access token using their Azure
#' Active Directory credentials. Defaults to `FALSE`. Both `token_auth_enabled` and
#' `auth_enabled` cannot be set to `TRUE`.
#' @return The `AksServiceDeploymentConfiguration` object.
#' @export
#' @details
#' \subsection{AKS compute target}{
#' When deploying to AKS, you deploy to an AKS cluster that is connected to your workspace.
#' There are two ways to connect an AKS cluster to your workspace:
#' * Create the AKS cluster using Azure ML (see `create_aks_compute()`).
#' * Attach an existing AKS cluster to your workspace (see `attach_aks_compute()`).
#'
#' Pass the `AksCompute` object to the `deployment_target` parameter of `deploy_model()`.
#' }
#' \subsection{Token-based authentication}{
#' We strongly recommend that you create your Azure ML workspace in the same region as your
#' AKS cluster. To authenticate with a token, the web service will make a call to the region
#' in which your workspace is created. If your workspace's region is unavailable, then you will
#' not be able to fetch a token for your web service, even if your cluster is in a different region
#' than your workspace. This effectively results in token-based auth being unavailable until your
#' workspace's region is available again. In addition, the greater the distance between your
#' cluster's region and your workspace's region, the longer it will take to fetch a token.
#' }
#' @examples
#' \dontrun{
#' deployment_config <- aks_webservice_deployment_config(cpu_cores = 1, memory_gb = 1)
#' }
#' @seealso
#' `deploy_model()`
#' @md
aks_webservice_deployment_config <- function(
                                      autoscale_enabled = NULL,
                                      autoscale_min_replicas = NULL,
                                      autoscale_max_replicas = NULL,
                                      autoscale_refresh_seconds = NULL,
                                      autoscale_target_utilization = NULL,
                                      auth_enabled = NULL,
                                      cpu_cores = NULL,
                                      memory_gb = NULL,
                                      enable_app_insights = NULL,
                                      scoring_timeout_ms = NULL,
                                      replica_max_concurrent_requests = NULL,
                                      max_request_wait_time = NULL,
                                      num_replicas = NULL,
                                      primary_key = NULL,
                                      secondary_key = NULL,
                                      tags = NULL,
                                      properties = NULL,
                                      description = NULL,
                                      gpu_cores = NULL,
                                      period_seconds = NULL,
                                      initial_delay_seconds = NULL,
                                      timeout_seconds = NULL,
                                      success_threshold = NULL,
                                      failure_threshold = NULL,
                                      namespace = NULL,
                                      token_auth_enabled = NULL) {
  config <- azureml$core$webservice$AksWebservice$deploy_configuration(
    autoscale_enabled = autoscale_enabled,
    autoscale_min_replicas = autoscale_min_replicas,
    autoscale_max_replicas = autoscale_max_replicas,
    autoscale_refresh_seconds = autoscale_refresh_seconds,
    autoscale_target_utilization = autoscale_target_utilization,
    auth_enabled = auth_enabled,
    cpu_cores = cpu_cores,
    memory_gb = memory_gb,
    enable_app_insights = enable_app_insights,
    scoring_timeout_ms = scoring_timeout_ms,
    replica_max_concurrent_requests = replica_max_concurrent_requests,
    max_request_wait_time = max_request_wait_time,
    num_replicas = num_replicas,
    primary_key = primary_key,
    secondary_key = secondary_key,
    tags = tags,
    properties = properties,
    description = description,
    gpu_cores = gpu_cores,
    period_seconds = period_seconds,
    initial_delay_seconds = initial_delay_seconds,
    timeout_seconds = timeout_seconds,
    success_threshold = success_threshold,
    failure_threshold = failure_threshold,
    namespace = namespace,
    token_auth_enabled = token_auth_enabled)
  invisible(config)
}


#' Update a deployed AKS web service
#' @description
#' Update an AKS web service with the provided properties. You can update the
#' web service to use a new model, a new entry script, or new dependencies
#' that can be specified in an inference configuration.
#'
#' Values left as `NULL` will remain unchanged in the web service.
#' @param webservice The `AksWebservice` object.
#' @param autoscale_enabled If `TRUE` enable autoscaling for the web service.
#' @param autoscale_min_replicas An int of the minimum number of containers
#' to use when autoscaling the web service.
#' @param autoscale_max_replicas An int of the maximum number of containers
#' to use when autoscaling the web service.
#' @param autoscale_refresh_seconds An int of how often in seconds the autoscaler
#' should attempt to scale the web service.
#' @param autoscale_target_utilization An int of the target utilization
#' (in percent out of 100) the autoscaler should attempt to maintain for the
#' web service.
#' @param auth_enabled If `TRUE` enable key-based authentication for the
#' web service. Defaults to `TRUE`.
#' @param cpu_cores The number of cpu cores to allocate for
#' the web service. Can be a decimal. Defaults to `0.1`.
#' @param memory_gb The amount of memory (in GB) to allocate for
#' the web service. Can be a decimal. Defaults to `0.5`.
#' @param enable_app_insights If `TRUE` enable AppInsights for the web service.
#' Defaults to `FALSE`.
#' @param scoring_timeout_ms An int of the timeout (in milliseconds) to enforce for
#' scoring calls to the web service.
#' @param replica_max_concurrent_requests An int of the number of maximum concurrent
#' requests per node to allow for the web service.
#' @param max_request_wait_time An int of the maximum amount of time a request
#' will stay in the queue (in milliseconds) before returning a 503 error.
#' @param num_replicas An int of the number of containers to allocate for the
#' web service. If this parameter is not set then the autoscaler is enabled by
#' default.
#' @param tags A named list of key-value tags for the web service,
#' e.g. `list("key" = "value")`. Will replace existing tags.
#' @param properties A named list of key-value properties to add for the web
#' service, e.g. `list("key" = "value")`.
#' @param description A string of the description to give the web service.
#' @param models A list of `Model` objects to package into the updated service.
#' @param inference_config An `InferenceConfig` object.
#' @param gpu_cores An int of the number of gpu cores to allocate for the
#' web service.
#' @param period_seconds An int of how often in seconds to perform the
#' liveness probe. Minimum value is `1`.
#' @param initial_delay_seconds An int of the number of seconds after
#' the container has started before liveness probes are initiated.
#' @param timeout_seconds An int of the number of seconds after which the
#' liveness probe times out. Minimum value is `1`.
#' @param success_threshold An int of the minimum consecutive successes
#' for the liveness probe to be considered successful after having failed.
#' Minimum value is `1`.
#' @param failure_threshold An int of the number of times Kubernetes will try
#' the liveness probe when a Pod starts and the probe fails, before giving up.
#' Minimum value is `1`.
#' @param namespace A string of the Kubernetes namespace in which to deploy the
#' web service: up to 63 lowercase alphanumeric ('a'-'z', '0'-'9') and
#' hyphen ('-') characters. The first last characters cannot be hyphens.
#' @param token_auth_enabled If `TRUE`, enable token-based authentication for
#' the web service. If enabled, users can access the web service by fetching
#' an access token using their Azure Active Directory credentials.
#' Both `token_auth_enabled` and `auth_enabled` cannot be set to `TRUE`.
#' @return None
#' @export
#' @md
update_aks_webservice <- function(webservice, autoscale_enabled = NULL,
                                  autoscale_min_replicas = NULL,
                                  autoscale_max_replicas = NULL,
                                  autoscale_refresh_seconds = NULL,
                                  autoscale_target_utilization = NULL,
                                  auth_enabled = NULL,
                                  cpu_cores = NULL,
                                  memory_gb = NULL,
                                  enable_app_insights = NULL,
                                  scoring_timeout_ms = NULL,
                                  replica_max_concurrent_requests = NULL,
                                  max_request_wait_time = NULL,
                                  num_replicas = NULL,
                                  tags = NULL,
                                  properties = NULL,
                                  description = NULL,
                                  models = NULL,
                                  inference_config = NULL,
                                  gpu_cores = NULL,
                                  period_seconds = NULL,
                                  initial_delay_seconds = NULL,
                                  timeout_seconds = NULL,
                                  success_threshold = NULL,
                                  failure_threshold = NULL,
                                  namespace = NULL,
                                  token_auth_enabled = NULL) {
  webservice$update(autoscale_enabled = autoscale_enabled,
            autoscale_min_replicas = autoscale_min_replicas,
            autoscale_max_replicas = autoscale_max_replicas,
            autoscale_refresh_seconds = autoscale_refresh_seconds,
            autoscale_target_utilization = autoscale_target_utilization,
            auth_enabled = auth_enabled,
            cpu_cores = cpu_cores,
            memory_gb = memory_gb,
            enable_app_insights = enable_app_insights,
            scoring_timeout_ms = scoring_timeout_ms,
            replica_max_concurrent_requests = replica_max_concurrent_requests,
            max_request_wait_time = max_request_wait_time,
            num_replicas = num_replicas,
            tags = tags,
            properties = properties,
            description = description,
            models = models,
            inference_config = inference_config,
            gpu_cores = gpu_cores,
            period_seconds = period_seconds,
            initial_delay_seconds = initial_delay_seconds,
            timeout_seconds = timeout_seconds,
            success_threshold = success_threshold,
            failure_threshold = failure_threshold,
            namespace = namespace,
            token_auth_enabled = token_auth_enabled)
  invisible(NULL)
}
