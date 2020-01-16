## Azure ML vignettes
These vignettes are end-to-end tutorials for using Azure Machine Learning with the R SDK.

Before running a vignette in RStudio, set the working directory to the folder that contains the vignette file (.Rmd file) in RStudio using `setwd(dirname)` or Session -> Set Working Directory -> To Source File Location. Each vignette assumes that the data and scripts are in the current working directory.

The following vignettes are included:
1. [installation](installation.Rmd): Install the Azure ML SDK for R.
2. [configuration](configuration.Rmd): Set up an Azure ML workspace.
3. [train-and-deploy-to-aci](train-and-deploy-to-aci): Train a caret model and deploy as a web service to Azure Container Instances (ACI).
4. [train-with-tensorflow](train-with-tensorflow/): Train a deep learning TensorFlow model with Azure ML.
5. [hyperparameter-tune-with-keras](cnn-tuning-with-hyperdrive/): Hyperparameter tune a Keras model using HyperDrive, Azure ML's hyperparameter tuning functionality.
6. [deploy-to-aks](deploy-to-aks/): Production deploy a model as a web service to Azure Kubernetes Service (AKS).

> If you are running these examples on an Azure Machine Learning compute instance, skip the installation and configuration vignettes (#1 and #2), as the compute instance has the Azure ML SDK pre-installed and your workspace details pre-configured.

For additional examples on using the R SDK, see the [samples](../samples) folder.

### Troubleshooting

- If the following error occurs when submitting an experiment using RStudio:
   ```R
    Error in py_call_impl(callable, dots$args, dots$keywords) : 
     PermissionError: [Errno 13] Permission denied
   ```
  Move the files for your project into a subdirectory and reset the working directory to that directory before re-submitting.
  
  In order to submit an experiment, the Azure ML SDK must create a .zip file of the project directory to send to the service. However,
  the SDK does not have permission to write into the .Rproj.user subdirectory that is automatically created during an RStudio
  session. For this reason, the recommended best practice is to isolate project files into their own directory.
