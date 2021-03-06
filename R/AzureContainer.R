#' List Storage containers for Specified Storage Account.
#'
#' @inheritParams setAzureContext
#' @inheritParams azureAuthenticate
#' @inheritParams azureSAGetKey

#' @family Container functions
#'
#' @export
azureListStorageContainers <- function(azureActiveContext, storageAccount, storageKey,
                                  resourceGroup, subscriptionID, verbose = FALSE) {
  azureCheckToken(azureActiveContext)

  if (missing(subscriptionID)) {
    subscriptionID <- azureActiveContext$subscriptionID
  } else (subscriptionID <- subscriptionID)
  if (missing(resourceGroup)) {
    resourceGroup <- azureActiveContext$resourceGroup
  } else (resourceGroup <- resourceGroup)
  if (missing(storageAccount)) {
    SAI <- azureActiveContext$storageAccount
  } else (SAI <- storageAccount)
  verbosity <- if (verbose)
    httr::verbose(TRUE) else NULL

  if (length(resourceGroup) < 1) {
    stop("Error: No resourceGroup provided: Use resourceGroup argument or set in AzureContext")
  }
  if (length(SAI) < 1) {
    stop("Error: No storageAccount provided: Use storageAccount argument or set in AzureContext")
  }

  STK <- if (length(azureActiveContext$storageAccountK) < 1 ||
      SAI != azureActiveContext$storageAccountK ||
      length(azureActiveContext$storageKey) < 1) {
    azureSAGetKey(azureActiveContext, resourceGroup = resourceGroup, storageAccount = SAI)
  } else {
    azureActiveContext$storageKey
  }


  if (length(STK) < 1) {
    stop("Error: No storageKey provided: Use storageKey argument or set in AzureContext")
  }

  URL <- paste("http://", SAI, ".blob.core.windows.net/?comp=list", sep = "")

  # r<-OLDazureblobCall(azureActiveContext,URL, 'GET', key=STK)

  D1 <- Sys.getlocale("LC_TIME")
  Sys.setlocale("LC_TIME", "C")
  `x-ms-date` <- format(Sys.time(), "%a, %d %b %Y %H:%M:%S %Z", tz = "GMT")
  Sys.setlocale("LC_TIME", D1)
  D1 <- format(Sys.time(), "%a, %d %b %Y %H:%M:%S %Z", tz = "GMT")

  SIG <- getSig(azureActiveContext, url = URL, verb = "GET", key = STK, storageAccount = SAI,
                CMD = "\ncomp:list", dateSig = D1)

  AT <- paste0("SharedKey ", SAI, ":", SIG)

  r <- GET(URL, add_headers(.headers = c(Authorization = AT, `Content-Length` = "0",
                                         `x-ms-version` = "2015-04-05",
                                         `x-ms-date` = D1)),
           verbosity)

  if (status_code(r) != 200) stopWithAzureError(r)
  r <- content(r, "text", encoding = "UTF-8")

  y <- htmlParse(r)

  namesx  <- xpathApply(y, "//containers//container/name", xmlValue)
  if (length(namesx) == 0) {
    message("No containers found in Storage account")
    return(
      data.frame(
        name            = character(0),
        `Last-Modified` = character(0),
        Status          = character(0),
        State           = character(0),
        Etag            = character(0),
        stringsAsFactors = FALSE
      )
    )
  }

  azureActiveContext$storageAccount <- SAI
  azureActiveContext$resourceGroup  <- resourceGroup
  azureActiveContext$storageKey     <- STK

  data.frame(
    name            = xpathSApply(y, "//containers//container/name", xmlValue),
    `Last-Modified` = xpathSApply(y, "//containers//container/properties/last-modified", xmlValue),
    Status          = xpathSApply(y, "//containers//container/properties/leasestatus", xmlValue),
    State           = xpathSApply(y, "//containers//container/properties/leasestate", xmlValue),
    Etag            = xpathSApply(y, "//containers//container/properties/etag",  xmlValue),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )

}


#' Create Storage containers in a specified Storage Account.
#'
#' @inheritParams setAzureContext
#' @inheritParams azureAuthenticate
#' @inheritParams azureSAGetKey

