#### Code from slides
## This code is excerpted from experiments-with-R.Rmd,
## edited and reformatted for use on slides

## SLIDE: Prepare Data

library(azuremlsdk)
ws <- load_workspace_from_config()


nassCDS <- read.csv("nassCDS.csv")
# Lots of cleaning code
saveRDS(accidents, 
        file="accidents.Rd")


ds <- get_default_datastore(ws)
target_path <- "accidentdata"
upload_files_to_datastore(ds,
                          list("./accidents.Rd"),
                          target_path = target_path,
                          overwrite = TRUE)





## SLIDE: Compute

ws <- load_workspace_from_config()
compute_target <- create_aml_compute(
  workspace = ws,
  cluster_name = "rcluster",
  vm_size = "STANDARD_D2_V2",
  vm_priority = "lowpriority",
  min_nodes = 0,
  max_nodes = 2)


## SLIDE: Experiments
exp <- experiment(ws, "accident")
est <- estimator(source_directory = ".",
                 entry_script = "accident-glmnet.R",
                 script_params = list(
                   "--data_folder" = ds$path(target_path),
                   "--percent_train" = 0.75),
                 compute_target = compute_target)
run.glmnet <- submit_experiment(exp, est)

## Register Model
model <- register_model(
  ws, 
  model_path = "outputs/model.rds", 
  model_name = "accidents_model_caret",
  description = "Predict accident probability")



r_env <- r_environment(name = "basic_env",
                       cran_packages="caret")

inference_config <- inference_config(
  entry_script = "accident_predict_caret.R",
  source_directory = ".",
  environment = r_env)

## Deploy model to container service
aci_config <- 
  aci_webservice_deployment_config(
    cpu_cores = 1, memory_gb = 0.5)

aci_service <- deploy_model(ws, 
                            'accident-pred-caret', 
                            list(model), 
                            inference_config, 
                            aci_config)

accident.endpoint <- get_webservice(
  ws, "accident-pred-caret")$scoring_uri


## Integrate into app

library(httr)
v <- POST(accident.endpoint, 
          body=input, 
          encode="json")

prob <- content(v)[[1]]*100





## R commands you can use to run models, etc manually from the Compute Instance
## The working directory should be the root folder of the azureml-sdk-for-r repository

accidents <- readRDS(  file.path(
  "vignettes/experiments-with-R/accidentdata", #opt$data_folder, 
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

### Test endpoint
accident.endpoint <- get_webservice(ws, "accident-predict-caret")$scoring_uri

newdata <- data.frame( # valid values shown below
  dvcat="10-24",        # "1-9km/h" "10-24"   "25-39"   "40-54"   "55+"  
  seatbelt="none",      # "none"   "belted"  
  frontal="frontal",    # "notfrontal" "frontal"
  sex="f",              # "f" "m"
  ageOFocc=25,          # age in years, 16-97
  yearVeh=2002,         # year of vehicle, 1955-2003
  airbag="none",        # "none"   "airbag"   
  occRole="pass"        # "driver" "pass"
)

accident_model <- readRDS("outputs/model.rds")
predict(accident_model, newdata=newdata, type="prob")[,"dead"]


v <- POST(accident.endpoint, body=newdata, encode="json")
content(v)[[1]]

