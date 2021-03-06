% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AzureBlob.R
\name{azureDeleteBlob}
\alias{azureDeleteBlob}
\title{Delete a specifed Storage blob.}
\usage{
azureDeleteBlob(azureActiveContext, blob, directory, storageAccount, storageKey,
  container, resourceGroup, verbose = FALSE)
}
\arguments{
\item{azureActiveContext}{A container used for caching variables used by AzureSMR}

\item{blob}{Blob name}

\item{directory}{Blob store directory to list for content}

\item{storageAccount}{Name of the azure storage account}

\item{storageKey}{Storage key associated with storage account}

\item{container}{Storage container name. See \code{\link[=azureListStorageContainers]{azureListStorageContainers()}}}

\item{resourceGroup}{Name of the resource group}

\item{verbose}{Print Tracing information (Default False)}
}
\description{
Delete a specifed Storage blob.
}
\seealso{
Other Blob store functions: \code{\link{azureBlobCD}},
  \code{\link{azureBlobFind}}, \code{\link{azureBlobLS}},
  \code{\link{azureGetBlob}},
  \code{\link{azureListStorageBlobs}},
  \code{\link{azurePutBlob}}
}