#' @family Container functions
#'
#' @export
azureCreateStorageContainer <- function(azureActiveContext, container, storageAccount,
                                   storageKey, resourceGroup, subscriptionID, verbose = FALSE) {
  # azureCheckToken(azureActiveContext)

  if (missing(subscriptionID)) {
    subscriptionID <- azureActiveContext$subscriptionID
  } else (subscriptionID <- subscriptionID)
  if (missing(resourceGroup)) {
    resourceGroup <- azureActiveContext$resourceGroup
  } else (resourceGroup <- resourceGroup)
  if (missing(storageAccount)) {
    SAI <- azureActiveContext$storageAccount
  } else (SAI <- storageAccount)
  if (missing(storageKey)) {
    STK <- azureActiveContext$storageKey
  } else (STK <- storageKey)
  if (missing(container)) {
    stop("Error: No container name provided")
  }
  verbosity <- if (verbose)
    httr::verbose(TRUE) else NULL

  if (length(resourceGroup) < 1) {
    stop("Error: No resourceGroup provided: Use resourceGroup argument or set in AzureContext")
  }
  if (length(SAI) < 1) {
    stop("Error: No storageAccount provided: Use storageAccount argument or set in AzureContext")
  }

  STK <- refreshStorageKey(azureActiveContext, SAI, resourceGroup)

  if (length(STK) < 1) {
    stop("Error: No storageKey provided: Use storageKey argument or set in AzureContext")
  }

  URL <- paste("https://", SAI, ".blob.core.windows.net//", container,
               "?restype=container", sep = "")


  # r<-OLDazureblobCall(azureActiveContext,URL, 'GET', key=STK)

  D1 <- Sys.getlocale("LC_TIME")
  Sys.setlocale("LC_TIME", "C")
  `x-ms-date` <- format(Sys.time(), "%a, %d %b %Y %H:%M:%S %Z", tz = "GMT")
  Sys.setlocale("LC_TIME", D1)
  D1 <- format(Sys.time(), "%a, %d %b %Y %H:%M:%S %Z", tz = "GMT")
  CNTR <- container

  azureActiveContext$container <- container
  azureActiveContext$storageAccount <- SAI
  azureActiveContext$resourceGroup <- resourceGroup

  URL <- paste("http://", SAI, ".blob.core.windows.net/", container,
               "?restype=container", sep = "")

  D1 <- Sys.getlocale("LC_TIME")
  Sys.setlocale("LC_TIME", "us")
  Sys.setlocale("LC_TIME", D1)
  D1 <- format(Sys.time(), "%a, %d %b %Y %H:%M:%S %Z", tz = "GMT")

  SIG <- getSig(azureActiveContext, url = URL, verb = "PUT", key = STK,
                storageAccount = SAI, container = CNTR,
                CMD = "\nrestype:container", dateSig = D1)

  AT <- paste0("SharedKey ", SAI, ":", SIG)
  r <- PUT(URL, add_headers(.headers = c(Authorization = AT, `Content-Length` = "0",
                                         `x-ms-version` = "2015-04-05",
                                         `x-ms-date` = D1)),
           verbosity)

  if (status_code(r) == 201) {
    message("OK. Container created.")
    return(TRUE)
  }
  if (status_code(r) == 409) {
    message("OK. The specified container already exists.")
    return(TRUE)
  }

  stopWithAzureError(r)
  message("OK")
  return(TRUE)
}


#' Delete Storage container in a specified Storage Account.
#'
#' @inheritParams setAzureContext
#' @inheritParams azureAuthenticate
#' @inheritParams azureSAGetKey

#' @family Container functions
#'
#' @export
azureDeleteStorageContainer <- function(azureActiveContext, container, storageAccount,
                                   storageKey, resourceGroup, subscriptionID, verbose = FALSE) {
  azureCheckToken(azureActiveContext)

  if (missing(subscriptionID)) {
    subscriptionID <- azureActiveContext$subscriptionID
  } else (subscriptionID <- subscriptionID)
  if (missing(resourceGroup)) {
    resourceGroup <- azureActiveContext$resourceGroup
  } else (resourceGroup <- resourceGroup)
  if (missing(storageAccount)) {
    SAI <- azureActiveContext$storageAccount
  } else (SAI <- storageAccount)
  if (missing(storageKey)) {
    STK <- azureActiveContext$storageKey
  } else (STK <- storageKey)
  if (missing(container)) {
    stop("Error: No container name provided")
  }
  verbosity <- if (verbose)
    httr::verbose(TRUE) else NULL

  CNTR <- container

  if (length(resourceGroup) < 1) {
    stop("Error: No resourceGroup provided: Use resourceGroup argument or set in AzureContext")
  }
  if (length(SAI) < 1) {
    stop("Error: No storageAccount provided: Use storageAccount argument or set in AzureContext")
  }

  STK <- refreshStorageKey(azureActiveContext, SAI, resourceGroup)
  if (length(STK) < 1) {
    stop("Error: No storageKey provided: Use storageKey argument or set in AzureContext")
  }


  URL <- paste("http://", SAI, ".blob.core.windows.net/", container,
               "?restype=container", sep = "")

  D1 <- Sys.getlocale("LC_TIME")
  Sys.setlocale("LC_TIME", "C")
  `x-ms-date` <- format(Sys.time(), "%a, %d %b %Y %H:%M:%S %Z", tz = "GMT")
  Sys.setlocale("LC_TIME", D1)
  D1 <- format(Sys.time(), "%a, %d %b %Y %H:%M:%S %Z", tz = "GMT")
  CNTR <- container

  azureActiveContext$container <- CNTR
  azureActiveContext$storageAccount <- SAI
  azureActiveContext$resourceGroup <- resourceGroup
  SIG <- getSig(azureActiveContext, url = URL, verb = "DELETE", key = STK,
                storageAccount = SAI,
                CMD = paste0(CNTR, "\nrestype:container"), dateSig = D1)

  AT <- paste0("SharedKey ", SAI, ":", SIG)

  r <- DELETE(URL, add_headers(.headers = c(Authorization = AT, `Content-Length` = "0",
                                            `x-ms-version` = "2015-04-05",
                                            `x-ms-date` = D1)),
              verbosity)

  if (status_code(r) == 202) {
    message("container delete request accepted")
    return(TRUE)
  }
  stop(paste0("Error: Return code(", status_code(r), ")"))
  message("OK")
  return(TRUE)
}
