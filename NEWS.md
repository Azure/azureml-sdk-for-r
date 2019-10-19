# azuremlsdk (0.5.6)
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
