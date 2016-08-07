##' @include request.R
NULL



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





