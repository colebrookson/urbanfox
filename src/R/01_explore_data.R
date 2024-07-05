# Explore the data

# Krigging 50 points ====
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
pharos_coord <- read.delim(here::here(
  "./julia/coord_pharos.txt"
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
pharos_sf2 <- sf::st_as_sf(pharos_coord, coords = c("x", "y"))
sf::st_crs(pharos_sf2) <- 4326

# make sure we can plot them all on the same geo-location
ggplot2::ggplot() +
  geom_sf(data = berlin_sf, aes(fill = population), alpha = 0.3) +
  geom_sf(data = grid_sample, colour = "red", size = 2) + # sampled points
  geom_sf(data = pharos_sf2, colour = "purple", size = 3) + # foxes!
  theme_void() +
  coord_sf()

# for mapping purposes, it would be nice to have a single polygon of berlin
# that doesn't include the postal codes but is just one big thing
berlin_poly <- sf::st_union(berlin_sf)
ggplot2::ggplot() +
  geom_sf(data = berlin_poly) +# this is what we want
  theme_void()

# variograms 
varg <- gstat::variogram(detection_outcome ~ 1, data = pharos_sf2) #by what do I replace detection_outcome
plot(varg)
## best option 
vgm0 <- gstat::vgm(
  psill = 0.20, # semivariance at the range
  range = 1, # distance of the plateau
  nugget = 0.005, # intercept (sorta)
  model = "Exp" # spherical model
)
fit_varg <- gstat::fit.variogram(varg, vgm0)

# krigging 
krig <- gstat::krige(
  detection_outcome ~ 1,
  locations = pharos_sf2,
  newdata = grid_sample,
  model = fit_varg,
  nmax = 5
)
plot(krig["var1.pred"])

krig_and_foxes <- ggplot2::ggplot() +
  geom_sf(data = berlin_poly, alpha = 0.3) +
  geom_sf(data = krig, aes(fill = var1.pred), shape = 21, size = 3) +
  geom_sf(data = pharos_sf2, aes(colour = detection_outcome), size = 2) + # foxes
  scale_fill_viridis_c("probability", na.value = "white") +
  scale_colour_manual("test outcome", values = c("#8a56b8", "#d5363d")) +
  theme_void() +
  coord_sf()
## map 1 ====
plot(krig_and_foxes)

# With entropy ====


#krig with 10, 100, 500 points


