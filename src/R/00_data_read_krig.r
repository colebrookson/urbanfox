#' Author: Cole Brookson
#' Date: 2024-05-27
#' Description: Initial file demonstrating the general process of grid
#' generation and krigging onto it

# load packages ===========
library(sf)
library(dplyr)
library(stringr)
library(ggplot2)
library(gstat)
library(here)

# read in data ===========

# REMEMBER TO CHANGE THE PATH FOR YOUR CASE
germany_sf <- sf::st_read(here::here("./data/raw/geo-data/")) %>%
    st_as_sf()
germany_code_matches <- readr::read_csv(here::here(
    "./data/raw/zuordnung_plz_ort.csv"
))
pharos_data <- readr::read_csv(here::here(
    "./data/raw/pharos_data.csv"
))

# clean up data =====

## deal with german words =====
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
ggplot2::ggplot() +
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

# variograms ====

## best option =====
varg <- gstat::variogram(detection_outcome ~ 1, data = pharos_sf)
plot(varg)
vgm <- gstat::vgm(
    psill = 0.20, # semivariance at the range
    range = 1, # distance of the plateau
    nugget = 0.01, # intercept (sorta)
    model = "Exp" # exponential model
)
# save the plot of a particular parameter combination
png(filename = here::here("./figs/varg-vgm-020-1-001-Exp.png")) # opens the png
plot(varg, vgm) # the thing you're actually saving
dev.off() # turns off the "opener" so you can do other things - you need one of 
# these every time you "open" with png() 

## other combinations =====
vgm1 <- gstat::vgm(
  psill = 0.20, # semivariance at the range
  range = 1, # distance of the plateau
  nugget = 0.005, # intercept (sorta)
  model = "Exp" # spherical model
)
# save the plot of a particular parameter combination
png(filename = here::here("./figs/varg-vgm-020-1-0005-Exp.png")) # opens the png
plot(varg, vgm1) # the thing you're actually saving
dev.off() #

vgm2 <- gstat::vgm(
  psill = 0.2, 
  range = 1, 
  nugget = 0.01, 
  model = "Gau" 
)
# save the plot of a particular parameter combination
png(filename = here::here("./figs/varg-vgm-020-1-001-Gau.png")) # opens the png
plot(varg, vgm2) # the thing you're actually saving
dev.off() #


fit_varg <- gstat::fit.variogram(varg, vgm)

# krigging ====
krig <- gstat::krige(
    detection_outcome ~ 1,
    locations = pharos_sf,
    newdata = grid_sample,
    model = fit_varg,
    nmax = 5
)
plot(krig["var1.pred"])

krig_and_foxes <- ggplot2::ggplot() +
    geom_sf(data = berlin_poly, alpha = 0.3) +
    # geom_sf(data = grid_sample, colour = "red", size = 2) + # sampled points
    geom_sf(data = krig, aes(fill = var1.pred), shape = 21, size = 3) +
    geom_sf(data = pharos_sf, aes(colour = detection_outcome), size = 2) + # foxes
    scale_fill_viridis_c("probability", na.value = "white") +
    scale_colour_manual("test outcome", values = c("#8a56b8", "#d5363d")) +
    theme_void() +
    coord_sf()
ggplot2::ggsave(
  filename = here::here("./figs/krigging-with-foxes-outcomes.png"),
  plot = krig_and_foxes,
  height = 6, 
  width = 8,
  bg = "white" # change if you want transparent background  
)

plot(krig_and_foxes)

## alternative krig ====
### vgm1 ====
fit_varg1 <- gstat::fit.variogram(varg, vgm1)

krig1 <- gstat::krige(
  detection_outcome ~ 1,
  locations = pharos_sf,
  newdata = grid_sample,
  model = fit_varg1,
  nmax = 5
)
plot(krig1["var1.pred"])

krig_and_foxes <- ggplot2::ggplot() +
  geom_sf(data = berlin_poly, alpha = 0.3) +
  # geom_sf(data = grid_sample, colour = "red", size = 2) + # sampled points
  geom_sf(data = krig1, aes(fill = var1.pred), shape = 21, size = 3) +
  geom_sf(data = pharos_sf, aes(colour = detection_outcome), size = 2) + # foxes
  scale_fill_viridis_c("probability", na.value = "white") +
  scale_colour_manual("test outcome", values = c("#8a56b8", "#d5363d")) +
  theme_void() +
  coord_sf()
ggplot2::ggsave(
  filename = here::here("./figs/krigging-with-foxes-outcomes-1.png"),
  plot = krig_and_foxes,
  height = 6, 
  width = 8,
  bg = "white" # change if you want transparent background  
)

### vgm2 ====
fit_varg2 <- gstat::fit.variogram(varg, vgm2)

krig2 <- gstat::krige(
  detection_outcome ~ 1,
  locations = pharos_sf,
  newdata = grid_sample,
  model = fit_varg2,
  nmax = 5
)
plot(krig2["var1.pred"])

