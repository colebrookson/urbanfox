# BiodiversityObservationNetworks.jl

#Dans R
#write.csv(as.data.frame(pharos_sf), file="pharossf.csv", row.names=FALSE)

# Dans Julia
using BiodiversityObservationNetworks
using NeutralLandscapes
using CairoMakie
using DelimitedFiles
using CSV
using DataFrames

# pharos = CSV.read("C:\\Users\\abuss\\github\\urbanfox\\julia\\pharossf.csv", DataFrame)

# Lecture des données depuis le fichier en utilisant DelimitedFiles.readdlm
U_local = readdlm("C:\\Users\\abuss\\github\\urbanfox\\julia\\pharossf.csv")

# Choix du nombre de sites
number_of_candidate_sites = min(200, count(!isnan, U_local))
number_of_sites = min(50, number_of_candidate_sites)

locations = U_local |>
            seed(BalancedAcceptance(; numpoints=number_of_candidate_sites)) |>
            refine(AdaptiveSpatial(; numpoints=number_of_sites)) |>
            first

# Sauvegarde des coordonées au format ligne/colonne (il y à une façon plus élégante mais 🤷)
grid_coordinates_local = rotr90(hcat([[location[2], location[1]] for location in locations]...))
grid_coordinates_local

writedlm("coord_pharos.txt", grid_coordinates_local)

# #voir les données
# siteselection()

#With Entropy (in Julia)
using BiodiversityObservationNetworks
using NeutralLandscapes
using CairoMakie
using DelimitedFiles
using CSV
using DataFrames
U_local = readdlm("C:\\Users\\abuss\\github\\urbanfox\\julia\\pharossf.csv")

entropize(U_local)

locations =
  U_local |> 
  entropize |> 
  seed(BalancedAcceptance(; numpoints = 100)) |> 
  first
  
grid_entropize = rotr90(hcat([[location[2], location[1]] for location in locations]...))
writedlm("coord_entropize.txt", grid_entropize)