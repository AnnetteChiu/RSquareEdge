require(jsonlite)
require(lubridate)
require(RgoogleMaps)
require(dplyr)

# fields are https://dev.socrata.com/foundry/data.cityofnewyork.us/fhrw-4uyv
baseurl = "https://data.cityofnewyork.us/resource/fhrw-4uyv.json"
varnames <- c('address_type', 'agency', 'agency_name', 'borough', 'city', 'closed_date', 'community_board', 'complaint_type', 'created_date', 'cross_street_1', 'cross_street_2', 'descriptor', 'due_date', 'facility_type', 'incident_address', 'incident_zip', 'latitude', 'location.type', 'location.coordinates1', 'location.coordinates2', 'location_type', 'longitude', 'park_borough', 'park_facility_name', 'resolution_action_updated_date', 'resolution_description', 'school_address', 'school_city', 'school_code', 'school_name', 'school_not_found', 'school_number', 'school_phone_number', 'school_region', 'school_state', 'school_zip', 'status', 'street_name', 'unique_key', 'x_coordinate_state_plane', 'y_coordinate_state_plane')
varnames <- sapply(varnames, identity, simplify=FALSE)

## return full name or stop if not a partial match
verify_name <- function(nm) {
    out <- varnames[[nm, exact=FALSE]]
    if (is.null(out))
        stop(nm, " does not match")
    out
}

## conveniences
posix_to_timestamp <- function(d) {
    sprintf("%4d-%02d-%02dT%02d:%02d:%3.3f", year(d), month(d), day(d), hour(d), minute(d), second(d))
}

## testit
sapply(c(now()-days(2), now()), posix_to_timestamp)

## encode URL with ' as %27
encodeURL <- function(query) {
    query <- URLencode(query)
    query <- gsub("'", "%27", query)  # XXX fails on "can't" ...
    query
}


## make queries easier
## different types
## * character
soda_character <- function(var, val) {
    sprintf("%s='%s'", var, val)  ## could use shQuote(val) and just %s ...
}

soda_date <- function(var, from, to=NULL) {
    if (is.null(to)) {
        sprintf("%s>='%s'", var, posix_to_timestamp(from))
    } else {
        sprintf("%s between '%s' and '%s'", var, posix_to_timestamp(from), posix_to_timestamp(to))
    }
}

## Here var is a some type of objectd [https://dev.socrata.com/docs/functions/within_box.html] location is a Point
soda_bbox <- function(var, lats, lons) {
    sprintf("within_box(%s, %2.6f, %2.6f, %2.6f, %2.6f)", var, lats[1], lons[1], lats[2], lons[2])
}


## with this we have
#condition_1 <- soda_bbox("location", lats, lons)
#condition_2 <- soda_character("complaint_type", "Noise - Residential")

## But this is kinda *ugly*. Why: same verb "soda", computer should make it easier for us to do this
## Enter S3 functions
Soda <- function(x,...) UseMethod("Soda")
Soda.character <-  function(val, var) {
    sprintf("%s='%s'", var, val)  ## could use shQuote(val) and just %s ...
}

## difference ".character", val is first, not second now (S3 concessions)
Soda.POSIXct <- function(from, var, to=NULL) {
    if (is.null(to)) {
        out <- sprintf("%s>='%s'", var, posix_to_timestamp(from))
    } else {
        out <- sprintf("%s between '%s' and '%s'", verify_name(var), posix_to_timestamp(from), posix_to_timestamp(to))
    }
    out
}


## what about bounding box? Well, we can compute this from data:
bbox <- function(lats, lons) {
    lats <- range(as.numeric(lats), na.rm=TRUE)
    lons <- range(as.numeric(lons), na.rm=TRUE)
    
    out <- c(lats[1], lons[1], lats[2], lons[2])
    class(out) <- c("BBOX", class(out))  ## <--- why?
    out
}

## By adding a class we can now do:
Soda.BBOX <- function(b, var) {
    sprintf("withbox(%s, %2.6f, %2.6f, %2.6f, %2.6f)", var, b[1], b[2], b[3], b[4])
}
    
## How to combine queries? Natural to use `&` or `|`
## For that we can define these for a query class -- but as of now our `soda`
## outputs are just characters.
## Let's adjust that:
Query <- function(x) {
    class(x) <- c("Query", class(x))
    x
}
soda <- function(x, var, ...) Query(Soda(x, verify_name(var), ...))

## and now

"&.Query" <- function(x, y)  Query(paste(x, y, sep=" and "))
"|.Query" <- function(x, y)  Query(paste(x, y, sep=" or "))

## request a data set
## A more robust method is here https://github.com/Chicago/RSocrata/tree/master/R
request <- function(query) {
    urls <- sprintf("%s?$where=%s", baseurl, query)
    urls <- sapply(urls, encodeURL)
    out <- Reduce(rbind, lapply(urls, fromJSON))  # vectorized, just df_request(url)  otherwise
    out <- tidy_up(out)
    class(out) <- c("Response", class(out))
    out
}

## tidy data frame
tidy_up <- function(d) {
    d$location <- NULL # clean up
    for (nm in c("created_date", "due_date"))
        d[[nm]] <- ymd_hms(d[[nm]])
    for (nm in c("latitude", "longitude"))
        d[[nm]] <- as.numeric(d[[nm]])
    d
}


## visualize queries
plot.Response <- function(a, pch=16, cex=0.3, ...) {
    bb <- with(a, qbbox(latitude, longitude))
    map <- GetMap.bbox(bb$lonR, bb$latR)
    
    ## Translate original data
    coords <- with(a, LatLon2XY.centered(map, latitude, longitude))
    coords <- data.frame(coords)
    
                                        # Plot
    PlotOnStaticMap(map)
    with(coords, points(newX, newY, pch=pch, cex=cex, ...))
    
}





