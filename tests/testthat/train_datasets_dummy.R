library(azuremlsdk)

run <- get_current_run()
dataset <- get_input_dataset_from_run("iris", run)