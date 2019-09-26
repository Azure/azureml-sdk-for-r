# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

library("azureml")

ws <- load_workspace_from_config()

# create aml compute
cluster_name <- "rcluster"
compute_target <- get_compute(ws, cluster_name = cluster_name)
if (is.null(compute_target)) {
  vm_size <- "STANDARD_NC6"
  compute_target <- create_aml_compute(workspace = ws,
                                       cluster_name = cluster_name,
                                       vm_size = vm_size,
                                       max_nodes = 1)
}
wait_for_compute(compute_target)

# define estimator
est <- estimator(source_directory = ".",
                 entry_script = "train_script.R",
                 compute_target = compute_target)

experiment_name <- "train-then-deploy-model"
exp <- experiment(ws, experiment_name)

run <- submit_experiment(est, exp)
wait_for_run_completion(run, show_output = TRUE)

# register the model
model <- run$register_model(model_name = "model.rds", 
                            model_path = "model.rds")

r_env <- environment(name="r_env")

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
