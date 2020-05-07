## Usage
**azuremlsdk** includes methods to support using `AmlCompute` as a parallel backend for the **foreach** package, enabling users to execute foreach loops in parallel.

### Getting started
To load the `register_do_azureml_parallel()` method, run the below code, as the feature is still experimental and not yet publically exported:
```
devtools::load_all()
```

Retrieve your Azure ML workspace and the `AmlCompute` cluster you will use to run your parallel jobs on:
```
ws <- load_workspace_from_config()
amlcluster <- get_compute(ws, name = "my-cluster")
```

Register the `AmlCompute` cluster as your parallel backend:
```
register_do_azureml_parallel(ws, amlcluster)
```

Now you can run your foreach loop with the `%dopar%` keyword. The results from the parallel execution will be returned by the `foreach()` call:

```
results <- foreach(i = 1:10) %dopar% {
  # Your code here that will be executed in parallel
  # ...
}
```

Once your job is complete, you can delete the cluster:
```
delete_compute(amlcluster)
```
Or, if you had provisioned your cluster with autoscale settings with `min_nodes = 0`, the cluster will autoscale back down to zero nodes once the job is complete.

### Azure ML-specific configurations for foreach
The below table includes additional Azure ML-specific options that you can configure for your `foreach()` call:
| Argument name | Default value | Type | Description |
| ------------- | :-------------: | :-----: | :----- |
| `node_count` | `1L` | Integer | The number of nodes in your cluster to use for the parallel execution. |
| `process_count_per_node` | `1L` | Integer | The number of processes (or "workers") to run on each node. |
| `job_timeout` | `1200L` | Integer | The maximum allowed time in seconds for the job to run. Azure ML will attempt to automatically cancel the job if it take longer than this value. |
| `experiment_name` | `"r-foreach"` | String | The name of the experiment that your job will be tracked under. This is the name that will appear in [Azure ML studio](ml.azure.com). |
| `r_env` | `NULL` | Azure ML Environment | The Azure ML Environment that defines the Docker image that will run as a container on each of the nodes for the job. Use [`r_environment()`](https://azure.github.io/azureml-sdk-for-r/reference/r_environment.html) to create the environment. You will need to explicitly load any of the packages installed by the environment definition in your `foreach` loop. For CRAN packages, you can use the `.packages` option to specify which CRAN packages to load in order to execute the code in the loop successfully. |

### Examples
For an example of using `AmlCompute` as your foreach backend, see the [batch inferencing](batch_inferencing) sample.
