# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Get a registered model
#' @description
#' Returns a `Model` object for an existing model that has been
#' previously registered to the given workspace.
#' @param workspace The `Workspace` object.
#' @param name Retrieve the latest model with the corresponding
#' name (a string), if it exists.
#' @param id Retrieve the model with the corresponding ID (a string),
#' if it exists.
#' @param tags (Optional) Retrieve the model filtered based on the
#' provided tags (a list), searching by either 'key' or
#' 'list(key, value)'.
#' @param properties (Optional) Retrieve the model filter based on the
#' provided properties (a list), searching by either 'key' or
#' 'list(key, value)'.
#' @param version (Optional) An int of the version of a model to
#' retrieve, when provided along with `name`. The specific version of
#' the specified named model will be returned, if it exists.
#' @param run_id (Optional) Retrieve the model filterd by the provided
#' run ID (a string) the model was registered from, if it exists.
#' @return The `Model` object.
#' @export
#' @md
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

#' Register a model to a given workspace
#' @description
#' Register a model to the given workspace. A registered model is a logical
#' container for one or more files that make up your model. For example, if
#' you have a model that's stored in multiple files, you can register them
#' as a single model in your workspace. After registration, you can then
#' download or deploy the registered model and receive all the files that
#' were registered.
#'
#' Models are identified by name and version. Each time you register a
#' model with the same name as an existing one, your workspace's model
#' registry assumes that it's a new version. The version is incremented,
#' and the new model is registered under the same name.
#' @param workspace The `Workspace` object.
#' @param model_path A string of the path on the local file system where
#' the model assets are located. This can be a direct pointer to a single
#' file or folder. If pointing to a folder, the `child_paths` parameter can
#' be used to specify individual files to bundle together as the `Model`
#' object, as opposed to using the entire contents of the folder.
#' @param model_name A string of the name to register the model with.
#' @param datasets A list of two-element lists where the first element is the
#' dataset-model relationship and the second is the corresponding dataset, e.g.
#' `list(list("training", train_ds), list("inferencing", infer_ds))`. Valid
#' values for the data-model relationship are 'training', 'validation', and 'inferencing'.
#' @param tags A named list of key-value tags to give the model, e.g.
#' `list("key" = "value")`
#' @param properties A named list of key-value properties to give the model,
#' e.g. `list("key" = "value")`.
#' @param description A string of the text description of the model.
#' @param child_paths A list of strings of child paths of a folder specified
#' by `model_name`. Must be provided in conjunction with a `model_path`
#' pointing to a folder; only the specified files will be bundled into the
#' `Model` object.
#' @param sample_input_dataset Sample input dataset for the registered model.
#' @param sample_output_dataset Sample output dataset for the registered model.
#' @param resource_configuration `ResourceConfiguration`` object to run the registered model.
#' @return The `Model` object.
#' @export
#' @section Examples:
#' Registering a model from a single file:
#' ```
#' ws <- load_workspace_from_config()
#' model <- register_model(ws,
#'                         model_path = "my_model.rds",
#'                         model_name = "my_model",
#'                         datasets = list(list("training", train_dataset)))
#' ```
#' @seealso [resource_configuration()]
#' @md
register_model <- function(workspace,
                           model_path,
                           model_name,
                           datasets = NULL,
                           tags = NULL,
                           properties = NULL,
                           description = NULL,
                           child_paths = NULL,
                           sample_input_dataset = NULL,
                           sample_output_dataset = NULL,
                           resource_configuration = NULL) {

  if (!is.null(datasets)) {
    user_ds_scenarios <- strsplit(unlist(lapply(datasets, "[", 1)), " ")
    valid_ds_scenarios <- c("training", "inferencing", "validation")
    if (!(all(user_ds_scenarios %in% valid_ds_scenarios))) {
      stop("One or more of your data-model relationship values is invalid.
           Valid values are 'training', 'validation', and 'inferencing'")
    }
  }

  model <- azureml$core$Model$register(workspace,
                                model_path,
                                model_name,
                                tags = tags,
                                properties = properties,
                                description = description,
                                child_paths = child_paths,
                                datasets = datasets,
                                sample_input_dataset = sample_input_dataset,
                                sample_output_dataset = sample_output_dataset,
                                resource_configuration = resource_configuration)
  invisible(model)
}

#' Download a model to the local file system
#' @description
#' Download a registered model to the `target_dir` of your local file
#' system.
#' @param model The `Model` object.
#' @param target_dir A string of the path to the directory on your local
#' file system for where to download the model to. Defaults to ".".
#' @param exist_ok If `FALSE`, replace the downloaded folder/file if they
#' already exist.
#' @return A string of the path to the file or folder of the downloaded
#' model.
#' @export
#' @examples
#' \dontrun{
#' ws <- load_workspace_from_config()
#' model <- get_model(ws, name = "my_model", version = 2)
#' download_model(model, target_dir = tempdir(), exist_ok = TRUE)
#' }
#' @md
download_model <- function(model, target_dir = ".", exist_ok = FALSE) {
  model_path <- model$download(target_dir, exist_ok)
  invisible(model_path)
}

#' Convert a `Model` object into a json serialized dictionary
#' @param model The `Model` object.
#' @return The json representation of the `model`.
#' @noRd
serialize_model <- function(model) {
  result <- model$serialize()
  invisible(result)
}

#' Convert a json object into a `Model` object.
#' @param workspace The `Workspace` object the model is registered in.
#' @param model_payload A json object to convert to a `Model` object.
#' @return The `Model` object representation of the provided json object.
#' @noRd
deserialize_to_model <- function(workspace, model_payload) {
  model <- azureml$core$Model$deserialize(workspace, model_payload)
  invisible(model)
}

#' Delete a model from its associated workspace
#' @description
#' Delete the registered model from its associated workspace. Note that
#' you cannot delete a registered model that is being used by an active
#' web service deployment.
#' @param model The `Model` object.
#' @return None
#' @export
#' @md
delete_model <- function(model) {
  model$delete()
}

#' Deploy a web service from registered model(s)
#' @description
#' Deploy a web service from zero or more registered models. Types of web
#' services that can be deployed are `LocalWebservice`, which will deploy
#' a model locally, and `AciWebservice` and `AksWebservice`, which will
#' deploy a model to Azure Container Instances (ACI) and Azure Kubernetes
#' Service (AKS), respectively.The type of web service deployed will be
#' determined by the `deployment_config` specified. Returns a `Webservice`
#' object corresponding to the deployed web service.
#' @param workspace The `Workspace` object.
#' @param name A string of the name to give the deployed service. Must be
#' unique to the workspace, only consist of lowercase letters, numbers, or
#' dashes, start with a letter, and be between 3 and 32 characters long.
#' @param models A list of `Model` objects. Can be an empty list.
#' @param inference_config The `InferenceConfig` object used to describe
#' how to configure the model to make predictions.
#' @param deployment_config The deployment configuration of type
#' `LocalWebserviceDeploymentConfiguration`,
#' `AciServiceDeploymentConfiguration`, or
#' `AksServiceDeploymentConfiguration` used to configure the web service.
#' The deployment configuration is specific to the compute target that will
#' host the web service. For example, when you deploy a model locally, you
#' must specify the port where the service accepts requests. If `NULL`, an
#' empty configuration object will be used based on the desired target
#' specified by `deployment_target`.
#' @param deployment_target The compute target to deploy the model to.
#' You will only need to specify this parameter if you are deploy to AKS,
#' in which case provide an `AksCompute` object. If you are deploying locally
#' or to ACI, leave this parameter as `NULL`.
#' @return The `LocalWebservice`, `AciWebservice`, or `AksWebservice` object.
#' @export
#' @section Details:
#' If you encounter any issue in deploying your web service, please visit this
#' [troubleshooting guide](https://docs.microsoft.com/en-us/azure/machine-learning/service/how-to-troubleshoot-deployment).
#' @examples
#' \dontrun{
#' ws <- load_workspace_from_config()
#' model <- get_model(ws, name = "my_model")
#' r_env <- r_environment(name = "r_env")
#' inference_config <- inference_config(entry_script = "score.R",
#'                                      source_directory = ".",
#'                                      environment = r_env)
#' deployment_config <- aci_webservice_deployment_config(cpu_cores = 1, memory_gb = 1)
#' service <- deploy_model(ws,
#'                         name = "my_webservice",
#'                         models = list(model),
#'                         inference_config = inference_config,
#'                         deployment_config = deployment_config)
#' wait_for_deployment(service, show_output = TRUE)
#' }
#' @seealso
#' `inference_config()`, `aci_webservice_deployment_config()`,
#' `aks_webservice_deployment_config()`, `local_webservice_deployment_config()`
#' @md
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

#' Create a model package that packages all the assets needed to host a
#' model as a web service
#' @description
#' In some cases, you might want to create a Docker image without deploying
#' the model (for example, if you plan to deploy to Azure App Service). Or
#' you might want to download the image and run it on a local Docker installation.
#' You might even want to download the files used to build the image, inspect
#' them, modify them, and build the image manually.
#'
#' Model packaging enables you to do these things. `package_model()` packages all
#' the assets needed to host a model as a web service and allows you to download
#' either a fully built Docker image or the files needed to build one. There are
#' two ways to use model packaging:
#' * **Download a packaged model**: Download a Docker image that contains the model
#' and other files needed to host it as a web service.
#' * **Generate a Dockerfile**: Download the Dockerfile, model, entry script, and
#' other assets needed to build a Docker image. You can then inspect the files or
#' make changes before you build the image locally. To use this method, make sure
#' to set `generate_dockerfile = TRUE`.
#' With either scenario, you will need to have Docker installed in your
#' development environment.
#' @param workspace The `Workspace` object.
#' @param models A list of `Model` objects to include in the package. Can
#' be an empty list.
#' @param inference_config The `InferenceConfig` object to configure the
#' operation of the models.
#' @param generate_dockerfile If `TRUE`, will create a Dockerfile that
#' can be run locally instead of building an image.
#' @return The `ModelPackage` object.
#' @export
#' @examples
#' # Package a registered model
#' \dontrun{
#' ws <- load_workspace_from_config()
#' model <- get_model(ws, name = "my_model")
#' r_env <- r_environment(name = "r_env")
#' inference_config <- inference_config(entry_script = "score.R",
#'                                      source_directory = ".",
#'                                      environment = r_env)
#' package <- package_model(ws,
#'                          models = list(model),
#'                          inference_config = inference_config)
#' wait_for_model_package_creation(show_output = TRUE)
#' }
#' @seealso
#' `wait_for_model_package_creation()`, `get_model_package_container_registry()`,
#' `get_model_package_creation_logs()`, `pull_model_package_image()`,
#' `save_model_package_files()`
#' @md
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

#' Get the Azure container registry that a packaged model uses
#' @description
#' Return a `ContainerRegistry` object for where the image
#' (or base image, for Dockerfile packages) is stored in an
#' Azure container registry.
#' @param package The `ModelPackage` object.
#' @return The `ContainerRegistry` object.
#' @export
#' @examples
#' # Given a ModelPackage object,
#' # get the container registry information
#' \dontrun{
#' container_registry <- get_model_package_container_registry(package)
#' address <- container_registry$address
#' username <- container_registry$username
#' password <- container_registry$password
#' }
#'
#' # To then authenticate Docker with the Azure container registry from
#' # a shell or command-line session, use the following command, replacing
#' # <address>, <username>, and <password> with the values retrieved
#' # from above:
#' # ```bash
#' # docker login <address> -u <username> -p <password>
#' # ```
#' @seealso
#' `container_registry()`
#' @md
get_model_package_container_registry <- function(package) {
  package$get_container_registry()
}

#' Get the model package creation logs
#' @description
#' Retrieve the creation logs from packaging a model with
#' `package_model()`.
#' @param package The `ModelPackage` object.
#' @param decode If `TRUE`, decode the raw log bytes to a string.
#' @param offset An int of the byte offset from which to start
#' reading the logs.
#' @return A string or character vector of package creation logs.
#' @export
#' @md
get_model_package_creation_logs <- function(package,
                                            decode = TRUE,
                                            offset = 0) {
  package$get_logs(decode, offset)
}

#' Pull the Docker image from a `ModelPackage` to your local
#' Docker environment
#' @description
#' Pull the Docker image from a created `ModelPackage` to your
#' local Docker environment. The output of this call will
#' display the name of the image. For example:
#' `Status: Downloaded newer image for myworkspacef78fd10.azurecr.io/package:20190822181338`.
#'
#' This can only be used with a Docker image `ModelPackage` (where
#' `package_model()` was called with `generate_dockerfile = FALSE`).
#'
#' After you've pulled the image, you can start a local container based
#' on this image using Docker commands.
#' @param package The `ModelPackage` object.
#' @return None
#' @export
#' @seealso
#' `package_model()`
#' @md
pull_model_package_image <- function(package) {
  package$pull()
}

#' Save a Dockerfile and dependencies from a `ModelPackage` to
#' your local file system
#' @description
#' Download the Dockerfile, model, and other assets needed to build
#' an image locally from a created `ModelPackage`.
#'
#' This can only be used with a Dockerfile `ModelPackage` (where
#' `package_model()` was called with `generate_dockerfile = TRUE` to
#' indicated that you wanted only the files and not a fully built image).
#'
#' `save_model_package_files()` downloads the files needed to build the
#' image to the `output_directory`. The Dockerfile included in the saved
#' files references a base image stored in an Azure container registry.
#' When you build the image on your local Docker installation, you will
#' need the address, username, and password to authenticate to the registry.
#' You can get this information using `get_model_package_container_registry()`.
#' @param package The `ModelPackage` object.
#' @param output_directory A string of the local directory that
#' will be created to contain the contents of the package.
#' @return None
#' @export
#' @seealso
#' `package_model()`, `get_model_package_container_registry()`
#' @md
save_model_package_files <- function(package, output_directory) {
  package$save(output_directory)
}

#' Wait for a model package to finish creating
#' @description
#' Wait for a model package creation to reach a terminal state.
#' @param package The `ModelPackage` object.
#' @param show_output If `TRUE`, print more verbose output. Defaults to
#' `FALSE`.
#' @return None
#' @export
#' @md
wait_for_model_package_creation <- function(package, show_output = FALSE) {
  package$wait_for_creation(show_output)
}

#' Create an inference configuration for model deployments
#' @description
#' The inference configuration describes how to configure the model to make
#' predictions. It references your scoring script (`entry_script`) and is
#' used to locate all the resources required for the deployment. Inference
#' configurations use Azure Machine Learning environments (see `r_environment()`)
#' to define the software dependencies needed for your deployment.
#' @param entry_script A string of the path to the local file that contains
#' the code to run for making predictions.
#' @param source_directory A string of the path to the local folder
#' that contains the files to package and deploy alongside your model, such as
#' helper files for your scoring script (`entry_script`). The folder must
#' contain the `entry_script`.
#' @param description (Optional) A string of the description to give this
#' configuration.
#' @param environment An `Environment` object to use for the deployment. The
#' environment does not have to be registered.
#' @return The `InferenceConfig` object.
#' @export
#' @section Defining the entry script:
#' To deploy a model, you must provide an entry script that accepts requests,
#' scores the requests by using the model, and returns the results. The
#' entry script is specific to your model. It must understand the format of
#' the incoming request data, the format of the data expected by your model,
#' and the format of the data returned to clients. If the request data is in a
#' format that is not usable by your model, the script can transform it into
#' an acceptable format. It can also transform the response before returning
#' it to the client.
#'
#' The entry script must contain an `init()` method that loads your model and
#' then returns a function that uses the model to make a prediction based on
#' the input data passed to the function. Azure ML runs the `init()` method
#' once, when the Docker container for your web service is started. The
#' prediction function returned by `init()` will be run every time the service
#' is invoked to make a prediction on some input data. The inputs and outputs
#' of this prediction function typically use JSON for serialization and
#' deserialization.
#'
#' To locate the model in your entry script (when you load the model in the
#' script's `init()` method), use `AZUREML_MODEL_DIR`, an environment variable
#' containing the path to the model location. The environment variable is
#' created during service deployment, and you can use it to find the location
#' of your deployed model(s).
#'
#' To get the path to a file in a model, combine the environment variable
#' with the filename you're looking for. The filenames of the model files
#' are preserved during registration and deployment.
#'
#' Single model example:
#' ```
#' model_path <- file.path(Sys.getenv("AZUREML_MODEL_DIR"), "my_model.rds")
#' ```
#' Multiple model example:
#' ```
#' model1_path <- file.path(Sys.getenv("AZUREML_MODEL_DIR"), "my_model/1/my_model.rds")
#' ```
#' @seealso
#' `r_environment()`, `deploy_model()`
#' @md
inference_config <- function(entry_script,
                             source_directory = ".",
                             description = NULL,
                             environment = NULL) {
  if (is.null(environment)) {
    environment <- r_environment("inferenceenv")
  }

  generate_score_python_wrapper(entry_script, source_directory)
  environment$inferencing_stack_version <- "latest"

  inference_config <- azureml$core$model$InferenceConfig(
    entry_script = "_generated_score.py",
    source_directory = source_directory,
    description = description,
    environment = environment)

  invisible(inference_config)
}

#' Generate _generated_score.py file for the corresponding entry_script file
#' @param entry_script Path to local file that contains the code to run for
#' the image.
#' @param source_directory paths to folders that contains all files to
#' create the image.
#' @return None
#' @noRd
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

#' Register a model for operationalization.
#'
#' @description
#' Register a model for operationalization.
#'
#' @param run The `Run` object.
#' @param model_name The name of the model.
#' @param model_path The relative cloud path to the model, for example,
#' "outputs/modelname". When not specified, `model_name` is used as the path.
#' @param tags A dictionary of key value tags to assign to the model.
#' @param properties A dictionary of key value properties to assign to the model.
#' These properties cannot be changed after model creation, however new key-value pairs can be added.
#' @param description An optional description of the model.
#' @param datasets A list of two-element lists where the first element is the
#' dataset-model relationship and the second is the corresponding dataset, e.g.
#' `list(list("training", train_ds), list("inferencing", infer_ds))`. Valid
#' values for the data-model relationship are 'training', 'validation', and 'inferencing'.
#' @param sample_input_dataset Sample input dataset for the registered model.
#' @param sample_output_dataset Sample output dataset for the registered model.
#' @param resource_configuration `ResourceConfiguration`` object to run the registered model.
#' @return The registered Model.
#' @export
#' @section Examples:
#' ```
#' registered_model <- register_model_from_run(run = run,
#'                                             model_name = "my model",
#'                                             model_path = 'outputs/model.rds',
#'                                             tags = list("version" = "0"),
#'                                             datasets = list(list("training", train_dataset),
#'                                                             list("validation", validation_dataset)),
#'                                             resource_configuration = resource_configuration(2, 2, 0))
#' ```
#' @seealso [resource_configuration()]
#' @md
register_model_from_run <- function(run, model_name, model_path = NULL,
                                    tags = NULL, properties = NULL,
                                    description = NULL, datasets = NULL,
                                    sample_input_dataset = NULL,
                                    sample_output_dataset = NULL,
                                    resource_configuration = NULL) {

  if (!is.null(datasets)) {
    user_ds_scenarios <- strsplit(unlist(lapply(datasets, "[", 1)), " ")
    valid_ds_scenarios <- c("training", "inferencing", "validation")
    if (!(all(user_ds_scenarios %in% valid_ds_scenarios))) {
      stop("One or more of your data-model relationship values is invalid.
           Valid values are 'training', 'validation', and 'inferencing'")
    }
  }

  run$register_model(model_name = model_name,
                     model_path = model_path, tags = tags,
                     properties = properties, description = description,
                     datasets = datasets,
                     sample_input_dataset = sample_input_dataset,
                     sample_output_dataset = sample_output_dataset,
                     resource_configuration = resource_configuration)
}

#' Initialize the  ResourceConfiguration.
#'
#' @description
#' Initialize the  ResourceConfiguration.
#'
#' @param cpu The number of CPU cores to allocate for this resource. Can be a decimal.
#' @param memory_in_gb The amount of memory (in GB) to allocate for this resource.
#' Can be a decimal If `TRUE`, decode the raw log bytes to a string.
#' @param gpu The number of GPUs to allocate for this resource.
#' @return The `ResourceConfiguration` object.
#' @export
#' @examples
#' \dontrun{
#' rc <- resource_configuration(2, 2, 0)
#'
#' registered_model <- register_model_from_run(run, "my_model_name",
#'                                             "path_to_my_model",
#'                                             resource_configuration = rc)
#' }
#' @seealso
#' \code{\link{register_model_from_run}}
#' @md
resource_configuration <- function(cpu = NULL, memory_in_gb = NULL,
                                   gpu = NULL) {
  azureml$core$resource_configuration$ResourceConfiguration(
    cpu = cpu, memory_in_gb = memory_in_gb, gpu = gpu)
}
