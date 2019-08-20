library(azureml)
library(jsonlite)

# set working directory to current dir before running the sample
setwd("D:\\Code\\azureml-sdk-for-r\\samples\\inference")

# load workspace
ws <- load_workspace_from_config(".")

# training
estimator <- create_estimator(".", compute_target = "gpu-std-nc6", entry_script = "train.R")

experiment_name <- "train-r-script-then-deploy"
exp <- experiment(ws, experiment_name)

run <- submit_experiment(estimator, exp)
wait_for_run_completion(run, show_output = TRUE)

get_run_metrics(run)

# register the model or load existing model
# inference team suggest to use file name as model name otherwise
# might run into some issue when get model path
#model <- run$register_model(model_name = "model.rds", model_path = "outputs/model.rds")
model <- azureml$core$model$Model(ws, name="model.rds")

r_env <- azureml$core$environment$Environment(name="r_env")
r_env$python$user_managed_dependencies <- TRUE
r_env$docker$enabled <- TRUE
# TODO: rpy2 needs to be added to base image
# In this sample, I am using my own image from workspace ACR,
# but using pre-built r-base image from vienna ACR (viennaprivate.azurecr.io) should be also working
r_env$docker$base_image <- "r-base:cpu"
#r_env$docker$base_image_registry$address <- "viennaprivate.azurecr.io"
r_env$docker$base_image_registry$address <- "ninhuadhacrrhgxycwt.azurecr.io"
r_env$inferencing_stack_version='latest'

# 1) Regarding R wrapper for inference config, we can consider exposing the
#    parameter for accepting packages similar to what we did to estimator
# 2) you have to specify the source_directory in order to deploy more than one file
#    otherwise, only score.py will be deployed
inference_config <- azureml$core$model$InferenceConfig(
    entry_script = "score.py",
    source_directory=".",
    environment = r_env)

# Which types of deployment config we need to support in R SDK? local, ACI, AKS??
#deployment_config <- azureml$core$webservice$AciWebservice$deploy_configuration(cpu_cores=1, memory_gb=1)
# Use below config for local debugging
deployment_config <- azureml$core$webservice$LocalWebservice$deploy_configuration(port=8890L)

# deployment
service <- azureml$core$model$Model$deploy(ws, 'test', list(model), inference_config, deployment_config)
service$wait_for_deployment(TRUE)

# State always return "deploying" even if it's actually completed
# Need to fire a bug for inference
service$state
service$get_logs()

# inferecing...

# versicolor
plant <- data.frame(Sepal.Length=6.4, Sepal.Width=2.8, Petal.Length=4.6, Petal.Width=1.8)
# setosa
plant <- data.frame(Sepal.Length=5.1, Sepal.Width=3.5, Petal.Length=1.4, Petal.Width=0.2)
# virginica
plant <- data.frame(Sepal.Length=6.7, Sepal.Width=3.3, Petal.Length=5.2, Petal.Width=2.3)

service$run(input_data=toJSON(plant))
