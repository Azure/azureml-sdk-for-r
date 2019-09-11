

# Azure Machine Learning SDK for R

[![Build Status](https://msdata.visualstudio.com/Vienna/_apis/build/status/AzureML-SDK%20R/R%20SDK%20Build?branchName=master)](https://msdata.visualstudio.com/Vienna/_build/latest?definitionId=7523&branchName=master)

Data scientists and AI developers use the Azure Machine Learning SDK for R to build and run machine learning workflows with the  Azure Machine Learning service. 

Azure Machine Learning SDK for R uses the reticulate package to bind to [Azure Machine Learning's Python SDK](https://docs.microsoft.com/azure/machine-learning/service/overview-what-is-azure-ml). By binding directly to Python, the Azure Machine Learning SDK for R allows you access to core objects and methods implemented in the Python SDK from any R environment you choose.

Main capabilities of the SDK include:

-   Manage cloud resources for monitoring, logging, and organizing your machine learning experiments.
-   Train models using cloud resources, including GPU-accelerated model training.

## Key Features and Roadmap

:heavy_check_mark: feature available :arrows_counterclockwise: in progress :clipboard: planned

| Features | Description | Status |
|----------|-------------|--------|
[Workspace](https://docs.microsoft.com/azure/machine-learning/service/concept-azure-machine-learning-architecture#workspaces)                     | The `Workspace` class is a foundational resource in the cloud that you use to experiment, train, and deploy machine learning models | :heavy_check_mark: |                     |
[Data Plane Resources](https://docs.microsoft.com/azure/machine-learning/service/concept-azure-machine-learning-architecture#datasets-and-datastores)     | `Datastore`, which stores connection information to an Azure storage service, and `DataReference`, which describes how and where data should be made available in a run. | :heavy_check_mark: |
[Compute](https://docs.microsoft.com/azure/machine-learning/service/concept-azure-machine-learning-architecture#compute-targets) | Cloud resources where you can train your machine learning models.| :heavy_check_mark: |
[Experiment](https://docs.microsoft.com/azure/machine-learning/service/concept-azure-machine-learning-architecture#experiments) | A foundational cloud resource that represents a collection of trials (individual model runs).| :heavy_check_mark: |
[Run](https://docs.microsoft.com/azure/machine-learning/service/concept-azure-machine-learning-architecture#runs) | A `Run` object represents a single trial of an experiment, and is the object that you use to monitor the asynchronous execution of a trial, store the output of the trial, analyze results, and access generated artifacts. You use `Run` inside your experimentation code to log metrics and artifacts to the Run History service. | :heavy_check_mark: |
[Estimator](https://docs.microsoft.com/azure/machine-learning/service/concept-azure-machine-learning-architecture#estimators) | A generic estimator to train data using any supplied training script. | :heavy_check_mark: |
[HyperDrive](https://docs.microsoft.com/azure/machine-learning/service/how-to-tune-hyperparameters) | HyperDrive automates the process of running hyperparameter sweeps for an `Experiment`. | :heavy_check_mark: |
[Models](https://docs.microsoft.com/azure/machine-learning/service/concept-azure-machine-learning-architecture#models) | Cloud representations of machine learning models that help you transfer models between local development environments and the `Workspace` object in the cloud. | :arrows_counterclockwise: |
[Webservice](https://docs.microsoft.com/azure/machine-learning/service/concept-azure-machine-learning-architecture#web-service-deployments) | Models can be packaged into container images that include the runtime environment and dependencies. Models must be built into an image before you deploy them as a web service. `Webservice` is the abstract parent class for creating and deploying web services for your models. | :arrows_counterclockwise: |
[Pipeline](https://docs.microsoft.com/en-us/azure/machine-learning/service/concept-ml-pipelines) | Machine learning pipelines optimize your workflow with speed, portability, and reuse. Pipelines are constructed from multiple steps, which are distinct computational units in the pipeline. Each step can run independently and use isolated compute resources. A `Pipeline` represents a collection of steps which can be executed as a workflow. | :clipboard: |

## Installing `azureml` R package

1. Install [anaconda](https://www.anaconda.com/) if not already installed. Choose python 3.5 or later.

2. Install the latest `devtools` in Rstudio/R:
   ```
   > install.packages('devtools')
   ```

3. Install azureml R package:

   Current repo is not opened up for public yet. To install from a private repo, generate a personal access token (PAT) in "https://github.com/settings/tokens" and supply to `auth_token` argument. When generating the token, make sure to select the "repo" scope.
   ```
   > devtools::install_github('https://github.com/Azure/azureml-sdk-for-r', auth_token = '<personal access toke>')
   ```

4. Install azureml python sdk. This will create a conda environment
   called `r-azureml` in which the package would be installed. Run the
   following in RStudio.
   ```
   > azureml::install_azureml()
   ```

5. You can test by doing:
   ```
   > library(azureml)
   > get_current_run()
   <azureml.core.run._OfflineRun>
   ```
   
## Getting Started

To begin running experiments with Azure Machine Learning, you must establish a connection to your Azure Machine Learning workspace.

1. If you don't already have a workspace created, you can create one by doing:
	```R
	new_ws <- create_workspace(name = workspace_name, subscription_id = your_sub_id, resource_group = your_rg, location = location, create_resource_group = FALSE)
	```
	Note: If you haven't already set up a resource group, set `create_resource_group = TRUE`  and set `resource_group` to your desired resource group name in order to create the resource group in the same step.

2. If you have an existing workspace associated with your subscription, you can retrieve it from the server by doing:
	```R
	existing_ws <- get_workspace(name, subscription_id  =  your_sub_id, resource_group  =  your_rg)
	```
	Or, if you have the workspace config.json file on your local machine, you can load the workspace by doing:
	```R
	loaded_ws <- load_workspace_from_config("insert-path-to-config-file")
	```
Once you've accessed your workspace, you can begin running and tracking your own experiments with Azure Machine Learning SDK for R. Take a look at our [samples](samples/) to learn how!

## Troubleshooting

- In step 4 of the installation, if you get ssl errors on windows, that is due to an
  outdated openssl binary. Install the latest openssl binaries from
  [here](https://wiki.openssl.org/index.php/Binaries).
- If the following error occurs when submitting an experiment using RStudio:
   ```R
    Error in py_call_impl(callable, dots$args, dots$keywords) : 
     PermissionError: [Errno 13] Permission denied
   ```
  Move the files for your project into a subdirectory and reset the working directory to that directory before re-submitting.
  
  In order to submit an experiment, AzureML SDK must create a .zip file of the project directory to send to the service. However,
  the SDK does not have permission to write into the .Rproj.user subdirectory that is automatically created during an RStudio
  session. For this reason, best practice is to isolate project files into their own directory.
  
## Contribute
We welcome contributions from the community. If you would like to contribute to the repository, please refer to the [contribution guide](CONTRIBUTING.md).

## Code of Conduct
This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
