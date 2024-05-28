#' Author: Cole Brookson
#' Date: 2024-05-27
#' Description: Initial file demonstrating the general process of grid
#' generation and krigging onto it

library(sf)
library(dplyr)
library(stringr)
library(ggplot2)
library(gstat)
library(here)

# REMEMBER TO CHANGE THE PATH FOR YOUR CASE
germany_sf <- sf::st_read(here::here("./data/plz-5stellig.shp")) %>%
    st_as_sf()
germany_code_matches <- readr::read_csv(here::here(
    "./data/zuordnung_plz_ort.csv"
))
pharos_data <- readr::read_csv(here::here(
    "./data/pharos_data.csv"
))

# look at the column names of the sf document and re-name into easy
# recognizable english
names(germany_sf)
germany_sf <- germany_sf %>% dplyr::rename(
    "zip_code" = "plz", "population" = "einwohner", "km_sq" = "qkm"
)
names(germany_sf) # see what the new names look like

# do the same re-naming to the code matches dataset
names(germany_code_matches)
germany_code_matches <- germany_code_matches %>% dplyr::rename(
    "zip_code" = "plz", "location" = "ort", "district" = "landkreis",
    "federal_state" = "bundesland"
)

# NOTE
#' So the important thing to note here is this is data for ALL of germany. We
#' don't really want everything in the whole country, we only want the zip codes
#' that are in berlin. So how will we do this? We have two datasets here -
#' the `germany_sf` one is where the actual spatial polygon data are, but the
#' city code is in the other dataframe, so we should filter that data file to
#' just the Berlin codes, and then use the codes remaining to just keep the
#' polygons we want

# filter the `germany_code_matches` data to only the postal codes that are
# in berlin
berlin_codes <- germany_code_matches[which(
    germany_code_matches$location == "Berlin"
), ]
berlin_sf <- germany_sf[which(germany_sf$zip_code %in% berlin_codes$zip_code), ]

# plot with a population fill just for fun
ggplot2::ggplot(berlin_sf) +
    geom_sf() +
    theme_void()

# NOTE
#' Now let's sample this whole area with points, so we can then perform the
#' kirgging to the points we have data for
grid_sample <- sf::st_sample(
    sf::st_as_sfc(berlin_sf),
    # the size is really large to make a fine grid - you can change this
    size = 10000, type = "regular"
) %>%
    sf::st_as_sf()
# this is important to make sure our georefs are the same
sf::st_crs(grid_sample) <- 4326

# plot these two to show how it looks
ggplot() +
    geom_sf(data = berlin_sf, fill = "grey30") +
    geom_sf(data = grid_sample, colour = "red", size = 4) +
    theme_void() +
    coord_sf()

# NOTE
# now we need to figure out how to make the points about berlin foxes talk to
# the points that we've just sampled on the grid in berlin

# first, make sure the data are of the same type (sf)
pharos_sf <- sf::st_as_sf(pharos_data, coords = c("longitude", "latitude"))

# set the coordinates for WGS84
sf::st_crs(pharos_sf) <- 4326

# make sure we can plot them all on the same geo-location
ggplot() +
    geom_sf(data = berlin_sf, aes(fill = population), alpha = 0.3) +
    geom_sf(data = grid_sample, colour = "red", size = 2) + # sampled points
    geom_sf(data = pharos_sf, colour = "purple", size = 3) + # foxes!
    theme_void() +
    coord_sf()

# for mapping purposes, it would be nice to have a single polygon of berlin
# that doesn't include the postal codes but is just one big thing
berlin_poly <- sf::st_union(berlin_sf)
ggplot() +
    geom_sf(data = berlin_poly) # this is what we want

# NOTE
#' now we want to be able to put the various data we have into a format that
#' will let us do indicator kriging on it -- binary logical data
pharos_sf <- pharos_sf[which(
    pharos_sf$detection_outcome != "inconclusive"
), ]
pharos_sf$detection_outcome[which(
    pharos_sf$detection_outcome == "positive"
)] <- TRUE
pharos_sf$detection_outcome[which(
    pharos_sf$detection_outcome == "negative"
)] <- FALSE
pharos_sf$detection_outcome <- as.logical(pharos_sf$detection_outcome)
sf::st_crs(pharos_sf) <- 4326
sf::st_crs(pharos_sf)
# variograms
varg <- gstat::variogram(detection_outcome ~ 1, data = pharos_sf)
plot(varg)
vgm <- gstat::vgm(
    psill = 0.20, # semivariance at the range
    range = 1, # distance of the plateau
    nugget = 0.01, # intercept (sorta)
    model = "Exp" # spherical model
)
plot(varg, vgm)
fit_varg <- gstat::fit.variogram(varg, vgm)

# now the kriging part
krig <- gstat::krige(
    detection_outcome ~ 1,
    locations = pharos_sf,
    newdata = grid_sample,
    model = fit_varg,
    nmax = 5
)
# plot(krig["var1.pred"])

ggplot() +
    geom_sf(data = berlin_poly, alpha = 0.3) +
    # geom_sf(data = grid_sample, colour = "red", size = 2) + # sampled points
    geom_sf(data = krig, aes(fill = var1.pred), shape = 21, size = 3) +
    geom_sf(data = pharos_sf, aes(colour = detection_outcome), size = 3) + # foxes
    scale_fill_viridis_c("probability", na.value = "white") +
    scale_colour_manual("test outcome", values = c("#8a56b8", "#d5363d")) +
    theme_void() +
    coord_sf()
