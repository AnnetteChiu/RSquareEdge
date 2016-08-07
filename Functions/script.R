require(jsonlite)
require(dplyr)
require(lubridate)

# fields are https://dev.socrata.com/foundry/data.cityofnewyork.us/fhrw-4uyv
baseurl = "https://data.cityofnewyork.us/resource/fhrw-4uyv.json"

## grab last two days: created_date
d2 = now()
d1 = d2 - days(2)

d1 = sprintf("%4d-%02d-%02dT%02d:%02d:%3.3f", year(d1), month(d1), day(d1), hour(d1), minute(d1), second(d1))
d2 = sprintf("%4d-%02d-%02dT%02d:%02d:%3.3f", year(d2), month(d2), day(d2), hour(d2), minute(d2), second(d2))


query = sprintf("%s?$where=created_date between '%s' and '%s'", baseurl, d1, d2)
query = URLencode(query)
query = gsub("'", "%27", query)

a = fromJSON(query)

## what to do now?

## most common complaints:
sort(table(a$complaint_type))  # Noise - Residential

## Let's visualize
filter(a, complaint_type == "Noise - Residential")

## Oh Issue with `location` -- it reads in as a data frame
sapply(a, class)

## not needed (redundant longitude and latitude are there)
a$location <- NULL

##
noisy_neighbors <- filter(a, complaint_type == "Noise - Residential")

## where are they?
require(RgoogleMaps)
noisy_neighbors[["longitude"]] = as.numeric(noisy_neighbors[["longitude"]])
noisy_neighbors[["latitude"]] = as.numeric(noisy_neighbors[["latitude"]])

center <- sapply(select(noisy_neighbors,latitude, longitude), mean, na.rm=TRUE)
map <- GetMap(center=center, zoom=11)

## Translate original data
coords <- with(noisy_neighbors, LatLon2XY.centered(map, latitude, longitude, 11))
coords <- data.frame(coords)

# Plot
PlotOnStaticMap(map)
points(coords$newX, coords$newY, pch=16, cex=0.3)


## Zoom is bad, better to use a bounding box
bb <- with(noisy_neighbors, qbbox(latitude, longitude))
map <- GetMap.bbox(bb$latR, bb$lonR)
## Translate original data
coords <- with(noisy_neighbors, LatLon2XY.centered(map, latitude, longitude))
coords <- data.frame(coords)

# Plot
PlotOnStaticMap(map)
with(coords, points(newX, newY, pch=16, cex=0.3))

## What the???
## GetMap.bbox is lon, lat -- not lat, lon:
map <- GetMap.bbox(bb$lonR, bb$latR)
## Translate original data
coords <- with(noisy_neighbors, LatLon2XY.centered(map, latitude, longitude))
coords <- data.frame(coords)

# Plot
PlotOnStaticMap(map)
with(coords, points(newX, newY, pch=16, cex=0.3))


## Let's look at a neighborhood over a bigger period of time
lat = 40.7104541
lon = -73.9644729
## . At 38 degrees North latitude, one degree of latitude equals approximately 364,000 ft (69 miles), one minute equals 6068 ft (1.15 miles), one-second equals 101 ft; https://www2.usgs.gov/faq/categories/9794/3022
## so one block is 1/12 a mile or about 1/60/15 -- third decimal
lats = c(lat - 0.001, lat + 0.001)
lons = c(lon - 0.001, lon + 0.001)

condition_1 <- sprintf("within_box(location, %2.6f, %2.6f, %2.6f, %2.6f)", lats[1], lons[1], lats[2], lons[2])
condition_2 <- sprintf("complaint_type='Noise - Residential'")
query = sprintf("%s?$where=%s and %s", baseurl, condition_1, condition_2)
query = URLencode(query)
query = gsub("'", "%27", query)

a = fromJSON(query)

dim(a)

## when created
a$created_date  # string

a$created_date <- ymd_hms(a$created_date) # R date-time format

## how to visualize? simple count by month by year:
xtabs(~month(created_date) + year(created_date),a)
