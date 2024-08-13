#data
coords50_1 <- readr::read_table(here::here(
  "./data/clean/coords50_1.txt"), col_names = FALSE)
colnames(coords50_1) <- c("x", "y", "prevalence")
coords50_2 <- readr::read_table(here::here(
  "./data/clean/coords50_2.txt"), col_names = FALSE)
colnames(coords50_2) <- c("x", "y", "prevalence")
coords50_3 <- readr::read_table(here::here(
  "./data/clean/coords50_3.txt"), col_names = FALSE)
colnames(coords50_3) <- c("x", "y", "prevalence")
coords50_4 <- readr::read_table(here::here(
  "./data/clean/coords50_4.txt"), col_names = FALSE)
colnames(coords50_4) <- c("x", "y", "prevalence")
coords50_5 <- readr::read_table(here::here(
  "./data/clean/coords50_5.txt"), col_names = FALSE)
colnames(coords50_5) <- c("x", "y", "prevalence")
#coord50_6 <- readr::read_table(here::here(
#  "./data/clean/BONs/coord50_6.txt"), col_names = FALSE)
#colnames(coord50_6) <- c("x", "y", "prevalence")
#coord50_7 <- readr::read_table(here::here(
#  "./data/clean/BONs/coord50_7.txt"), col_names = FALSE)
#colnames(coord50_7) <- c("x", "y", "prevalence")
#coord50_8 <- readr::read_table(here::here(
#  "./data/clean/BONs/coord50_8.txt"), col_names = FALSE)
#colnames(coord50_8) <- c("x", "y", "prevalence")
#coord50_9 <- readr::read_table(here::here(
#  "./data/clean/BONs/coord50_9.txt"), col_names = FALSE)
#colnames(coord50_9) <- c("x", "y", "prevalence")
#coord50_10 <- readr::read_table(here::here(
#  "./data/clean/BONs/coord50_10.txt"), col_names = FALSE)
#colnames(coord50_10) <- c("x", "y", "prevalence")

# Variance et moyenne
varmean <- data.frame(
  moyenne =  c(mean(coords50_1$prevalence), 
               mean(coords50_2$prevalence), 
               mean(coords50_3$prevalence), 
               mean(coords50_4$prevalence), 
               mean(coords50_5$prevalence)), 
  variance = c(var(coords50_1$prevalence),
               var(coords50_2$prevalence),
               var(coords50_3$prevalence),
               var(coords50_4$prevalence),
               var(coords50_5$prevalence)) 
)
varmean
