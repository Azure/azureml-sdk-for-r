# Developer instructions on building `azureml` package
1. Make sure below packages are installed.
    ```
    install.packages('devtools')
    install.packages('roxygen2')
    install.packages('pkgdown')
    ```
2. Run the following to generate docs and build the code:
   ```
   setwd('<repo_root>')

   # Generate Pakcage Documentation
   roxygen2::roxygenise()

   # Generate a docs directory for hosting on GitHub pages
   pkgdown::build_site()

   # Build the R package
   package_location <- devtools::build()
   ```
3. The R package file is created at `package_location`. We can now either upload it to a blob store, publish it to CRAN or install directly from the file.
4. To install the package from the `.tar.gz` file in the filesystem, do:
   ```
   install.packages(package_location, repos = NULL)
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
