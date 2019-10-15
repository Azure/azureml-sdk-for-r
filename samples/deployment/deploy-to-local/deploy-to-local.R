# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

library("azureml")
library("jsonlite")


# Register model and deploy locally
# This example shows how to deploy a web service in step-by-step fashion:
#   
# 1) Register model
# 2) Deploy the image as a web service in a local Docker container.
# 3) Quickly test changes to your entry script by reloading the local service.
# 4) Optionally, you can also make changes to model, conda or extra_docker_file_steps and update local service

#Initialize a workspace object from persisted configuration.
ws <- load_workspace_from_config()

# register the model. we are using model.rds file in the current directory 
# as a model with the same name model.rds in the workspace.
model <- register_model(ws, model_path = "model.rds", model_name = "model.rds")

#create environment
r_env <- r_environment(name = "r_env")

# create inference config
inference_config <- inference_config(
  entry_script = "score.R",
  source_directory = ".",
  environment = r_env)

# create ACI deployment config, deploy Model as a local docker Web service
local_deployment_config <- local_webservice_deployment_config()

# deploy the webservice
# NOTE:

# The Docker image runs as a Linux container. If you are running Docker for Windows, you need to ensure the Linux Engine is running:
# # PowerShell command to switch to Linux engine
# & 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchLinuxEngine

service <- deploy_model(ws, 
                        'rservice-local', 
                        list(model), 
                        inference_config, 
                        local_deployment_config)
# Wait for deployment
wait_for_deployment(service, show_output = TRUE)

#show the port of local service
message(service$port)

# If you encounter any issue in deploying the webservice, please visit
# https://docs.microsoft.com/en-us/azure/machine-learning/service/how-to-troubleshoot-deployment

# Inferencing
# versicolor
# plant <- data.frame(Sepal.Length = 6.4,
#                     Sepal.Width = 2.8,
#                     Petal.Length = 4.6,
#                     Petal.Width = 1.8)
# setosa
plant <- data.frame(Sepal.Length = 5.1,
                    Sepal.Width = 3.5,
                    Petal.Length = 1.4,
                    Petal.Width = 0.2)
# # virginica
# plant <- data.frame(Sepal.Length = 6.7,
#                     Sepal.Width = 3.3,
#                     Petal.Length = 5.2,
#                     Petal.Width = 2.3)

#Test the web service, Call the web service with some input data to get a prediction.
invoke_webservice(service, toJSON(plant))

## The last few lines of the logs should have the correct prediction and should display -> R[write to console]: "setosa" 
cat(gsub(pattern="\n", replacement = " \n", x=get_webservice_logs(service)))

##Optional, Reload the service as you make a change.
reload_local_webservice_assets(service)

# Check updated service
invoke_webservice(service, toJSON(plant))
cat(gsub(pattern="\n", replacement = " \n", x=get_webservice_logs(service)))

# Update service
# If you want to change your model(s), Conda dependencies, or deployment configuration, call update() to rebuild the Docker image.

#update_local_webservice(service, models = [NewModelObject], deployment_config = deployment_config, wait = FALSE, inference_config = inference_config)

# Delete service
delete_local_webservice(service)
