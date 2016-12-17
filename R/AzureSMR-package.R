#' Install packages from snapshots on the checkpoint server for reproducibility
#'
#' THe AzureSMR package connects R to the Azure Service Manager API.
#'
#' This enables you to use and change many Azure resources, including:
#'
#' \itemize{
#' \item Storage Blobs
#' \item HDInsight (Nodes, Hive, Spark)
#' \item Azure Resource Manager
#' \item Virtual Machines
#' }
#'
#'
#' @name AzureSMR-package
#' @aliases AzureSMR
#' @docType package
#' @keywords package
#'
#' @importFrom utils browseURL ls.str
#' @importFrom digest hmac
#' @importFrom base64enc base64encode base64decode
#' @importFrom plyr rbind.fill
#'
#' @import httr
#' @import jsonlite
#' @import XML
#' @import plyr
#' @import base64enc
#' @import curl
#' @import digest
NULL