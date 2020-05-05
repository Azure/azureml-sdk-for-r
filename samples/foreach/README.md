## Usage
**azuremlsdk** includes methods to support using AmlCompute as a parallel backend for the **foreach** package, enabling users to execute foreach loops in parallel.

### Getting started
To load the `register_do_azureml_parallel()` method, run the below code, as the feature is still experimental and not yet publically exported:
```
devtools::load_all()
```

Retrieve your Azure ML workspace and the AmlCompute cluster you will use to run your parallel jobs on:
```
ws <- load_workspace_from_config()
amlcluster <- get_compute(ws, name = "my-cluster")
```
