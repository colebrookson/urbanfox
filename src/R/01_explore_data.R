# Explore the data

# Krig 50 points ====
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


# Krig 10 points ====
krig10 <- gstat::krige(
  detection_outcome ~ 1,
  locations = pharos_10,
  newdata = grid_sample,
  model = fit_varg10,
  nmax = 5
)
plot(krig10["var1.pred"])

krig_10pts <- ggplot2::ggplot() +
  geom_sf(data = berlin_poly, alpha = 0.3) +
  geom_sf(data = krig10, aes(fill = var1.pred), shape = 21, size = 3) +
  geom_sf(data = pharos_10, aes(colour = detection_outcome), size = 2) + # foxes
  scale_fill_viridis_c("probability", na.value = "white") +
  scale_colour_manual("test outcome", values = c("#8a56b8", "#d5363d")) +
  theme_void() +
  coord_sf()

## map 2 ====
plot(krig_10pts)

# Krig 100 points ====
krig100 <- gstat::krige(
  detection_outcome ~ 1,
  locations = pharos_100,
  newdata = grid_sample,
  model = fit_varg100,
  nmax = 5
)
plot(krig100["var1.pred"])

krig_100pts <- ggplot2::ggplot() +
  geom_sf(data = berlin_poly, alpha = 0.3) +
  geom_sf(data = krig100, aes(fill = var1.pred), shape = 21, size = 3) +
  geom_sf(data = pharos_100, aes(colour = detection_outcome), size = 2) + # foxes
  scale_fill_viridis_c("probability", na.value = "white") +
  scale_colour_manual("test outcome", values = c("#8a56b8", "#d5363d")) +
  theme_void() +
  coord_sf()

## map 3 ====
plot(krig_100pts)

# Krig 500 points ====
krig500 <- gstat::krige(
  detection_outcome ~ 1,
  locations = pharos_500,
  newdata = grid_sample,
  model = fit_varg500,
  nmax = 5
)
plot(krig500["var1.pred"])

krig_500pts <- ggplot2::ggplot() +
  geom_sf(data = berlin_poly, alpha = 0.3) +
  geom_sf(data = krig500, aes(fill = var1.pred), shape = 21, size = 3) +
  geom_sf(data = pharos_500, aes(colour = detection_outcome), size = 2) + # foxes
  scale_fill_viridis_c("probability", na.value = "white") +
  scale_colour_manual("test outcome", values = c("#8a56b8", "#d5363d")) +
  theme_void() +
  coord_sf()

## map 3 ====
plot(krig_500pts)

# With entropy ====



