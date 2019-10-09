install.packages('AzureAuth')
install.packages('promises')
install.packages('future')

library(future)
library(promises)

library(AzureAuth)
library(mlflow)
# install python package for mlflow
install_mlflow()


get_tracking_uri <- function(region,
                             subscription_id,
                             resource_group,
                             workspace_name) {
    sprintf(paste0('https://%s.experiments.azureml.net/history/v1.0/',
                   'subscriptions/%s/resourceGroups/%s/providers/',
                   'Microsoft.MachineLearningServices/workspaces/%s'),
            region,
            subscription_id,
            resource_group,
            workspace_name)
}

tenant_id <- Sys.getenv('TENANT_ID', unset = '<TENANT_ID>')
client_id <- Sys.getenv('CLIENT_ID', unset = '<CLIENT_ID')
secret <- Sys.getenv('SECRET', unset = '<SECRET>')

# client_id is service principal's application (client) id. password is service
# principal's secret
# service principal should have contributor access to workspace
# call token$refresh() to refresh the token if you start hitting 403 errors.
token <- get_azure_token(c('https://management.azure.com/.default',
                           'offline_access'),
                         tenant = tenant_id,
                         app = client_id,
                         password = secret,
                         version=2)

Sys.setenv('MLFLOW_TOKEN' = token$credentials$access_token)

# set up background refresh of token if this has to run for a long time in a
script
plan(multisession, workers = 2)
f <- function(x){
    token$refresh()
    Sys.setenv('MLFLOW_TOKEN' = token$credentials$access_token)
    future(Sys.sleep(3600)) %...>% f
}
future(Sys.sleep(3600)) %...>% f


region <- Sys.getenv('REGION', unset = '<workspace_region')
subscription_id <- Sys.getenv('SUBSCRIPTION_ID', unset = '<subscription_id>')
resource_group <- Sys.getenv('RESOURCE_GROUP', unset = '<resource_group')
workspace_name <- Sys.getenv('WORKSPACE_NAME', unset = '<workspace_name')

tracking_uri <- get_tracking_uri(region,
                                 subscription_id,
                                 resource_group,
                                 workspace_name)
client <- mlflow_client(tracking_uri = tracking_uri)

experiment_id <- mlflow_create_experiment('mlflow_experiment', client = client)
run_id <- mlflow_start_run(experiment_id = experiment_id, client = client)

mlflow_log_metric("key", 2, run_id = run_id$run_id, client = client)
mlflow_get_metric_history("key", run_id = run_id$run_id)
