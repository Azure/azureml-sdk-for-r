% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compute.R
\name{update_aml_compute}
\alias{update_aml_compute}
\title{Update Scale settings for AmlCompute target.}
\usage{
update_aml_compute(cluster, min_nodes = NULL, max_nodes = NULL,
  idle_seconds_before_scaledown = NULL)
}
\arguments{
\item{cluster}{cluster object}

\item{min_nodes}{Minimum number of nodes to use on the cluster}

\item{max_nodes}{Maximum number of nodes to use on the cluster
idle_seconds_before_scaledown: Node idle time in seconds before 
scaling down the cluster}
}
\description{
Update Scale settings for AmlCompute target.
}