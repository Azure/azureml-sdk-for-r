# azuremlsdk 0.8.0
## New features
- Foreach backend for distributed training and batch inferencing.
- R Section in Environment Definition.
- Added Azure Data Lake Gen2 Datastore support.

## Bug fixes
- Fix issues with Dataset creation and usage.
- Fix Interactive Authentication

## Breaking Changes
- Removed Run Details widget support

# azuremlsdk 0.6.85
## New features
- Methods for creating and managing Azure ML Datasets.
- Update `create_workspace()` to use `sku` parameter.
- Expose `file_name` parameter to `load_workspace_from_config()`.
- v2 of the Azure ML run details widget in RStudio Viewer pane.

## Bug fixes
- Fix installation issue introduced by latest **reticulate** 1.14 release.
- Fix default CRAN CDN.
- Remove dependency on **DAAG** package in train-and-deploy-to-aci vignette.

# azuremlsdk 0.5.7.9000
`view_run_details` for invoking Azure ML run details widget with live updates in RStudio Viewer pane.

# azuremlsdk 0.5.7
Initial CRAN release

## Initial features
- Methods for creating and managing Azure Machine Learning (Azure ML) Workspaces.
- Methods for registering and managing Azure ML Datastores.
- Methods for managing secrets in the Azure Key Vault associated with a workspace.
- Methods for creating and managing Azure Machine Learning Compute (AmlCompute).
- Methods for creating, managing, and attaching Azure Kubernetes Service clusters as compute targets (AksCompute).
- Methods for creating and managing Azure ML Environments for training and deployment.
- Methods for creating and submitting Azure ML Experiments.
- Methods for configuring and managing Azure ML Runs.
- Methods for logging metrics to Azure ML during runs.
- Methods for configuring and managing Azure ML hyperparameter tuning runs.
- Methods for model registration and management to Azure ML.
- Methods for deploying models as local webservices for testing.
- Methods for deploying models as webservices on Azure Container Instances (ACI) and Azure Kubernetes Service (AKS).
- `view_run_details()` for invoking remote Azure ML run details in RStudio Viewer pane.

## Documentation
- Vignettes for installation, TensorFlow training on AmlCompute, hyperparameter tuning a Keras model with Azure ML's HyperDrive service, and production deloying a model as a webservice to AKS.
- Additional code samples for setting up workspaces, training on AmlCompute, and deploying a model as a webservice to ACI.
