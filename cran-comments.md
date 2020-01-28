## Release summary
This is a minor release.

Adressing the note in R CMD CHECK:
* Found the following assignments to the global environment:
   File 'azuremlsdk/R/run.R':
     assign(widget_obj_names[[x]], widget_obj_vals[[x]], envir = .GlobalEnv)
  * The widgets run as a background job and have to access these variables in order to function successfully. The only way it could work is if these variables are added to the Global Environment so that they are available to the application.

## Test environments
* local: windows-x86_64-devel
* azure devops: Ubuntu:16.04 LTS
* r-hub: windows-x86_64-devel, ubuntu-gcc-release
* win-builder: windows-x86_64-devel

## R CMD check results
0 errors | 0 warnings | 1 note
