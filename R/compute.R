# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Create an AmlCompute cluster
#'
#' @description
#' Provision Azure Machine Learning Compute (AmlCompute) as a compute target
#' for training. AmlCompute is a managed-compute infrastructure that allows the
#' user to easily create a single or multi-node compute. To create a persistent
#' AmlCompute resource that can be reused across jobs, make sure to specify the
#' `vm_size` and `max_nodes` parameters. The compute can then be shared with
#' other users in the workspace and is kept between jobs. If `min_nodes = 0`,
#' the compute autoscales down to zero nodes when it isn't used, and scales up
#' automatically when a job is submitted.
#'
#' AmlCompute has default limits, such as the number of cores that can be
#' allocated. For more information, see
#' [Manage and request quotas for Azure resources](https://docs.microsoft.com/en-us/azure/machine-learning/service/how-to-manage-quotas).
#' @param workspace The `Workspace` object.
#' @param cluster_name A string of the name of the cluster.
#' @param vm_size A string of the size of agent VMs. More details can be found
#' [here](https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/2019-12-01/virtualmachines#virtualmachineidentity-object).
#' Note that not all sizes are available in all regions, as detailed in the
#' aformentioned link. Defaults to `'Standard_NC6'`.
#' @param vm_priority A string of either `'dedicated'` or `'lowpriority'` to
#' use either dedicated or low-priority VMs. Defaults to `'dedicated'`.
#' @param min_nodes An integer of the minimum number of nodes to use on the
#' cluster. If not specified, will default to `0`.
#' @param max_nodes An integer of the maximum number of nodes to use on the
#' cluster.
#' @param idle_seconds_before_scaledown An integer of the node idle time in
#' seconds before scaling down the cluster. Defaults to `120`.
#' @param admin_username A string of the name of the administrator user account
#' that can be used to SSH into nodes.
#' @param admin_user_password A string of the password of the administrator user
#' account.
#' @param admin_user_ssh_key A string of the SSH public key of the administrator
#' user account.
#' @param vnet_resourcegroup_name A string of the name of the resource group
#' where the virtual network is located.
#' @param vnet_name A string of the name of the virtual network.
#' @param subnet_name A string of the name of the subnet inside the vnet.
#' @param tags A named list of tags for the cluster, e.g.
#' `list("tag" = "value")`.`
#' @param description A string of the description for the cluster.
#' @return The `AmlCompute` object.
#' @export
#' @section Details:
#' For more information on using an Azure Machine Learning Compute resource
#' in a virtual network, see
#' [Secure Azure ML experimentation and inference jobs within an Azure Virtual Network](https://docs.microsoft.com/en-us/azure/machine-learning/service/how-to-enable-virtual-network#use-a-machine-learning-compute-instance).
#' @examples
#' \dontrun{
#' ws <- load_workspace_from_config()
#' compute_target <- create_aml_compute(ws,
#'                                      cluster_name = 'mycluster',
#'                                      vm_size = 'STANDARD_D2_V2',
#'                                      max_nodes = 1)
#' wait_for_provisioning_completion(compute_target, show_output = TRUE)
#' }
#' @seealso
#' `wait_for_provisioning_completion()`
#' @md
create_aml_compute <- function(workspace,
                               cluster_name,
                               vm_size,
                               vm_priority = "dedicated",
                               min_nodes = 0,
                               max_nodes = NULL,
                               idle_seconds_before_scaledown = NULL,
                               admin_username = NULL,
                               admin_user_password = NULL,
                               admin_user_ssh_key = NULL,
                               vnet_resourcegroup_name = NULL,
                               vnet_name = NULL,
                               subnet_name = NULL,
                               tags = NULL,
                               description = NULL) {
  compute_config <- azureml$core$compute$AmlCompute$provisioning_configuration(
    vm_size = vm_size,
    vm_priority = vm_priority,
    min_nodes = min_nodes,
    max_nodes = max_nodes,
    idle_seconds_before_scaledown = idle_seconds_before_scaledown,
    admin_username = admin_username,
    admin_user_password = admin_user_password,
    admin_user_ssh_key = admin_user_ssh_key,
    vnet_resourcegroup_name = vnet_resourcegroup_name,
    vnet_name = vnet_name,
    subnet_name = subnet_name,
    tags = tags,
    description = description)

  azureml$core$compute$ComputeTarget$create(workspace,
                                            cluster_name,
                                            compute_config)
}

