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
