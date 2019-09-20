context("webservice tests")

test_that("create, get, generate keys of, and delete webservice",
{
  ws <- existing_ws
  
  tmp_dir_name <- "tmp_dir"
  model_name <- "dummy_model.data"
  dir.create(tmp_dir_name)
  file.create(file.path(tmp_dir_name, model_name))
  
  # register the model
  model <- register_model(ws, tmp_dir_name, model_name)
  
  # Create a new environment
  env <- environment(name = "newenv")
  env$register(ws)
  
  # Create the inference config to use for Webservice
  config <- inference_config(entry_script = "dummy_score.py", environment = env)
  
  # Create local deployment config  
  localconfig = local_webservice_deployment_config()

  # Deploy the model
  service_name <- "local-service"
  service <- deploy_model(ws, service_name, models = c(model), inference_config = config,
                          deployment_config = localconfig)
  
  wait_for_deployment(service, show_output = TRUE)
  

  update_local_webservice(service)
  
  
  # delete the webservice
  delete_local_webservice(service)
})