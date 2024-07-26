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
class(coord50_1)
coordinates(coord50_1) <- ~ X1 + X2
class(coord50_1)

#variogram
lzn.vgm <- variogram(log(X3)~1, coord50_1) # calculates sample variogram values 
lzn.fit <- fit.variogram(lzn.vgm, model=vgm(1, "Sph", 900, 1)) # fit model

# Krig 50 points ====
# On veut savoir si la randomness a un effet sur la qualité de l'échantillonnage
# Est-il similaire au krig original ? Plus ou moins précis ? Uniforme entre eux ?
krig50 <- gstat::krige(
  detection_outcome ~ 1,
  locations = pharos_50,
  newdata = grid_sample,
  model = fit_varg50,
  nmax = 5
)
plot(krig50["var1.pred"])

krig_50pts <- ggplot2::ggplot() +
  geom_sf(data = berlin_poly, alpha = 0.3) +
  geom_sf(data = krig50, aes(fill = var1.pred), shape = 21, size = 3) +
  geom_sf(data = pharos_50, aes(colour = detection_outcome), size = 2) + # foxes
  scale_fill_viridis_c("probability", na.value = "white") +
  scale_colour_manual("test outcome", values = c("#8a56b8", "#d5363d")) +
  theme_void() +
  coord_sf()

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




