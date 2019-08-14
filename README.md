# Azure Machine Learning SDK for R

[![Build Status](https://msdata.visualstudio.com/Vienna/_apis/build/status/AzureML-SDK%20R/R%20SDK%20Build?branchName=master)](https://msdata.visualstudio.com/Vienna/_build/latest?definitionId=7523&branchName=master)

Data scientists and AI developers use the Azure Machine Learning SDK for R to build and run machine learning workflows with the  [Azure Machine Learning service](https://docs.microsoft.com/azure/machine-learning/service/overview-what-is-azure-ml). You can interact with the service in any R environment.

Main capabilities of the SDK include:

-   Manage cloud resources for monitoring, logging, and organizing your machine learning experiments.
-   Train models using cloud resources, including GPU-accelerated model training.

## Key Features and Roadmap

:heavy_check_mark: feature available  :heavy_minus_sign: in progress  :heavy_multiplication_x: no support planned

| Features                                                                                                         | Description                | Status             |
|------------------------------------------------------------------------------------------------------------------|---------------------|---------------------|
| [Workspace](https://docs.microsoft.com/python/api/azureml-core/azureml.core.workspace.workspace?view=azure-ml-py)                     | The `Workspace` class is a foundational resource in the cloud that you use to experiment, train, and deploy machine learning models | :heavy_check_mark: |                     |
| [Data Plane Resources](https://docs.microsoft.com/en-us/python/api/azureml-core/azureml.data?view=azure-ml-py)     | `Datastore`, which stores connection information to an Azure storage service, and `DataReference`, which describes how and where data should be made available in a run. | :heavy_check_mark: |
| [Compute](https://docs.microsoft.com/python/api/overview/azure/ml/intro?view=azure-ml-py#computetarget-runconfiguration-and-scriptrunconfig) | Cloud resources where you can train your machine learning models.| :heavy_check_mark: |
[Experiment](https://docs.microsoft.com/python/api/overview/azure/ml/intro?view=azure-ml-py#experiment) | A foundational cloud resource that represents a collection of trials (individual model runs).| :heavy_check_mark: |
[Estimator](https://docs.microsoft.com/python/api/azureml-train-core/azureml.train.estimator.estimator?view=azure-ml-py) | A generic estimator to train data using any supplied training script. | :heavy_minus_sign: |
[Run](https://docs.microsoft.com/python/api/overview/azure/ml/intro?view=azure-ml-py#run) | A `Run` object represents a single trial of an experiment, and is the object that you use to monitor the asynchronous execution of a trial, store the output of the trial, analyze results, and access generated artifacts. You use `Run` inside your experimentation code to log metrics and artifacts to the Run History service. | :heavy_check_mark: |
[Models](https://docs.microsoft.com/python/api/overview/azure/ml/intro?view=azure-ml-py#model) | Cloud representations of machine learning models that help you transfer models between local development environments and the `Workspace` object in the cloud. | :heavy_minus_sign: |
[Webservice](https://docs.microsoft.com/python/api/overview/azure/ml/intro?view=azure-ml-py#image-and-webservice) | Models can be packaged into container images that include the runtime environment and dependencies. Models must be built into an image before you deploy them as a web service. `Webservice` is the abstract parent class for creating and deploying web services for your models. | :heavy_minus_sign: |
[RunConfiguration and ScriptRunConfiguration](https://docs.microsoft.com/python/api/overview/azure/ml/intro?view=azure-ml-py#computetarget-runconfiguration-and-scriptrunconfig) | `RunConfiguration` configures an environment involving `Experiment` runs and compute. `ScriptRunConfiguration` does the same for `ScriptRun` objects. | :heavy_multiplication_x: |

## Installing `azureml` R package
1. Install [anaconda](https://www.anaconda.com/) if not already installed. Choose python 3.5 or later.

2. Install azureml R package in Rstudio/R:

   Current repo is not opened up for public yet. To install from a private repo, generate a personal access token (PAT) in "https://github.com/settings/tokens" and supply to `auth_token` argument.
   ```
   > devtools::install_github('https://github.com/Azure/azureml-sdk-for-r', auth_token = '<personal access toke>')
   ```

3. Install azureml python sdk. This will create a conda environment
   called `r-azureml` in which the package would be installed. Run the
   following in Rstudio.
   ```
   > azureml::install_azureml()
   ```

4. You can test by doing:
   ```
   > library(azureml)
   > get_current_run()
   <azureml.core.run._OfflineRun>
   ```

### Troubleshooting
- In step 2, if the following error occurs:
   ```python
    Error: 'setInternet2' is defunct.
    ```
    Then upgrade devtools to the latest version or
   install the latest `devtools` from github through:
   ```
   devtools::install_github("r-lib/devtools")
   ```
- In step 3, if you get ssl errors on windows, that is due to an
  outdated openssl binary. Install the latest openssl binaries from
  [here](https://wiki.openssl.org/index.php/Binaries).
- If the following error occurs when submitting an experiment using RStudio:
   ```python
    Error in py_call_impl(callable, dots$args, dots$keywords) : 
     PermissionError: [Errno 13] Permission denied
   ```
  Move the files for your project into a subdirectory and reset the working directory to that directory before re-submitting.
  
  In order to submit an experiment, AzureML SDK must create a .zip file of the project directory to send to the service. However,
  the SDK does not have permission to write into the .Rproj.user subdirectory that is automatically created during an RStudio
  session. For this reason, best practice is to isolate project files into their own directory.



## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.


<p align="center"><a href="https://github.com/Azure/AzureR"><img src="https://github.com/Azure/AzureR/raw/master/images/logo2.png" width=800 /></a></p>

