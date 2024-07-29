# Explore the data

library(sp)
library(gstat)
suppressPackageStartupMessages({
  library(dplyr) # for "glimpse"
  library(ggplot2)
  library(scales) # for "comma"
  library(magrittr)
})

coord50_1 <- readr::read_table(here::here(
  "./data/clean/coord50_1.txt"), col_names = FALSE)
coord50_2 <- readr::read_table(here::here(
  "./data/clean/coord50_2.txt"), col_names = FALSE)
coord50_3 <- readr::read_table(here::here(
  "./data/clean/coord50_3.txt"), col_names = FALSE)
coord50_4 <- readr::read_table(here::here(
  "./data/clean/coord50_4.txt"), col_names = FALSE)
coord50_5 <- readr::read_table(here::here(
  "./data/clean/coord50_5.txt"), col_names = FALSE)
coord50_6 <- readr::read_table(here::here(
  "./data/clean/coord50_6.txt"), col_names = FALSE)
coord50_7 <- readr::read_table(here::here(
  "./data/clean/coord50_7.txt"), col_names = FALSE)
coord50_8 <- readr::read_table(here::here(
  "./data/clean/coord50_8.txt"), col_names = FALSE)
coord50_9 <- readr::read_table(here::here(
  "./data/clean/coord50_9.txt"), col_names = FALSE)
coord50_10 <- readr::read_table(here::here(
  "./data/clean/coord50_10.txt"), col_names = FALSE)
coord10 <- readr::read_table(here::here(
  "./data/clean/coord10.txt"), col_names = FALSE)
coord100 <- readr::read_table(here::here(
  "./data/clean/coord100.txt"), col_names = FALSE)
coord200 <- readr::read_table(here::here(
  "./data/clean/coord200.txt"), col_names = FALSE)
coord300 <- readr::read_table(here::here(
  "./data/clean/coord300.txt"), col_names = FALSE)
coord500 <- readr::read_table(here::here(
  "./data/clean/coord500.txt"), col_names = FALSE)
#coord1000 <- readr::read_table(here::here("./data/clean/coord1000.txt"), col_names = FALSE)
#coord2000 <- readr::read_table(here::here("./data/clean/coord2000.txt"), col_names = FALSE)
#coord5000 <- readr::read_table(here::here("./data/clean/coord5000.txt"), col_names = FALSE)
#coord10000 <- readr::read_table(here::here("./data/clean/coord10000.txt"), col_names = FALSE)
#coord25000 <- readr::read_table(here::here("./data/clean/coord25000.txt"), col_names = FALSE)

#prep de data
coordinates(coord50_1) <- ~ X1 + X2

#variogram
lzn.vgm <- variogram(X3~1, data=coord50_1) 
plot(lzn.vgm)

#no line is showing up!
lzn.model <- gstat::vgm( 
  psill = 0.06, # semivariance at the range
  range = 100, # distance of the plateau
  nugget = 1, # intercept (sorta)
  model = "Sph") # spherical model

png(filename = here::here("./figs/varg-vgm-006-100-1-Sph.png")) 
plot(lzn.vgm, lzn.model) 
dev.off() 

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
  ggplot(aes(X1=X1, Y=Y)) + geom_tile(aes(fill=var1.pred)) + coord_equal() +
  scale_fill_gradient(low = "yellow", high="red") +
  scale_x_continuous(labels=comma) + scale_y_continuous(labels=comma) +
  theme_bw()

png(filename = here::here("./figs/coord50_1_kriged")) 
plot(lzn.kriged) 
dev.off() 

# Krig 50 points ====
# On veut savoir si la randomness a un effet sur la qualité de l'échantillonnage
# Est-il similaire au krig original ? Plus ou moins précis ? Uniforme entre eux ?

## map 1 ====
plot(krig_50pts)
## map 2 ====
plot(krig_50pts)
## map 3 ====
plot(krig_50pts)
## map 4 ====
plot(krig_50pts)
## map 5 ====
plot(krig_50pts)
## map 6 ====
plot(krig_50pts)
## map 7 ====
plot(krig_50pts)
## map 8 ====
plot(krig_50pts)
## map 9 ====
plot(krig_50pts)
## map 10 ====
plot(krig_50pts)

# Krig 10 points ====
# On veut savoir si le nombre de points (sous-échantillon) a un effet sur la 
# qualité du krigeage. Est-il similaire au krig original ? Y a-t-il un plateau
# ou un nombre de ptns ou il n'y a pas de différéence significative ?

## map 11 ====
plot(krig_10pts)

# Krig 100 points ====

## map 12 ====
plot(krig_100pts)

# Krig 200 points ====

## map 13 ====
plot(krig_100pts)

# Krig 300 points ====

## map 14 ====
plot(krig_500pts)

# Krig 500 points ====

## map 15 ====
plot(krig_500pts)

# Krig 1000 points ====

## map 16 ====

# Krig 2000 points ====

## map 16 ====

# Krig 5000 points ====

## map 17 ====

# Krig 10000 points ====

## map 18 ====

# Krig 25000 points ====

## map 19 ====




