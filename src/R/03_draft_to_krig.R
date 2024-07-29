#trying to figure  out how to krig the new data

library(sf)
library(dplyr)
library(stringr)
library(ggplot2)
library(gstat)
library(here)
library(raster)
library(terra)

# read in data 
germany_sf <- sf::st_read(here::here("./data/raw/geo-data/")) %>%
  st_as_sf()
germany_code_matches <- readr::read_csv(here::here(
  "./data/raw/zuordnung_plz_ort.csv"
))
coord50_1 <- readr::read_table(here::here(
  "./data/clean/coord50_1.txt"), col_names = FALSE)

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

# NOTE
# First try ====
# Here I tried to import our data (coord50_1) in our previous kriging script
# This is for indicator kriging (or discreet)

# Grid
grid_sample <- sf::st_sample(
  sf::st_as_sfc(berlin_sf),
  size = 10000, type = "regular"
) %>%
  sf::st_as_sf()
sf::st_crs(grid_sample) <- 4326

ggplot2::ggplot() +
  geom_sf(data = berlin_sf, fill = "grey30") +
  geom_sf(data = grid_sample, colour = "red", size = 4) +
  theme_void() +
  coord_sf()

# set the coordinates for WGS84
coord50_1sf <- sf::st_as_sf(coord50_1, coords = c("X1", "X2"))
sf::st_crs(coord50_1sf) <- 4326

# isn't looking normal
ggplot2::ggplot() +
  geom_sf(data = berlin_sf, aes(fill = population), alpha = 0.3) +
  geom_sf(data = grid_sample, colour = "red", size = 2) + 
  geom_sf(data = coord50_1sf, colour = "purple", size = 3) + 
  theme_void() +
  coord_sf()

berlin_poly <- sf::st_union(berlin_sf)
ggplot2::ggplot() +
  geom_sf(data = berlin_poly) + 
  theme_void()

# variograms
varg <- gstat::variogram(X3 ~ 1, data = coord50_1sf)
plot(varg)

#did my best here
vgm0 <- gstat::vgm(
  psill = 0.05, # semivariance at the range
  range = 500, # distance of the plateau
  nugget = 0.005, # intercept (sorta)
  model = "Exp" # spherical model
)
plot(varg,vgm0)

png(filename = here::here("./figs/varg-vgm-005-500-0005-Exp.png")) 
plot(varg, vgm0) 
dev.off() 

fit_varg <- gstat::fit.variogram(varg, vgm0)

# kriging 
krig <- gstat::krige(
  X3 ~ 1,
  locations = coord50_1sf,
  newdata = grid_sample,
  model = fit_varg,
  nmax = 5
)

plot(krig["var1.pred"])

krig_and_foxes <- ggplot2::ggplot() +
  geom_sf(data = berlin_poly, alpha = 0.3) +
  geom_sf(data = krig, aes(fill = var1.pred), shape = 21, size = 3) +
  geom_sf(data = coord50_1sf, aes(colour = X3), size = 2) + # foxes
  scale_fill_viridis_c("probability", na.value = "white") +
  scale_colour_manual("test outcome", values = c("#8a56b8", "#d5363d")) +
  theme_void() +
  coord_sf()

ggplot2::ggsave(
  filename = here::here("./figs/krigging-with-foxes-outcomes.png"),
  plot = krig_and_foxes,
  height = 6,
  width = 8,
  bg = "white" 
)

plot(krig_and_foxes) #isn't looking normal


# NOTE
# Second try ====
# Here I tried to follow this https://rpubs.com/nabilabd/118172 
# for continuous krig
library(sp)
library(gstat)
suppressPackageStartupMessages({
  library(dplyr) # for "glimpse"
  library(ggplot2)
  library(scales) # for "comma"
  library(magrittr)
})

#prep de data
coordinates(coord50_1) <- ~ X1 + X2

#variogram
lzn.vgm <- variogram(X3~1, data=coord50_1) 
plot(lzn.vgm)

lzn.model <- gstat::vgm( 
  psill = 0.06, # semivariance at the range
  range = 75, # distance of the plateau
  nugget = 0.005, # intercept (sorta)
  model = "Exp") # spherical model
plot(lzn.vgm, lzn.model)

#png(filename = here::here("./figs/varg-vgm-006-75-0005-Exp.png")) 
#plot(lzn.vgm, lzn.model) 
#dev.off() 

lzn.fit <- fit.variogram(lzn.vgm, lzn.model) 

grid_sample <- sf::st_sample(
  sf::st_as_sfc(berlin_sf),
  size = 10000, type = "regular"
)
coords <- st_coordinates(grid_sample)
berlin_grid <- as.data.frame(coords)
coordinates(berlin_grid) <- ~ X + Y

lzn.kriged <- krige(X3 ~ 1, coord50_1, grid_sample, model=lzn.fit)

lzn.kriged %>% as.data.frame %>%
  ggplot(aes(x=x, y=y)) + geom_tile(aes(fill=var1.pred)) + coord_equal() +
  scale_fill_gradient(low = "yellow", high="red") +
  scale_x_continuous(labels=comma) + scale_y_continuous(labels=comma) +
  theme_bw()
names(lzn.kriged) #x and y doesn't exist

#png(filename = here::here("./figs/coord50_1_kriged")) 
#plot(lzn.kriged) 
#dev.off() 