#' Get an existing compute cluster
#'
#' @description
#' Returns an `AmlCompute` or `AksCompute` object for an existing compute
#' resource. If the compute target doesn't exist, the function will return
#' `NULL`.
#' @param workspace The `Workspace` object.
#' @param cluster_name A string of the name of the cluster.
#' @return The `AmlCompute` or `AksCompute` object.
#' @export
#' @examples
#' \dontrun{
#' ws <- load_workspace_from_config()
#' compute_target <- get_compute(ws, cluster_name = 'mycluster')
#' }
#' @md
get_compute <- function(workspace, cluster_name) {
  tryCatch({
    azureml$core$compute$ComputeTarget(workspace = workspace,
                                       name = cluster_name)
    },
    error = function(e) {
      if (grepl("ComputeTargetException", e$message, )) {
        NULL
      } else {
        stop(message(e))
      }
    }
  )
}

#' Wait for a cluster to finish provisioning
#'
#' @description
#' Wait for a cluster to finish provisioning. Typically invoked after a
#' `create_aml_compute()` or `create_aks_compute()` call.
#' @param cluster The `AmlCompute` or `AksCompute` object.
#' @param show_output If `TRUE`, more verbose output will be provided.
#' @return None
#' @export
#' @seealso
#' `create_aml_compute()`, `create_aks_compute()`
#' @md
wait_for_provisioning_completion <- function(cluster, show_output = FALSE) {
  cluster$wait_for_completion(show_output)
}

#' Delete a cluster
#'
#' @description
#' Remove the compute object from its associated workspace and delete the
#' corresponding cloud-based resource.
#' @param cluster The `AmlCompute` or `AksCompute` object.
#' @return None
#' @export
#' @examples
#' \dontrun{
#' ws <- load_workspace_from_config()
#' compute_target <- get_compute(ws, cluster_name = 'mycluster')
#' delete_compute(compute_target)
#' }
#' @md
delete_compute <- function(cluster) {
  cluster$delete()
  invisible(NULL)
}

#' Update scale settings for an AmlCompute cluster
#'
#' @description
#' Update the scale settings for an existing AmlCompute cluster.
#' @param cluster The `AmlCompute` cluster.
#' @param min_nodes An integer of the minimum number of nodes to use on
#' the cluster.
#' @param max_nodes An integer of the maximum number of nodes to use on
#' the cluster.
#' @param idle_seconds_before_scaledown An integer of the node idle time
#' in seconds before scaling down the cluster.
#' @return None
#' @export
#' @md
update_aml_compute <- function(cluster, min_nodes = NULL, max_nodes = NULL,
                               idle_seconds_before_scaledown = NULL) {
  cluster$update(cluster = cluster,
                 min_nodes = min_nodes,
                 max_nodes = max_nodes,
                 idle_seconds_before_scaledown = idle_seconds_before_scaledown)
  invisible(NULL)
}

#' Get the details (e.g IP address, port etc) of all the compute nodes in the
#' compute target
#'
#' @param cluster cluster object
#' @return Details of all the compute nodes in the cluster in data frame
#' @export
#' @md
list_nodes_in_aml_compute <- function(cluster) {
  nodes <- cluster$list_nodes()
  plyr::ldply(nodes, data.frame)
}

