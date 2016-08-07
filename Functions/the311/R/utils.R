
# fields are https://dev.socrata.com/foundry/data.cityofnewyork.us/fhrw-4uyv
varnames <- c('address_type', 'agency', 'agency_name', 'borough', 'city', 'closed_date', 'community_board', 'complaint_type', 'created_date', 'cross_street_1', 'cross_street_2', 'descriptor', 'due_date', 'facility_type', 'incident_address', 'incident_zip', 'latitude', 'location.type',  'location', 'location_type', 'longitude', 'park_borough', 'park_facility_name', 'resolution_action_updated_date', 'resolution_description', 'school_address', 'school_city', 'school_code', 'school_name', 'school_not_found', 'school_number', 'school_phone_number', 'school_region', 'school_state', 'school_zip', 'status', 'street_name', 'unique_key', 'x_coordinate_state_plane', 'y_coordinate_state_plane')
## create a named list
varnames <- sapply(varnames, identity, simplify=FALSE)

##' return full name or stop if not a partial match
##' @param nm a column name
verify_name <- function(nm) {
    out <- varnames[[nm, exact=FALSE]]
    if (is.null(out))
        stop(nm, " does not match")
    out
}

##' convert posix time into timestamp format
##' @param d a posix time
posix_to_timestamp <- function(d) {
    sprintf("%4d-%02d-%02dT%02d:%02d:%3.3f", year(d), month(d), day(d), hour(d), minute(d), second(d))
}


##' encode URL with ' as %27
##' @param query a string
##' @note this should use `shQuote`
encodeURL <- function(query) {
    query <- URLencode(query)
    query <- gsub("'", "%27", query)  # XXX fails on "can't" ...
    query
}
