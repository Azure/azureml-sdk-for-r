context("datasets")
source("utils.R")

testthat("",{
  skip_if_no_subscription()
  ws <- existing_ws
  exp <- experiment(ws, experiment_name)
  ds <- get_default_datastore(ws)

  # upload files to datastore
  file_name <- "iris.csv"
  upload_files_to_datastore(ds,
                            files = list(file.path(".", file_name)),
                            target_path = 'train-dataset/tabular/',
                            overwrite = TRUE)
  dataset <- create_tabular_dataset_from_delimited_files(list(ds,
                                                              'train-dataset/tabular/iris.csv'))

  est <- estimator(".",
                   compute_target = "local",
                   cran_packages = c("ggplot2"),
                   inputs = dataset)
})