#' Create an AksCompute cluster
#'
#' @description
#' Provision an Azure Kubernetes Service instance (AksCompute) as a compute
#' target for web service deployment. AksCompute is recommended for high-scale
#' production deployments and provides fast response time and autoscaling of
#' the deployed service. Cluster autoscaling isn't supported through the Azure
#' ML R SDK. To change the nodes in the AksCompute cluster, use the UI for the
#' cluster in the Azure portal. Once created, the cluster can be reused for
#' multiple deployments.
#' @param workspace The `Workspace` object.
#' @param cluster_name A string of the name of the cluster.
#' @param agent_count An integer of the number of agents (VMs) to host
#' containers. Defaults to `3`.
#' @param vm_size A string of the size of agent VMs. More details can be found
#' [here](https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/2019-12-01/virtualmachines#virtualmachineidentity-object).
#' Note that not all sizes are available in all regions, as detailed in the
#' aformentioned link. Defaults to `'Standard_D3_v2'`.
#' @param ssl_cname A string of a CName to use if enabling SSL validation on
#' the cluster. Must provide all three - CName, cert file, and key file - to
#' enable SSL validation.
#' @param ssl_cert_pem_file A string of a file path to a file containing cert
#' information for SSL validation. Must provide all three - CName, cert file,
#' and key file - to enable SSL validation.
#' @param ssl_key_pem_file A string of a file path to a file containing key
#' information for SSL validation. Must provide all three - CName, cert file,
#' and key file - to enable SSL validation.
#' @param location A string of the location to provision the cluster in. If not
#' specified, defaults to the workspace location. Available regions for this
#' compute can be found here:
#' "https://azure.microsoft.com/global-infrastructure/services/?regions=all&products=kubernetes-service".
#' @param vnet_resourcegroup_name A string of the name of the resource group
#' where the virtual network is located.
#' @param vnet_name A string of the name of the virtual network.
#' @param subnet_name A string of the name of the subnet inside the vnet.
#' @param service_cidr A string of a CIDR notation IP range from which to assign
#' service cluster IPs.
#' @param dns_service_ip A string of the container's DNS server IP address.
#' @param docker_bridge_cidr A string of a CIDR notation IP for Docker bridge.
#' @param cluster_purpose A string describing targeted usage of the cluster.
#' This is used to provision Azure Machine Learning components to ensure the desired level of fault-tolerance and QoS.
#' 'FastProd' will provision components to handle higher levels of traffic with production quality fault-tolerance. This will default the AKS cluster to have 3 nodes.
#' 'DevTest' will provision components at a minimal level for testing. This will default the AKS cluster to have 1 node.
#' 'FastProd'is the default value.
#' @return An `AksCompute` object.
#' @export
#' @section Details:
#' For more information on using an AksCompute resource within a virtual
#' network, see
#' [Secure Azure ML experimentation and inference jobs within an Azure Virtual Network](https://docs.microsoft.com/en-us/azure/machine-learning/service/how-to-enable-virtual-network#use-azure-kubernetes-service-aks).
#' @section Examples:
#' ```r
#' # Create an AksCompute cluster using the default configuration (you can also
#' # provide parameters to customize this)
#'
#' ws <- load_workspace_from_config()
#'
#' compute_target <- create_aks_compute(ws, cluster_name = 'mycluster')
#' wait_for_provisioning_completion(compute_target)
#' ```
#' @md
create_aks_compute <- function(workspace,
                               cluster_name,
                               agent_count = NULL,
                               vm_size = NULL,
                               ssl_cname = NULL,
                               ssl_cert_pem_file = NULL,
                               ssl_key_pem_file = NULL,
                               location = NULL,
                               vnet_resourcegroup_name = NULL,
                               vnet_name = NULL,
                               subnet_name = NULL,
                               service_cidr = NULL,
                               dns_service_ip = NULL,
                               docker_bridge_cidr = NULL,
                               cluster_purpose = c("FastProd", "DevTest")) {

  cluster_purpose <- match.arg(cluster_purpose)

  compute_config <- azureml$core$compute$AksCompute$provisioning_configuration(
    agent_count = agent_count,
    vm_size = vm_size,
    ssl_cname = ssl_cname,
    ssl_cert_pem_file = ssl_cert_pem_file,
    ssl_key_pem_file = ssl_key_pem_file,
    location = location,
    vnet_resourcegroup_name = vnet_resourcegroup_name,
    vnet_name = vnet_name,
    subnet_name = subnet_name,
    service_cidr = service_cidr,
    dns_service_ip = dns_service_ip,
    docker_bridge_cidr = docker_bridge_cidr,
    cluster_purpose = cluster_purpose)

  azureml$core$compute$ComputeTarget$create(workspace,
                                            cluster_name,
                                            compute_config)
}

