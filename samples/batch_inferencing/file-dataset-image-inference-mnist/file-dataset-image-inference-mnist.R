library(azuremlsdk)
library(jsonlite)


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
mnist_data <- register_azure_blob_container_datastore(
                            ws,
                            datastore_name = "mnist_datastore",
                            container_name = "sampledata",
                            account_name = "pipelinedata")

path_on_datastore <- mnist_data$path('mnist')
input_mnist_ds <- azureml$core$Dataset$File$from_files(path=path_on_datastore, validate=FALSE)
registered_mnist_ds <- input_mnist_ds$register(ws, "mnist_sample_data", create_new_version = TRUE)
named_mnist_ds <- registered_mnist_ds$as_named_input("mnist_sample_data")

registered_mnist_ds$to_path()

# Setup output data
output_folder <- azureml$pipeline$core$PipelineData(name = 'inferences', 
                                                    datastore = ws$get_default_datastore(), 
                                                    output_path_on_compute = "mnist/results")

# Setup batch environment used for the run
# Issues
# https://msdata.visualstudio.com/Vienna/_workitems/edit/543502, 
# https://msdata.visualstudio.com/Vienna/_workitems/edit/543503
batch_env <- r_environment("predict_environment", 
                             environment_variables = list(env1 = "val1"),
                             custom_docker_image = "ninhu/batchinferencing")

# register the model
model <- register_model(ws, 
                        model_path = "models/", 
                        model_name = "mnist",
                        description = "Mnist trained tensorflow model")

# Create runconfig and pipeline step
parallel_run_config <- azureml$contrib$pipeline$steps$ParallelRunConfig(
                        source_directory = ".",
                        entry_script = "_score_wrapper.py",
                        mini_batch_size = '5',
                        output_action = 'append_row',
                        environment = batch_env,
                        compute_target = compute_target,
                        node_count = 2L,
                        run_invocation_timeout = 300L,
                        error_threshold = 100L)


parallel_run_step <- azureml$contrib$pipeline$steps$ParallelRunStep(
                        name = 'predict-digits-mnist',
                        inputs = list(named_mnist_ds),
                        output = output_folder,
                        parallel_run_config = parallel_run_config,
                        models = list(model),
                        arguments = list(),
                        allow_reuse = FALSE)

azureml$core$Workspace$"__repr__" <- function(self) {
  sprintf("create_workspace(name=\"%s\", subscription_id=\"%s\", resource_group=\"%s\")", 
          self$"_workspace_name",
          self$"_subscription_id",
          self$"_resource_group")
  }
ws


tryCatch(
  expr = {
    pipeline <- azureml$pipeline$core$Pipeline(workspace = ws, steps = c(parallel_run_step))
  },
  error = function(e) {
    print(e)
  }
)

# Submit the parallel run 
run <- azureml$core$Experiment(ws, 'batch_mnist')$submit(pipeline)

run$wait_for_completion(show_output = TRUE)

batch_run <- reticulate::iterate(run$get_children())[[1]]
batch_output <- batch_run$get_output_data("inferences")
batch_output$download(local_path = "inferencing_results")

result_file <- list.files(pattern = "parallel_run_step.txt", recursive = TRUE)
head(read.table(result_file), 10)

           