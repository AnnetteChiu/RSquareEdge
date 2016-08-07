##' @include utils.R
NULL

## Make queries a bit easier
## used through `soda` interface
Soda <- function(x,var,...) UseMethod("Soda")
Soda.character <-  function(val, var) {
   sprintf("%s in(%s)", var, paste(shQuote(x), collapse = ", "))
}

## difference ".character", val is first, not second now (S3 concessions)
Soda.POSIXct <- function(vals, var) {
  
  if (length(vals) > 1) vals <- vals[1:2]
  compare_with <- ifelse(length(vals) == 1, ">=", "between")
  
  sprintf("%s %s %s", var, compare_with, paste(shQuote(x), collapse=" and "))
}



##' Create a BBOX object to define a bounding box based on latitudes and longitudes
##'
##' @param lats latitudes
##' @param lons longitudes
##' @export
bbox <- function(lats, lons) {
    lats <- range(as.numeric(lats), na.rm=TRUE)
    lons <- range(as.numeric(lons), na.rm=TRUE)
    
    out <- c(lats[1], lons[1], lats[2], lons[2])
    class(out) <- c("BBOX", class(out))  ## <--- why?
    out
}

## By adding a class we can now do:
Soda.BBOX <- function(b, var) {
    sprintf("within_box(%s, %2.6f, %2.6f, %2.6f, %2.6f)", var, b[1], b[2], b[3], b[4])
}
    
## How to combine queries? Natural to use `&` or `|`
## For that we can define these for a query class -- but as of now our `soda`
## outputs are just characters.
## Let's adjust that:

##' Constructor to create Query class object
Query <- function(x) {
    class(x) <- c("Query", class(x))
    x
}

##' Create a query using dispatch to control how
##'
##' @param x: value to dispatch on
##' @param var: a field name
##'
##' Examples: soda(c(now()-days(2), now()), "created_date") -- records within a time window
##' soda(bbox(lats, lons), "location")  -- return records within bounding box
##' soda("Noise - Residential", "complaint_type") -- match this complaint_type
##'
##' Queries can be combined with `&` or `|`
##' @export
soda <- function(x, var, ...) {
    if (length(var) > 1)
        warning("Only one variable at a time, first one being used.")
    Query(Soda(x, verify_name(var[1]), ...))
}

## combine queries logically
"&.Query" <- function(x, y)  Query(paste(x, y, sep=" and "))
"|.Query" <- function(x, y)  Query(paste(x, y, sep=" or "))
