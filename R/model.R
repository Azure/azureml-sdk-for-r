# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Retrieve the Model object from the cloud.
#' @param workspace The workspace object containing the Model to retrieve
#' @param name Will retrieve the latest model with the corresponding name, if
#' it exists
#' @param id Will retrieve the model with the corresponding ID, if it exists
#' @param tags Optional, will filter based on the provided list, searching by
#' either 'key' or '[key, value]'.
#' @param properties Optional, will filter based on the provided list,
#' searching by either 'key' or '[key, value]'.
#' @param version When provided along with name, will get the specific version
#' of the specified named model, if it exists
#' @param run_id Optional, will filter based on the provided ID.
#' @return A model object, if one is found in the provided workspace
#' @export
get_model <- function(workspace,
                      name = NULL,
                      id = NULL,
                      tags = NULL,
                      properties = NULL,
                      version = NULL,
                      run_id = NULL) {
  model <- azureml$core$Model(workspace,
                              name,
                              id,
                              tags,
                              properties,
                              version,
                              run_id)
  invisible(model)
}

#' Register a model with the provided workspace.
#' @param workspace The workspace to register the model under
#' @param model_path String which points to the path on the local file system
#' where the model assets are located. This can be a direct pointer to a single
#' file or folder. If pointing to a folder, the child_paths parameter can be
#' used to specify individual files to bundle together as the Model object,
#' as opposed to using the entire contents of the folder.
#' @param model_name The name to register the model with
#' @param tags Dictionary of key value tags to give the model
#' @param properties Dictionary of key value properties to give the model.
#' These properties cannot be changed after model creation, however new key
#' value pairs can be added
#' @param description A text description of the model
#' @param child_paths If provided in conjunction with a model_path to a folder,
#' only the specified files will be bundled into the Model object.
#' @return The registered Model object
#' @export
register_model <- function(workspace,
                           model_path,
                           model_name,
                           tags = NULL,
                           properties = NULL,
                           description = NULL,
                           child_paths = NULL) {
  model <- azureml$core$Model$register(workspace,
                                       model_path,
                                       model_name,
                                       tags = tags,
                                       properties = properties,
                                       description = description,
                                       child_paths = child_paths)
  invisible(model)
}

#' Download model to target_dir of local file system.
#' @param model The model to download
#' @param target_dir Path to directory for where to download the model.
#' Defaults to "."
#' @param exist_ok Boolean to replace downloaded dir/files if exists.
#' Defaults to FALSE
#' @return string path to file or folder of model
#' @export
download_model <- function(model, target_dir = ".", exist_ok = FALSE) {
  model_path <- model$download(target_dir, exist_ok)
  invisible(model_path)
}

#' Convert this Model into a json serialized dictionary
#' @param model The model to download
#' @return The json representation of this Model
serialize_model <- function(model) {
  result <- model$serialize()
  invisible(result)
}

#' Convert a json object into a Model object.
#' @param workspace The workspace object the model is registered under
#' @param model_payload A json object to convert to a Model object
#' @return The Model representation of the provided json object
deserialize_to_model <- function(workspace, model_payload) {
  model <- azureml$core$Model$deserialize(workspace, model_payload)
  invisible(model)
}

#' Delete this model from its associated workspace.
#' @param model The model to download
#' @export
delete_model <- function(model) {
  model$delete()
}

#' Deploy a Webservice from zero or more model objects.
#' @param workspace A Workspace object to associate the Webservice with
#' @param name The name to give the deployed service. Must be unique to the
#' workspace, only consist of lowercase letters, numbers, or dashes, start with
#' a letter, and be between 3 and 32 characters long.
#' @param models A list of model objects. Can be an empty list.
#' @param inference_config An InferenceConfig object used to determine required
#' model properties.
#' @param deployment_config A WebserviceDeploymentConfiguration used to
#' configure the webservice. If one is not provided, an empty configuration
#' object will be used based on the desired target.
#' @param deployment_target A azureml.core.ComputeTarget to deploy the
#' Webservice to. As Azure Container Instances has no associated
#' azureml.core.ComputeTarget, leave this parameter as None to deploy to Azure
#' Container Instances.
#' @return A Webservice object corresponding to the deployed webservice
#' @export
deploy_model <- function(workspace,
                         name,
                         models,
                         inference_config,
                         deployment_config = NULL,
                         deployment_target = NULL) {
  webservice <- azureml$core$Model$deploy(workspace,
                                          name,
                                          models,
                                          inference_config,
                                          deployment_config,
                                          deployment_target)
  invisible(webservice)
}

