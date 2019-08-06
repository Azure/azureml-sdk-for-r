# Installing `azureml` R package
1. Install [anaconda](https://www.anaconda.com/) if not already installed. Choose 
python 3.5 or later.
2. Install azureml R package in Rstudio/R:
   ```
   > devtools::install_github('https://github.com/Azure/azureml-sdk-for-r')
        
3. Install azureml python sdk. This will create a conda environment 
   called `r-azureml` in which the package would be installed. Run the
   following in Rstudio.
   
   `> azureml::install_azureml()`
   

You can test by doing:
```
> library(azureml)
> get_current_run()
<azureml.core.run._OfflineRun>
```

## Troubleshooting
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
