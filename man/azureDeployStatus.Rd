% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AzureTemplate.R
\name{azureDeployStatus}
\alias{azureDeployStatus}
\title{Check Template Deployment Status.}
\usage{
azureDeployStatus(azureActiveContext, deplname, resourceGroup, subscriptionID,
  verbose = FALSE)
}
\arguments{
\item{azureActiveContext}{A container used for caching variables used by AzureSMR}

\item{deplname}{deplname}

\item{resourceGroup}{Name of the resource group}

\item{subscriptionID}{Set the subscriptionID.  This is obtained automatically by \code{\link[=azureAuthenticate]{azureAuthenticate()}} when only a single subscriptionID is available via Active Directory}

\item{verbose}{Print Tracing information (Default False)}
}
\description{
Check Template Deployment Status.
}
\seealso{
Other Template functions: \code{\link{azureCancelDeploy}},
  \code{\link{azureDeleteDeploy}},
  \code{\link{azureDeployTemplate}}
}
