## Using basic AzureML APIs

Before running the samples in RStudio, change to the sample directory in Rstudio using `setwd(dirname)`.
The examples assume that the data and scripts are in the current directory.

1. [setup.R](setup.R): Setup workspace before running samples.
2. [Train on ML Compute](training/train-on-amlcompute): Train a model using an ML Compute cluster as compute target.
3. [Train with TensorFlow](training/train-with-tensorflow): Train a TensorFlow GradientDescentOptimizer on MNIST.
4. [CNN Tuning with HyperDrive](training/cnn-tuning-with-hyperdrive): Use AzureML's HyperDrive service to tune hyperparameters for CIFAR10 training with Keras
5. [Deploying a model to Cloud](deployment/deploy-to-cloud): Train a model and deploy it as a Webservice.

### Troubleshooting

- If the following error occurs when submitting an experiment using RStudio:
   ```R
    Error in py_call_impl(callable, dots$args, dots$keywords) : 
     PermissionError: [Errno 13] Permission denied
   ```
  Move the files for your project into a subdirectory and reset the working directory to that directory before re-submitting.
  
  In order to submit an experiment, AzureML SDK must create a .zip file of the project directory to send to the service. However,
  the SDK does not have permission to write into the .Rproj.user subdirectory that is automatically created during an RStudio
  session. For this reason, best practice is to isolate project files into their own directory.