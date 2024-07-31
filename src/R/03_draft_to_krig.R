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
coordinates(coord500) <- ~ X1 + X2

#variogram
lzn.vgm <- variogram(X3~1, data=coord500) 
plot(lzn.vgm)

lzn.model <- gstat::vgm( 
  psill = 0.060, # semivariance at the range
  range = 100, # distance of the plateau
  nugget = 0.005, # intercept (sorta)
  model = "Exp") # spherical model
plot(lzn.vgm, lzn.model)

#png(filename = here::here("./figs/varg-vgm-006-75-0005-Exp.png")) 
#plot(lzn.vgm, lzn.model) 
#dev.off() 

lzn.fit <- fit.variogram(lzn.vgm, lzn.model) 

#grid_sample <- sf::st_sample(
 # sf::st_as_sfc(berlin_sf),
  #size = 10000, type = "regular"
#)
#coords <- st_coordinates(grid_sample)
#berlin_grid <- as.data.frame(coords)
#coordinates(berlin_grid) <- ~ X + Y

lzn.kriged500 <- krige(X3 ~ 1, coord500, berlin_grid, model=lzn.fit)

#lzn.kriged %>% as.data.frame %>%
 # ggplot(aes(x=X, y=Y)) + geom_tile(aes(fill=var1.pred)) + coord_equal() +
  #scale_fill_gradient(low = "yellow", high="red") +
  #scale_x_continuous(labels=comma) + scale_y_continuous(labels=comma) +
  #theme_bw()

# NOTE : the saved png isn't looking good, I prefer to export it manually
#png(filename = here::here("./figs/coord50_1_kriged.png")) 
#plot(lzn.kriged) 
#dev.off() 