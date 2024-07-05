#Prep for the krigging of 50 pts
# load packages
library(sf)
library(dplyr)
library(stringr)
library(ggplot2)
library(gstat)
library(here)

# read in data 
germany_sf <- sf::st_read(here::here("./data/raw/geo-data/")) %>%
  st_as_sf()
germany_code_matches <- readr::read_csv(here::here(
  "./data/raw/zuordnung_plz_ort.csv"
))
pharos_data <- readr::read_csv(here::here(
  "./data/raw/pharos_data.csv"
))
pharos_coord <- read.delim(here::here(
  "./data/clean/coord_pharos.txt"
))

# clean up data 
names(germany_sf)
germany_sf <- germany_sf %>% dplyr::rename(
  "zip_code" = "plz", "population" = "einwohner", "km_sq" = "qkm"
)
names(germany_code_matches)
germany_code_matches <- germany_code_matches %>% dplyr::rename(
  "zip_code" = "plz", "location" = "ort", "district" = "landkreis",
  "federal_state" = "bundesland"
)
berlin_codes <- germany_code_matches[which(
  germany_code_matches$location == "Berlin"
), ]
berlin_sf <- germany_sf[which(germany_sf$zip_code %in% berlin_codes$zip_code), ]

grid_sample <- sf::st_sample(
  sf::st_as_sfc(berlin_sf),
  size = 10000, type = "regular"
) %>%
  sf::st_as_sf()
sf::st_crs(grid_sample) <- 4326

# first, make sure the data are of the same type (sf)
pharos_sf <- sf::st_as_sf(pharos_data, coords = c("longitude", "latitude"))
sf::st_crs(pharos_sf) <- 4326

# make sure we can plot them all on the same geo-location
ggplot2::ggplot() +
  geom_sf(data = berlin_sf, aes(fill = population), alpha = 0.3) +
  geom_sf(data = grid_sample, colour = "red", size = 2) + # sampled points
  geom_sf(data = pharos_sf, colour = "purple", size = 3) + # foxes!
  theme_void() +
  coord_sf()

# for mapping purposes, it would be nice to have a single polygon of berlin
# that doesn't include the postal codes but is just one big thing
berlin_poly <- sf::st_union(berlin_sf)
ggplot2::ggplot() +
  geom_sf(data = berlin_poly) +# this is what we want
  theme_void()

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

# Trouver les points dupliqués (tolérance de distance très petite)
tolerance <- 1e-9
duplicates <- st_is_within_distance(pharos_sf, pharos_sf, dist = tolerance)
# Supprimer les doublons 
unique_indices <- which(!duplicated(duplicates))
pharos_sf <- pharos_sf[unique_indices, ]

# Extract xy from sf
pharos_sf  <- pharos_sf %>%
    dplyr::mutate(lon = sf::st_coordinates(.)[,1],
                  lat = sf::st_coordinates(.)[,2]) 
pharos_location <- data.frame(
  x = pharos_sf$lat,
  y = pharos_sf$lon
  #detection_outcome = pharos_sf$detection_outcome
)
readr::write_csv(pharos_location, 
                 file=here::here("./data/clean/pharos_location.csv"),
                 col_names = FALSE)

# Filtrer les 50 données
pharos_50 <- pharos_location[which(
  pharos_location$x %in% pharos_coord50$x & 
    pharos_location$y %in% pharos_coord50$y
), ]

# variograms 
varg50 <- gstat::variogram(detection_outcome ~ 1, data = pharos_50) #by what do I replace detection_outcome
vgm50 <- gstat::vgm(
  psill = 0.20, # semivariance at the range
  range = 1, # distance of the plateau
  nugget = 0.005, # intercept (sorta)
  model = "Exp" # spherical model
)
fit_varg50 <- gstat::fit.variogram(varg50, vgm50)

