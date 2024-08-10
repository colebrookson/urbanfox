# Indicator krig ==== 
# variograms 
varg <- gstat::variogram(detection_outcome ~ 1, data = rand) 
plot(varg)
vgm <- gstat::vgm(
  psill = 0.21, # semivariance at the range
  range = 0.5, # distance of the plateau
  nugget = 0.005, # intercept (sorta)
  model = "Sph" # spherical model
)
plot(varg,vgm)
fit_varg <- gstat::fit.variogram(varg, vgm)

# krigging 
krig <- gstat::krige(
  detection_outcome ~ 1,
  locations = rand,
  newdata = grid_sample,
  model = fit_varg,
  nmax = 5
)

plot(krig["var1.pred"])

krig_and_foxes <- ggplot2::ggplot() +
  geom_sf(data = berlin_poly, alpha = 0.3) +
  geom_sf(data = krig, aes(fill = var1.pred), shape = 21, size = 3) +
  geom_sf(data = rand, aes(colour = detection_outcome), size = 2) + # foxes
  scale_fill_viridis_c("probability", na.value = "white") +
  scale_colour_manual("test outcome", values = c("#8a56b8", "#d5363d")) +
  theme_void() +
  coord_sf()
plot(krig_and_foxes)

ggplot2::ggsave(
  filename = here::here("./figs/indicator_krig_100_random_sample.png"),
  plot = krig_and_foxes,
  height = 6,
  width = 8,
  bg = "white" 
)