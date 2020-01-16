context("webservice tests")
source("utils.R")

test_that("create, get, generate keys of, and delete webservice", {
  skip('skip')
  ws <- existing_ws
  
  tmp_dir_name <- file.path(tempdir(), "tmp_dir")
  model_name <- "dummy_model.data"
  dir.create(tmp_dir_name)
  file.create(file.path(tmp_dir_name, model_name))
  
  # register the model
  model <- register_model(ws, tmp_dir_name, model_name)
  
  # Create the inference config to use for Webservice
  config <- inference_config(entry_script = "dummy_score.R")
  
  # Create ACI deployment config
  tags <- reticulate::py_dict('name', 'temp')
  aciconfig <- 
    azureml$core$webservice$AciWebservice$deploy_configuration(cpu_cores = 1,
                                                               memory_gb = 1,
                                                               tags = tags,
                                                               auth_enabled = T)
  # Deploy the model
  service_name <- paste("svc", build_num, sep="")
  service <- deploy_model(ws,
                          service_name,
                          models = c(model),
                          inference_config = config,
                          deployment_config = aciconfig)
  
  wait_for_deployment(service, show_output = TRUE)
  
  # Get webservice  
  service <- get_webservice(ws, name = service_name)

  # Check the logs
  logs <- get_webservice_logs(service)
  expect_equal(length(logs), 1)

  # Get the service keys  
  keys <- get_webservice_keys(service)
  expect_equal(length(keys), 2)

  # Try changing secondary key
  generate_new_webservice_key(service, key_type = 'Secondary')
  new_keys <- get_webservice_keys(service)
  expect_equal(length(new_keys), 2)

  # check if the new secondary key is different from the previous one  
  expect_false(keys[[2]] == new_keys[[2]])
  
  # delete the webservice
  delete_webservice(service)
})