# Azure Machine Learning SDK for R
[![Build Status](https://msdata.visualstudio.com/Vienna/_apis/build/status/AzureML-SDK%20R/R%20SDK%20Function%20Tests?branchName=master&label=Build%20%26%20Tests)](https://azure.microsoft.com/en-us/services/devops/pipelines/)
[![Build Status](https://msdata.visualstudio.com/Vienna/_apis/build/status/AzureML-SDK%20R/R%20SDK%20Code%20Quality?branchName=master&label=Code%20Quality)](https://azure.microsoft.com/en-us/services/devops/pipelines/)
[![Build Status](https://msdata.visualstudio.com/Vienna/_apis/build/status/AzureML-SDK%20R/R%20SDK%20Sample%20Validation?branchName=master&&label=Samples)](https://azure.microsoft.com/en-us/services/devops/pipelines/)
[![Build Status](https://msdata.visualstudio.com/Vienna/_apis/build/status/AzureML-SDK%20R/R%20SDK%20Docs?branchName=master&label=Docs)](https://azure.microsoft.com/en-us/services/devops/pipelines/)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/azuremlsdk)](https://cran.r-project.org/package=azuremlsdk)

Data scientists and AI developers use the Azure Machine Learning SDK for R to build and run machine learning workflows with Azure Machine Learning. 

Azure Machine Learning SDK for R uses the reticulate package to bind to [Azure Machine Learning's Python SDK](https://docs.microsoft.com/azure/machine-learning/service/overview-what-is-azure-ml). By binding directly to Python, the Azure Machine Learning SDK for R allows you access to core objects and methods implemented in the Python SDK from any R environment you choose.

Main capabilities of the SDK include:

-   Manage cloud resources for monitoring, logging, and organizing your machine learning experiments.
-   Train models using cloud resources, including GPU-accelerated model training.
-   Deploy your models as webservices on Azure Container Instances (ACI) and Azure Kubernetes Service (AKS).

Please take a look at the package website https://azure.github.io/azureml-sdk-for-r for complete documentation.

## Key Features and Roadmap

:heavy_check_mark: feature available :arrows_counterclockwise: in progress :clipboard: planned

| Features | Description | Status |
|----------|-------------|--------|
| [Workspace](https://azure.github.io/azureml-sdk-for-r/reference/index.html#section-workspaces) | The `Workspace` class is a foundational resource in the cloud that you use to experiment, train, and deploy machine learning models | :heavy_check_mark: | 
| [Compute](https://azure.github.io/azureml-sdk-for-r/reference/index.html#section-compute-targets) | Cloud resources where you can train your machine learning models.| :heavy_check_mark: |
| [Data Plane Resources](https://azure.github.io/azureml-sdk-for-r/reference/index.html#section-working-with-data) | `Datastore`, which stores connection information to an Azure storage service, and `DataReference`, which describes how and where data should be made available in a run. | :heavy_check_mark: |
| [Experiment](https://azure.github.io/azureml-sdk-for-r/reference/index.html#section-training-experimentation) | A foundational cloud resource that represents a collection of trials (individual model runs).| :heavy_check_mark: |
| [Run](https://azure.github.io/azureml-sdk-for-r/reference/index.html#section-training-experimentation) | A `Run` object represents a single trial of an experiment, and is the object that you use to monitor the asynchronous execution of a trial, store the output of the trial, analyze results, and access generated artifacts. You use `Run` inside your experimentation code to log metrics and artifacts to the Run History service. | :heavy_check_mark: |
| [Estimator](https://azure.github.io/azureml-sdk-for-r/reference/index.html#section-training-experimentation) | A generic estimator to train data using any supplied training script. | :heavy_check_mark: |
| [HyperDrive](https://azure.github.io/azureml-sdk-for-r/reference/index.html#section-hyperparameter-tuning) | HyperDrive automates the process of running hyperparameter sweeps for an `Experiment`. | :heavy_check_mark: |
| [Model](https://azure.github.io/azureml-sdk-for-r/reference/index.html#section-model-management-deployment) | Cloud representations of machine learning models that help you transfer models between local development environments and the `Workspace` object in the cloud. | :heavy_check_mark: |
| [Webservice](https://azure.github.io/azureml-sdk-for-r/reference/index.html#section-model-management-deployment) | Models can be packaged into container images that include the runtime environment and dependencies. Models must be built into an image before you deploy them as a web service. `Webservice` is the abstract parent class for creating and deploying web services for your models. | :heavy_check_mark: |
| [Dataset](https://docs.microsoft.com/en-us/azure/machine-learning/service/concept-azure-machine-learning-architecture#datasets-and-datastores) | An Azure Machine Learning `Dataset` allows you to explore, transform, and manage your data for various scenarios such as model training and pipeline creation. When you are ready to use the data for training, you can save the Dataset to your Azure ML workspace to get versioning and reproducibility capabilities. | :heavy_check_mark: |

## Installation

Install [Conda](https://docs.conda.io/en/latest/miniconda.html) if not already installed. Choose Python 3.5 or later.

```R
# Install Azure ML SDK from CRAN
install.packages("azuremlsdk")

# Or the development version from GitHub
install.packages("remotes")
remotes::install_github('https://github.com/Azure/azureml-sdk-for-r')

# Then, use `install_azureml()` to install the compiled code from the AzureML Python SDK.
azuremlsdk::install_azureml()
```
Now, you're ready to get started!

For a more detailed walk-through of the installation process, advanced options, and troubleshooting, see our [Installation Guide](https://azure.github.io/azureml-sdk-for-r/articles/installation.html).

## Getting Started

To begin running experiments with Azure Machine Learning, you must establish a connection to your Azure Machine Learning workspace.

1. If you don't already have a workspace created, you can create one by doing:

	```R
	# If you haven't already set up a resource group, set `create_resource_group = TRUE`  
	# and set `resource_group` to your desired resource group name in order to create the resource group 
	# in the same step.
	new_ws <- create_workspace(name = <workspace_name>, 
	                           subscription_id = <subscription_id>, 
				   resource_group = <resource_group_name>, 
				   location = location, 
				   create_resource_group = FALSE)
	```
	
	After the workspace is created, you can save it to a configuration file to the local machine.
	
	```R
	write_workspace_config(new_ws)
	```

2. If you have an existing workspace associated with your subscription, you can retrieve it from the server by doing:

	```R
	existing_ws <- get_workspace(name = <workspace_name>, 
				     subscription_id = <subscription_id>, 
				     resource_group = <resource_group_name>)
	```
	Or, if you have the workspace config.json file on your local machine, you can load the workspace by doing:
	
	```R
	loaded_ws <- load_workspace_from_config()
	```
Once you've accessed your workspace, you can begin running and tracking your own experiments with Azure Machine Learning SDK for R.

Take a look at our [code samples](https://github.com/Azure/azureml-sdk-for-r/tree/master/samples) and [end-to-end vignettes](https://github.com/Azure/azureml-sdk-for-r/tree/master/vignettes) for examples of what's possible with the SDK!
 
## Resources
* R SDK package documentation: https://azure.github.io/azureml-sdk-for-r/reference/index.html
* Azure Machine Learning: https://docs.microsoft.com/en-us/azure/machine-learning/service/overview-what-is-azure-ml

## Contribute
We welcome contributions from the community. If you would like to contribute to the repository, please refer to the [contribution guide](https://github.com/Azure/azureml-sdk-for-r/blob/master/CONTRIBUTING.md).

## Code of Conduct
This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
