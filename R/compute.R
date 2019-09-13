# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Create AmlCompute
#' @param workspace workspace object
#' @param cluster_name cluster name
#' @param vm_size Size of agent VMs. More details can be found here: https://aka.ms/azureml-vm-details.
#' Note that not all sizes are available in all regions, as detailed in the previous link.
#' @param vm_priority dedicated or lowpriority VMs. If not specified, will default to dedicated.
#' @param min_nodes Minimum number of nodes to use on the cluster. If not specified, will default to 0
#' @param max_nodes Maximum number of nodes to use on the cluster
#' @param idle_seconds_before_scaledown Node idle time in seconds before scaling down the cluster
#' @param admin_username Name of the administrator user account which can be used to SSH into nodes
#' @param admin_user_password Password of the administrator user account
#' @param admin_user_ssh_key SSH public key of the administrator user account
#' @param vnet_resourcegroup_name Name of the resource group where the virtual network is located
#' @param vnet_name Name of the virtual network
#' @param subnet_name Name of the subnet inside the vnet
#' @param tags A dictionary of key value tags to provide to the compute object
#' @param description A description to provide to the compute object
#' @return An AmlCompute object representation of the compute object
#' @export
create_aml_compute <- function(workspace, cluster_name, vm_size, vm_priority = "dedicated", min_nodes = 0,
                  max_nodes = NULL, idle_seconds_before_scaledown = NULL, admin_username = NULL,
                  admin_user_password = NULL, admin_user_ssh_key = NULL, vnet_resourcegroup_name = NULL,
                  vnet_name = NULL, subnet_name = NULL, tags = NULL, description = NULL)
{
  compute_config <- azureml$core$compute$AmlCompute$provisioning_configuration(vm_size = vm_size,
                                  vm_priority = vm_priority, min_nodes = min_nodes, max_nodes = max_nodes,
                                  idle_seconds_before_scaledown = idle_seconds_before_scaledown,
                                  admin_username = admin_username,
                                  admin_user_password = admin_user_password, admin_user_ssh_key = admin_user_ssh_key,
                                  vnet_resourcegroup_name = vnet_resourcegroup_name, vnet_name = vnet_name,
                                  subnet_name = subnet_name, tags = tags, description = description)
  azureml$core$compute$ComputeTarget$create(workspace, cluster_name, compute_config)
}

#' Get compute. Returns NULL if compute is not found on workspace.
#' @param workspace workspace that has the cluster
#' @param cluster_name name of the cluster
#' @export
get_compute <- function(workspace, cluster_name)
{
  tryCatch(
    {
      azureml$core$compute$ComputeTarget(workspace = workspace, name = cluster_name)
    },
    error = function(e) {
      if (grepl("ComputeTargetException", e$message, ))
      {
        NULL
      }
      else
      {
        stop(message(e))
      }
    }
  )
}

#' Wait for cluster's instantiation
#' @param cluster cluster object
#' @param show_output show output on console
#' @export
wait_for_compute <- function(cluster, show_output = TRUE)
{
  cluster$wait_for_completion(show_output)
}

#' Delete compute
#' @param cluster cluster object
#' @export
delete_compute <- function(cluster)
{
  cluster$delete()
  invisible(NULL)
}

#' Create AksCompute
#' @param workspace workspace object
#' @param cluster_name cluster name
#' @param agent_count Number of agents (VMs) to host containers. Defaults to 3
#' @param vm_size Size of agent VMs. More details can be found here: https://aka.ms/azureml-vm-details.
#' Defaults to Standard_D3_v2
#' @param ssl_cname A CName to use if enabling SSL validation on the cluster. Must provide all three
#' CName, cert file, and key file to enable SSL validation
#' @param ssl_cert_pem_file A file path to a file containing cert information for SSL validation. Must provide
#' all three CName, cert file, and key file to enable SSL validation
#' @param ssl_key_pem_file A file path to a file containing key information for SSL validation. Must provide
#' all three CName, cert file, and key file to enable SSL validation
#' @param location Location to provision cluster in. If not specified, will default to workspace location.
#' Available regions for this compute can be found here:
#' https://azure.microsoft.com/en-us/global-infrastructure/services/?regions=all&products=kubernetes-service
#' @param vnet_resourcegroup_name Name of the resource group where the virtual network is located
#' @param vnet_name Name of the virtual network
#' @param subnet_name Name of the subnet inside the vnet
#' @param service_cidr A CIDR notation IP range from which to assign service cluster IPs.
#' @param dns_service_ip Containers DNS server IP address.
#' @param docker_bridge_cidr A CIDR notation IP for Docker bridge.
#' @return An AksCompute object representation of the compute object
#' @export
create_aks_compute <- function(workspace, cluster_name, agent_count = NULL, vm_size = NULL, ssl_cname = NULL, ssl_cert_pem_file = NULL,
                               ssl_key_pem_file = NULL, location = NULL, vnet_resourcegroup_name = NULL,
                               vnet_name = NULL, subnet_name = NULL, service_cidr = NULL,
                               dns_service_ip = NULL, docker_bridge_cidr = NULL)
{
  compute_config <- azureml$core$compute$AksCompute$provisioning_configuration(agent_count = agent_count, vm_size = vm_size,
                                                                               ssl_cname = ssl_cname, ssl_cert_pem_file = ssl_cert_pem_file, ssl_key_pem_file = ssl_key_pem_file,
                                                                               location = location,
                                                                               vnet_resourcegroup_name = vnet_resourcegroup_name, vnet_name = vnet_name,
                                                                               subnet_name = subnet_name, service_cidr = service_cidr,
                                                                               dns_service_ip = dns_service_ip, docker_bridge_cidr = docker_bridge_cidr)
  
  azureml$core$compute$ComputeTarget$create(workspace, cluster_name, compute_config)
}

#' Retrieve the credentials for the AKS target
#' @param cluster cluster object
#' @return Credentials for the AKS target
#' @export
get_aks_compute_credentials <- function(cluster)
{
  cluster$get_credentials()
}

#' Attach an already existing AKS compute resource with the provided workspace
#' @param workspace The workspace object to attach the Compute object to. 
#' @param cluster_name The AKS cluster name 
#' @param resource_id The Azure resource ID for the compute resource being attached
#' @param resource_group Name of the resource group in which the AKS is located. 
#' @return An AksCompute object representation of the compute object
#' @export
attach_aks_compute <- function(workspace, cluster_name, resource_id, resource_group = NULL)
{
  attach_config <- azureml$core$compute$AksCompute$attach_configuration(resource_group = resource_group, resource_id = resource_id)
  
  azureml$core$compute$ComputeTarget$attach(workspace, cluster_name, attach_config)
}

#' Detach the AksCompute object from its associated workspace
#' @param cluster cluster object
#' @export
detach_aks_compute <- function(cluster)
{
  cluster$detach()
  invisible(NULL)
}
