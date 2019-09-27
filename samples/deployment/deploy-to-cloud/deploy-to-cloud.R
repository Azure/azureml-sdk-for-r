# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

library("azureml")

ws <- load_workspace_from_config()

# register the model
model <- register_model(ws, model_path = "model.rds", model_name = "model.rds")
r_env <- environment(name = "r_env", inferencing_stack_version = 'latest')

# create inference config
inference_config <- inference_config(
  entry_script = "score.R",
  source_directory=".",
  environment = r_env)

# create ACI deployment config
deployment_config <- aci_webservice_deployment_config(cpu_cores=1, memory_gb=1)

# deploy the webservice
service <- deploy_model(ws, 
                        'rservice', 
                        list(model), 
                        inference_config, 
                        deployment_config)
wait_for_deployment(service, show_output = TRUE)

# If you encounter any issue in deploying the webservice, please visit
# https://docs.microsoft.com/en-us/azure/machine-learning/service/how-to-troubleshoot-deployment

# Inferencing
# versicolor
plant <- data.frame(Sepal.Length=6.4, 
                    Sepal.Width=2.8, 
                    Petal.Length=4.6, 
                    Petal.Width=1.8)
# setosa
plant <- data.frame(Sepal.Length=5.1, 
                    Sepal.Width=3.5, 
                    Petal.Length=1.4, 
                    Petal.Width=0.2)
# virginica
plant <- data.frame(Sepal.Length=6.7, 
                    Sepal.Width=3.3, 
                    Petal.Length=5.2, 
                    Petal.Width=2.3)

predicted_val <- invoke_webservice(service, toJSON(plant))
