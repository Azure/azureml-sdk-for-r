context("model tests")
source("utils.R")

test_that("get, register, download, serialize, deserialize and delete model", {
  skip_if_no_subscription()
  ws <- existing_ws
  
  tmp_dir_name <- "tmp_dir"
  tmp_dir_path <- file.path(tempdir(), tmp_dir_name)
  model_name <- "dummy_model.data"
  dir.create(tmp_dir_path)
  file.create(file.path(tmp_dir_path, model_name))
  
  # register the model (with datasets)
  ds <- get_default_datastore(ws)

  file_name <- "iris.csv"
  upload_files_to_datastore(ds,
                            files = list(file.path(".", file_name)),
                            target_path = 'train-dataset/tabular/',
                            overwrite = TRUE)
  
  train_ds <- create_tabular_dataset_from_delimited_files(ds$path('train-dataset/tabular/iris.csv'))
  val_ds <- create_tabular_dataset_from_delimited_files(ds$path('train-dataset/tabular/iris.csv'))
  infer_ds <- create_tabular_dataset_from_delimited_files(ds$path('train-dataset/tabular/iris.csv'))

  model <- register_model(ws, tmp_dir_path, model_name,
                          datasets = list(list("training", train_ds),
                                          list("validation", val_ds),
                                          list("inferencing", infer_ds)))
  
  # get model
  ws_model <- get_model(ws, model_name)

  expect_equal(model_name, ws_model$name)

  # download model    
  download_dir <- file.path(tempdir(),"downloaded")
  dir.create(download_dir)
  path <- download_model(model, download_dir)
  expect_equal(file.exists(file.path(download_dir, tmp_dir_name, model_name)),
               TRUE)
  
  # serialize and deserialize model
  model_payload <- serialize_model(model)
  deserialized_model <- deserialize_to_model(ws, model_payload)

  # delete the model
  delete_model(model)
})

test_that("create, check container registry and save model package", {
  skip_if_no_subscription()
  ws <- existing_ws
  
  tmp_dir_name <- "tmp_dir"
  tmp_dir_path <- file.path(tempdir(), tmp_dir_name)
  model_name <- "dummy_model.data"
  dir.create(tmp_dir_path)
  file.create(file.path(tmp_dir_path, model_name))
  
  # register the model
  model <- register_model(ws, tmp_dir_path, model_name)

  env <- r_environment("newenv")
  register_environment(env, ws)
  
  config <- inference_config(entry_script = "dummy_score.py",
                             environment = env)

  # Create ModelPackage with dockerfile
  model_package <- package_model(ws,
                                 c(model),
                                 config, 
                                 generate_dockerfile = TRUE)
  
  # wait for the package to be created
  wait_for_model_package_creation(model_package, show_output = TRUE)
  
  # Check package container registry
  cr <- get_model_package_container_registry(model_package)
  env_image_details <- env$get_image_details(ws)
  expect_equal(cr$address, env_image_details$dockerImage$registry$address)
  expect_equal(cr$username, env_image_details$dockerImage$registry$username)
  
  # save package files locally
  save_model_package_files(model_package,
                           output_directory = "downloaded_package")
  expect_equal(file.exists(file.path("downloaded_package", "Dockerfile")), TRUE)
  expect_equal(file.exists(file.path("downloaded_package",
                                     "model_config_map.json")), TRUE)
  
  # Create ModelPackage without dockerfile
  model_package <- package_model(ws, c(model), config)
  
  # wait for the package to be created
  wait_for_model_package_creation(model_package, show_output = TRUE)
  pull_model_package_image(model_package)
})

test_that("testpython score wrapper", {
  tmp_dir_name <- "tmp_dir"
  tmp_dir_path <- file.path(tempdir(), tmp_dir_name)
  dir.create(tmp_dir_path)

  entry_script <- "myscore.R"
  file.copy(entry_script, tmp_dir_path)
  generate_score_python_wrapper(entry_script, tmp_dir_path)
  expect_equal(file.exists(file.path(tmp_dir_path, "_generated_score.py")), TRUE)

  unlink(tmp_dir_path, recursive = TRUE)
})
