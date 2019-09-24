# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Create a configuration object for deploying to an AKS compute target.
#' @param autoscale_enabled Whether or not to enable autoscaling for this 
#' Webservice. Defaults to True if num_replicas is None
#' @param autoscale_min_replicas The minimum number of containers to use when 
#' autoscaling this Webservice. Defaults to 1
#' @param autoscale_max_replicas The maximum number of containers to use when 
#' autoscaling this Webservice. Defaults to 10
#' @param autoscale_refresh_seconds How often the autoscaler should attempt to 
#' scale this Webservice. Defaults to 1
#' @param autoscale_target_utilization The target utilization (in percent out 
#' of 100) the autoscaler should attempt to maintain for this Webservice. 
#' Defaults to 70
#' @param auth_enabled Whether or not to enable key auth for this Webservice. 
#' Defaults to TRUE
#' @param cpu_cores The number of cpu cores to allocate for this Webservice. 
#' Can be a decimal. Defaults to 0.1
#' @param memory_gb The amount of memory (in GB) to allocate for this 
#' Webservice. Can be a decimal. Defaults to 0.5
#' @param enable_app_insights Whether or not to enable Application Insights 
#' logging for this Webservice. Defaults to FALSE
#' @param scoring_timeout_ms A timeout to enforce for scoring calls to this 
#' Webservice. Defaults to 60000
#' @param replica_max_concurrent_requests The number of maximum concurrent 
#' requests per node to allow for this Webservice. Defaults to 1
#' @param max_request_wait_time The maximum amount of time a request will stay 
#' in the queue (in milliseconds) before returning a 503 error. Defaults to 500
#' @param num_replicas The number of containers to allocate for this 
#' Webservice. No default, if this parameter is not set then the autoscaler is 
#' enabled by default.
#' @param primary_key A primary auth key to use for this Webservice
#' @param secondary_key A secondary auth key to use for this Webservice
#' @param tags Dictionary of key value tags to give this Webservice
#' @param properties Dictionary of key value properties to give this 
#' Webservice. These properties cannot be changed after deployment, however new 
#' key value pairs can be added
#' @param description A description to give this Webservice
#' @param gpu_cores The number of gpu cores to allocate for this Webservice. 
#' Default is 1
#' @param period_seconds How often (in seconds) to perform the liveness probe. 
#' Default to 10 seconds. Minimum value is 1.
#' @param initial_delay_seconds Number of seconds after the container has 
#' started before liveness probes are initiated. Defaults to 310
#' @param timeout_seconds Number of seconds after which the liveness probe 
#' times out. Defaults to 2 second. Minimum value is 1
#' @param success_threshold Minimum consecutive successes for the liveness 
#' probe to be considered successful after having failed. Defaults to 1. 
#' Minimum value is 1.
#' @param failure_threshold When a Pod starts and the liveness probe fails, 
#' Kubernetes will try failureThreshold times before giving up. Defaults to 3. 
#' Minimum value is 1.
#' @param namespace The Kubernetes namespace in which to deploy this 
#' Webservice: up to 63 lowercase alphanumeric ('a'-'z', '0'-'9') and hyphen 
#' ('-') characters. The first and last characters cannot be hyphens.
#' @param token_auth_enabled Whether or not to enable Token auth for this 
#' Webservice. If this is enabled, users can access this Webservice by fetching 
#' access token using their Azure Active Directory credentials. 
#' Defaults to FALSE
#' @return AksServiceDeploymentConfiguration object
#' @export
aks_webservice_deployment_config <- function(autoscale_enabled = NULL, 
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


#' Update the Webservice with provided properties.
#' Values left as None will remain unchanged in this Webservice.
#' @param webservice AciWebservice object.
#' @param autoscale_enabled Enable or disable autoscaling of this Webservice
#' @param autoscale_min_replicas The minimum number of containers to use when 
#' autoscaling this Webservice
#' @param autoscale_max_replicas The maximum number of containers to use when 
#' autoscaling this Webservice
#' @param autoscale_refresh_seconds How often the autoscaler should attempt to 
#' scale this Webservice
#' @param autoscale_target_utilization The target utilization (in percent out 
#' of 100) the autoscaler should attempt to maintain for this Webservice
#' @param auth_enabled Whether or not to enable auth for this Webservice
#' @param cpu_cores The number of cpu cores to allocate for this Webservice. 
#' Can be a decimal
#' @param memory_gb The amount of memory (in GB) to allocate for this 
#' Webservice. Can be a decimal
#' @param enable_app_insights Whether or not to enable Application Insights 
#' logging for this Webservice
#' @param scoring_timeout_ms A timeout to enforce for scoring calls to this 
#' Webservice
#' @param replica_max_concurrent_requests The number of maximum concurrent 
#' requests per node to allow for this Webservice
#' @param max_request_wait_time The maximum amount of time a request will stay 
#' in the queue (in milliseconds) before returning a 503 error
#' @param num_replicas The number of containers to allocate for this Webservice
#' @param tags Dictionary of key value tags to give this Webservice. Will 
#' replace existing tags.
#' @param properties Dictionary of key value properties to add to existing 
#' properties dictionary
#' @param description A description to give this Webservice
#' @param models A list of Model objects to package with the updated service
#' @param inference_config An InferenceConfig object used to provide the 
#' required model deployment properties.
#' @param gpu_cores The number of gpu cores to allocate for this Webservice
#' @param period_seconds How often (in seconds) to perform the liveness probe. 
#' Default to 10 seconds. Minimum value is 1.
#' @param initial_delay_seconds Number of seconds after the container has 
#' started before liveness probes are initiated.
#' @param timeout_seconds Number of seconds after which the liveness probe 
#' times out. Defaults to 1 second. Minimum value is 1.
#' @param success_threshold Minimum consecutive successes for the liveness 
#' probe to be considered successful after having failed. Defaults to 1. 
#' Minimum value is 1.
#' @param failure_threshold When a Pod starts and the liveness probe fails, 
#' Kubernetes will try failureThreshold times before giving up. Defaults to 3. 
#' Minimum value is 1.
#' @param namespace The Kubernetes namespace in which to deploy this 
#' Webservice: up to 63 lowercase alphanumeric ('a'-'z', '0'-'9') and hyphen 
#' ('-') characters. The first and last characters cannot be hyphens.
#' @param token_auth_enabled Whether or not to enable Token auth for this 
#' Webservice. If this is enabled, users can access this Webservice by fetching 
#' access token using their Azure Active Directory credentials. 
#' Defaults to FALSE
#' @export
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
