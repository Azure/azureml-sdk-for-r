## R commands you can use to run models, etc manually from the Compute Instance
## The working directory should be the root folder of the azureml-sdk-for-r repository

accidents <- readRDS(  file.path(
  "vignettes/train-and-deploy-to-aci", #opt$data_folder, 
  "accidents.Rd"))
summary(accidents)

library(caret)

## Create data partition
train.pct <- 0.80
accident_idx <- createDataPartition(accidents$dead, p = train.pct, list = FALSE)
accident_trn <- accidents[accident_idx, ]
accident_tst <- accidents[-accident_idx, ]
## Utility function for calculating accuracy in test set
calc_acc = function(actual, predicted) {
  mean(actual == predicted)
}

## SLIDE: Training models
library(azuremlsdk)
ws <- load_workspace_from_config()
exp <- experiment(ws, "accident-caret")

cluster_name <- "research-cluster"
compute_target <- get_compute(ws, cluster_name = cluster_name)
if (is.null(compute_target)) {
  compute_target <- create_aml_compute(workspace = ws,
                                       cluster_name = cluster_name,
                                       vm_size = "STANDARD_D2_V2",
                                       vm_priority = "lowpriority",
                                       min_nodes = 1,
                                       max_nodes = 4)
  
  wait_for_provisioning_completion(compute_target, show_output = TRUE)
}

ds <- get_default_datastore(ws)
target_path <- "accidentdata"

train_pct_exp <- 0.85
## GLM model
exp <- experiment(ws, "accident")
est <- estimator(source_directory = "./vignettes/train-and-deploy-to-aci",
                 entry_script = "accident-glm.R",
                 script_params = list("--data_folder" = ds$path(target_path),
                                      "--percent_train" = train_pct_exp),
                 compute_target = compute_target
)

run <- submit_experiment(exp, est)
#view_run_details(run)

## KNN model
exp <- experiment(ws, "accident")
est <- estimator(source_directory = "./vignettes/train-and-deploy-to-aci",
                 entry_script = "accident-knn.R",
                 script_params = list("--data_folder" = ds$path(target_path),
                                      "--percent_train" = train_pct_exp),
                 compute_target = compute_target
)

run <- submit_experiment(exp, est)
#view_run_details(run)

## GLMNET model
exp <- experiment(ws, "accident")
est <- estimator(source_directory = "./vignettes/train-and-deploy-to-aci",
                 entry_script = "accident-glmnet.R",
                 script_params = list("--data_folder" = ds$path(target_path),
                                      "--percent_train" = train_pct_exp),
                 compute_target = compute_target
)

run <- submit_experiment(exp, est)
#view_run_details(run)
