# Developer instructions on building `azureml` package
1.  Make sure both `devtools` and `roxygenise` are installed.
    ```
    install.packages('devtools')
    install.packages('roxygen2')
    ```
2. Run the following to generate docs and build the code:
   ```
   setwd('<repo_root>')
   roxygen2::roxygenise()
   devtools::build()
   ```
3. A file called `azureml_1.0.tar.gz` is created that is the `R` package.
We can now either upload it to a blob store, publish it to CRAN or install
directly from the file.
4. To install the package from the `.tar.gz` file in the filesystem, do:
   ```
   install.packages('azureml_1.0.tar.gz', repos = NULL)
   ```
   To install from a url:
   ```
   install.packages(package_url, repos = NULL)
   ```

   If you already have the package loaded in your R session, you may want to
   remove it from the session to use the new one. This can be done by the
   following:
   ```
   detach("package:azureml", unload = TRUE)
    ```