#' Create a model package in the form of a Docker image or Dockerfile build
#' context
#' @param workspace The workspace in which to create the package.
#' @param models A list of Model objects to include in the package. Can be an
#' empty list.
#' @param inference_config An InferenceConfig object to configure the
#' operation of the models. This must include an Environment object.
#' @param generate_dockerfile Whether to create a Dockerfile that can be run
#' locally instead of building an image.
#' @return A ModelPackage object.
#' @export
package_model <- function(workspace,
                          models,
                          inference_config,
                          generate_dockerfile = FALSE) {
  model_package <- azureml$core$Model$package(workspace,
                                              models,
                                              inference_config,
                                              generate_dockerfile)
  invisible(model_package)
}

#' Return a ContainerRegistry object for where the image
#' (or base image, for Dockerfile packages) is stored.
#' @param package Package created with model(s) and dependencies.
#' @return ContainerRegistry object
#' @export
get_model_package_container_registry <- function(package) {
  package$get_container_registry()
}

#' Retrieve the package creation logs.
#' @param package Package created with model(s) and dependencies.
#' @param decode Whether to decode the raw log bytes to a string.
#' @param offset Byte offset from which to start reading the logs.
#' @return Package creation logs.
#' @export
get_model_package_creation_logs <- function(package,
                                            decode = TRUE,
                                            offset = 0) {
  package$get_logs(decode, offset)
}

#' Pull the package output to the local machine.
#' This can only be used with a Docker image package.
#' @param package Package created with model(s) and dependencies.
#' @export
pull_model_package_image <- function(package) {
  package$pull()
}

#' Save the package output to a local directory.
#' This can only be used with a Dockerfile package.
#' @param package Package created with model(s) and dependencies.
#' @param output_directory Local directory that will be created to contain
#' the contents of the package.
#' @export
save_model_package_files <- function(package, output_directory) {
  package$save(output_directory)
}

#' Wait for the package to finish creating.
#' @param package Package created with model(s) and dependencies.
#' @param show_output Boolean option to print more verbose output. Defaults to
#' FALSE.
#' @export
wait_for_model_package_creation <- function(package, show_output = FALSE) {
  package$wait_for_creation(show_output)
}

#' Creates the Model deployment config specific to model deployments.
#' @param entry_script Path to local file that contains the code to run for the
#' image.
#' @param source_directory paths to folders that contains all files to create
#' the image.
#' @param description A description to give this image.
#' @param environment An environment object to use for the deployment.
#' Doesn't have to be registered. A user should provide either this, or the
#' other parameters, not both. The individual parameters will NOT serve
#' as an override for the environment object. Exceptions include
#' `entry_script`, `source_directory` and `description`.
#' @return An InferenceConfig object
#' @export
inference_config <- function(entry_script,
                             source_directory = NULL,
                             description = NULL,
                             environment = NULL) {
  saved_image <- NULL
  generate_score_python_wrapper(entry_script, source_directory)
  if (!is.null(environment)) {
      environment$inferencing_stack_version <- "latest"
      
      # this is a temporary fix for github issue #101
      saved_image <- environment$docker$base_image
      environment$docker$base_image <- "temp_image"
  }

  inference_config <- azureml$core$model$InferenceConfig(
    entry_script = "_generated_score.py",
    source_directory = source_directory,
    description = description,
    environment = environment)

  inference_config$environment$docker$base_image <- saved_image
  invisible(inference_config)
}

#' Generate _generated_score.py file for the corresponding entry_script file
#' @param entry_script Path to local file that contains the code to run for
#' the image.
#' @param source_directory paths to folders that contains all files to
#' create the image.
generate_score_python_wrapper <- function(entry_script, source_directory) {
  score_py_template <- sprintf("# This is auto-generated python wrapper.
import rpy2.robjects as robjects
import os
import json

def init():
    global r_run

    score_r_path = os.path.join(os.path.dirname(
      os.path.realpath(__file__)),
      \"%s\")

    # handle path for windows os
    score_r_path = score_r_path.replace('\\\\', '/')
    robjects.r.source(\"{}\".format(score_r_path))
    r_run = robjects.r['init']()

def run(input_data):
    dataR = r_run(input_data)[0]
    return json.loads(dataR)",
                               entry_script)

  if (is.null(source_directory))
    source_directory <- "."
  score_py_file_path <- file.path(source_directory, "_generated_score.py")
  py_file <- file(score_py_file_path, open = "w")
  writeLines(score_py_template, py_file)
  close(py_file)
  invisible(NULL)
}
