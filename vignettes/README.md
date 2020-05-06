## Azure ML vignettes
These vignettes are end-to-end tutorials for using Azure Machine Learning with the R SDK.

Before running a vignette in RStudio, set the working directory to the folder that contains the vignette file (.Rmd file) in RStudio using `setwd(dirname)` or Session -> Set Working Directory -> To Source File Location. Each vignette assumes that the data and scripts are relative to vignette file location.

The following vignettes are included:
1. [installation](installation.Rmd): Install the Azure ML SDK for R.
2. [configuration](configuration.Rmd): Set up an Azure ML workspace.
3. [train-and-deploy-first-model](train-and-deploy-first-model.Rmd): Train a caret model and deploy as a web service to Azure Container Instances (ACI).
4. [train-with-tensorflow](train-with-tensorflow.Rmd): Train a deep learning TensorFlow model with Azure ML.
5. [hyperparameter-tune-with-keras](hyperparameter-tune-with-keras.Rmd): Hyperparameter tune a Keras model using HyperDrive, Azure ML's hyperparameter tuning functionality.
6. [deploy-to-aks](deploy-to-aks.Rmd): Production deploy a model as a web service to Azure Kubernetes Service (AKS).

> If you are running these examples on an Azure Machine Learning compute instance, skip the installation and configuration vignettes (#1 and #2), as the compute instance has the Azure ML SDK pre-installed and your workspace details pre-configured.

For additional examples on using the R SDK, see the [samples](../samples) folder.

### Azure ML guides
In addition to the end-to-end vignettes, we also provide more detailed documentation for the following:
* [Deploying models](deploying-models.Rmd): Where and how to deploy models on Azure ML.
* [Troubleshooting](troubleshooting.Rmd): Known issues and troubleshooting for using R in Azure ML.