krig_and_foxes <- ggplot2::ggplot() +
  geom_sf(data = berlin_poly, alpha = 0.3) +
  # geom_sf(data = grid_sample, colour = "red", size = 2) + # sampled points
  geom_sf(data = krig2, aes(fill = var1.pred), shape = 21, size = 3) +
  geom_sf(data = pharos_sf, aes(colour = detection_outcome), size = 2) + # foxes
  scale_fill_viridis_c("probability", na.value = "white") +
  scale_colour_manual("test outcome", values = c("#8a56b8", "#d5363d")) +
  theme_void() +
  coord_sf()
ggplot2::ggsave(
  filename = here::here("./figs/krigging-with-foxes-outcomes-2.png"),
  plot = krig_and_foxes,
  height = 6, 
  width = 8,
  bg = "white" # change if you want transparent background  
)

# Covariance matrix warnings ====
# covariance matrix = une matrice qui met en relation les points. 
# warning = la matrice est singulière (peut pas être inversée)

## Explanations ====
# 1-points are duplicated/too close
pharos_data <- pharos_data[-zerodist(pharos_data)[,1],] #zerodist doesn't exist
# 2-no data available (insufficient sampling) 
# 3-no single-point variability (we tried bootstrap, didn't work)
# 4-wrong model used (try with Gau)
vgm <- gstat::vgm(
  psill = 0.2, 
  range = 1, 
  nugget = 0.01, 
  model = "Gau" # Tim said it wasn't better
)

## Solutions ====
### bootstrap ====
# Tim asked to run a bootstrap (sous-échantillonnage avec remise)
# x10. Then, run the krig and note if blank spaces move.
library(boot)

####first try ====
med_boot <- function(x, i) median(x[i])
boot_res <- boot(pharos_data$detection_outcome, med_boot, R = 10000)
boot_res <- as.data.frame(boot_res)
class(boot_res) # class=boot (can't find a way to switch it to dataframe)

####second try ==== 
nBoots<-10 #number of bootstraps 
bootResult<-list()
for (i in seq_len(nBoots)){
  bootResult[[i]]<-pharos_data[sample(seq_len(nrow(pharos_data)), nrow(pharos_data), replace=TRUE), ]
}
bootResult
bootResult <- as.data.frame(bootResult)

bootResults_sf <- sf::st_as_sf(bootResult, coords = c("longitude", "latitude"))
sf::st_crs(bootResults_sf) <- 4326
bootResults_sf <- bootResults_sf[which(
  bootResults_sf$detection_outcome != "inconclusive"
), ]
bootResults_sf$detection_outcome[which(
  bootResults_sf$detection_outcome == "positive"
)] <- TRUE
bootResults_sf$detection_outcome[which(
  bootResults_sf$detection_outcome == "negative"
)] <- FALSE
bootResults_sf$detection_outcome <- as.logical(bootResults_sf$detection_outcome)
sf::st_crs(bootResults_sf) <- 4326
sf::st_crs(bootResults_sf)

krigb <- gstat::krige(
  detection_outcome ~ 1,
  locations = bootResults_sf,
  newdata = grid_sample,
  model = fit_varg,
  nmax = 5
)
krigb["var1.pred"]

krig_boot <- ggplot2::ggplot() +
  geom_sf(data = berlin_poly, alpha = 0.3) +
  geom_sf(data = krigb, aes(fill = var1.pred), shape = 21, size = 3) +
  scale_fill_viridis_c("probability", na.value = "white") +
  theme_void() +
  coord_sf()
plot(krig_boot) # krig it 10x

### Regularization ====
library(gstat)
# Exemple de régularisation
regularization_constant <- 1e-10
# Fonction pour ajuster la matrice de covariance
adjust_covariance_matrix <- function(cov_matrix, regularization_constant) {
  cov_matrix + diag(regularization_constant, nrow(cov_matrix))
}
# Fonction de prédiction ajustée pour inclure la régularisation
predict_pharos <- function(pharos_sf, newdata, block = NULL, ...) {
  # Ajuster la matrice de covariance
  pharos_sf$detection_outcome$covariance <- adjust_covariance_matrix(pharos_sf$variogram$covariance, regularization_constant)
  # Continuez avec la prédiction habituelle
  predict.gstat(pharos_sf, newdata = newdata, block = block, ...)
}
# Appliquer la prédiction avec la régularisation
prediction <- predict_pharos(pharos_sf, newdata = newdata)

### Interpolation Spline ====
interpSpline(pharos_sf, bSpline = FALSE, period = NULL,
             ord = 4L,
             na.action = na.fail, sparse = FALSE)
#interpSpline doesn't exist + spline function doesn't work

# aesthetic ====
#trying to make it prettier
krig_and_foxes <- ggplot2::ggplot() +
  geom_sf(data = berlin_poly, alpha = 0.3) +
  geom_sf(data = krig, aes(fill = var1.pred), shape = 21, size = 3, colour = NA, stroke = 0) + # same color outline and fill
  geom_sf(data = pharos_sf, aes(fill = detection_outcome), size = 2, shape = 21, colour = "black", stroke = 0.5) + # black outline
  scale_fill_viridis_c("probability", na.value = "white") +
  scale_colour_manual("test outcome", values = c("#40e0d0", "#d5363d")) +
  theme_void() +
  coord_sf()
plot(krig_and_foxes)



