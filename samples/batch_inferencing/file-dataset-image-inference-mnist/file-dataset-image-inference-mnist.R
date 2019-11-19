library(azuremlsdk)


ws <- load_workspace_from_config()

# Prepare AmlCompute cluster
cluster_name <- "gpu-std-nc6"
compute_target <- get_compute(ws, cluster_name = cluster_name)
if (is.null(compute_target)) {
  vm_size <- "STANDARD_D2_V2"
  compute_target <- create_aml_compute(workspace = ws,
                                       cluster_name = cluster_name,
                                       vm_size = vm_size,
                                       max_nodes = 2)

  wait_for_provisioning_completion(compute_target, show_output = TRUE)
}

# Create a FileDataset
# DataSet is required for batch inferencing as it will be used to partitition the data
# into mini-batches
mnist_data <- register_azure_blob_container_datastore(
                            ws,
                            datastore_name = "mnist_datastore",
                            container_name = "sampledata",
                            account_name = "pipelinedata")

path_on_datastore <- mnist_data$path('mnist')
input_mnist_ds <- azureml$core$Dataset$File$from_files(path=path_on_datastore, validate=FALSE)
registered_mnist_ds <- input_mnist_ds$register(ws, "mnist_sample_data", create_new_version = TRUE)
named_mnist_ds <- registered_mnist_ds$as_named_input("mnist_sample_data")

# Setup output data
# need a wrapper to hide PipelineData from customer
output_folder <- azureml$pipeline$core$PipelineData(name = 'inferences', 
                                                    datastore = ws$get_default_datastore(), 
                                                    output_path_on_compute = "mnist/results")

# Setup batch environment used for the run
# Issues
# https://msdata.visualstudio.com/Vienna/_workitems/edit/543502, 
# https://msdata.visualstudio.com/Vienna/_workitems/edit/543503
# The reason we use a custom docker image here is because pipeline doesn't support
# base_dockerfile yet. Once RSection is ready, we also need to inform pipeline team 
# to make according backend changes.
batch_env <- r_environment(name = "predict_environment",
                           environment_variables = list(env1 = "val1"),
                           custom_docker_image = "ninhu/batchinferencing")

# register the model
# please ntoe model is not required for batch-inferencing
model <- register_model(ws, 
                        model_path = "models/", 
                        model_name = "mnist",
                        description = "Mnist trained tensorflow model")

# parallel_run_config (wrapper of the pipeline)
run_config <- parallel_run_config(name = "predict-digits-mnist",
                                  inputs = list(named_mnist_ds),
                                  output = output_folder,
                                  models = list(model),
                                  compute_target = compute_target,
                                  entry_script = "score.py",
                                  mini_batch_size = '5',
                                  output_action = 'append_row',
                                  node_count = 2L,
                                  run_invocation_timeout = 300L,
                                  error_threshold = 100L,
                                  environment = batch_env,
                                  workspace = ws)

# Submit the parallel run 
exp <- experiment(ws, 'batch_mnist')
run <- submit_experiment(exp, run_config)
wait_for_run_completion(run)

# Get the results
batch_run <- reticulate::iterate(run$get_children())[[1]]
batch_output <- batch_run$get_output_data("inferences")
batch_output$download(local_path = "inferencing_results")

# Peek first 10 rows
result_file <- list.files(pattern = "parallel_run_step.txt", recursive = TRUE)
head(read.table(result_file), 10)
