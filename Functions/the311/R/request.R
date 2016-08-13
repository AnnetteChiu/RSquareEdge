##' @include query.R
NULL

## constant
baseurl <- "https://data.cityofnewyork.us/resource/fhrw-4uyv.json"


## create a query
query_to_url <- function(query) {
    urls <- sprintf("%s?$where=%s", baseurl, query)
    urls <- encodeURL(encodeURL)
    urls
}


##' Request a subset of the 311 data set
##' @param query A query built up using `soda` calls
##' @note A more robust method is here https://github.com/Chicago/RSocrata
##' @export
request <- function(query) {
    urls <- query_to_url(query)
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
    tbl_df(d)
}