#' Get the credentials for an AksCompute cluster
#'
#' @description
#' Retrieve the credentials for an AksCompute cluster.
#' @param cluster The `AksCompute` object.
#' @return Named list of the cluster details.
#' @export
#' @md
get_aks_compute_credentials <- function(cluster) {
  cluster$get_credentials()
}

#' Attach an existing AKS cluster to a workspace
#'
#' @description
#' If you already have an AKS cluster in your Azure subscription, and it is
#' version 1.12.##, you can attach it to your workspace to use for deployments.
#' The existing AKS cluster can be in a different Azure region than your
#' workspace.
#'
#' If you want to secure your AKS cluster using an Azure Virtual Network, you
#' must create the virtual network first. For more information, see
#' [Secure Azure ML experimentation and inference jobs within an Azure Virtual Network](https://docs.microsoft.com/en-us/azure/machine-learning/service/how-to-enable-virtual-network#aksvnet)
#'
#' If you want to re-attach an AKS cluster, for example to to change SSL or other
#' cluster configuration settings, you must first remove the existing attachment
#' with `detach_aks_compute()`.
#'
#' Attaching a cluster will take approximately 5 minutes.
#' @param workspace The `Workspace` object to attach the AKS cluster to.
#' @param resource_group A string of the resource group in which the AKS cluster
#' is located.
#' @param cluster_name A string of the name of the AKS cluster.
#' @param cluster_purpose The targeted usage of the cluster. The possible values are
#' "DevTest" or "FastProd". This is used to provision Azure Machine Learning components
#' to ensure the desired level of fault-tolerance and QoS. If your cluster has less
#' than 12 virtual CPUs, you will need to specify "DevTest" for this argument. We
#' recommend that your cluster have at least 2 virtual CPUs for dev/test usage.
#' @return The `AksCompute` object.
#' @export
#' @section Examples:
#' ```r
#' ws <- load_workspace_from_config()
#' compute_target <- attach_aks_compute(ws,
#'                                      resource_group = 'myresourcegroup',
#'                                      cluster_name = 'myakscluster')
#' ```
#'
#' If the cluster has less than 12 virtual CPUs, you will need to also specify the
#' `cluster_purpose` parameter in the `attach_aks_compute()` call: `cluster_purpose = 'DevTest'`.
#' @seealso
#' `detach_aks_compute()`
#' @md
attach_aks_compute <- function(workspace,
                               resource_group,
                               cluster_name,
                               cluster_purpose = c("FastProd", "DevTest")) {
  cluster_purpose <- match.arg(cluster_purpose)
  attach_config <- azureml$core$compute$AksCompute$attach_configuration(
    resource_group = resource_group, cluster_name = cluster_name, cluster_purpose = cluster_purpose)

  azureml$core$compute$ComputeTarget$attach(workspace,
                                            cluster_name,
                                            attach_config)
}

#' Detach an AksCompute cluster from its associated workspace
#'
#' @description
#' Detach the AksCompute cluster from its associated workspace. No
#' underlying cloud resource will be deleted; the association will
#' just be removed.
#' @param cluster The `AksCompute` object.
#' @return None
#' @export
#' @md
detach_aks_compute <- function(cluster) {
  cluster$detach()
  invisible(NULL)
}

#' List the supported VM sizes in a region
#'
#' @param workspace The `Workspace` object.
#' @param location A string of the location of the cluster. If not specified,
#' will default to the workspace location.
#' @return A data frame of supported VM sizes in a region with name of the VM, VCPUs,
#' RAM.
#' @export
#' @md
list_supported_vm_sizes <- function(workspace, location = NULL) {
  vm_sizes <- azureml$core$compute$AmlCompute$supported_vmsizes(workspace,
                                                                location)
  plyr::ldply(vm_sizes, data.frame)
}
