using BiodiversityObservationNetworks
using DelimitedFiles

# Données aléatoires - tu peux enlever cet example en utilisant les vraies données
using NeutralLandscapes
U = rand(DiamondSquare(0.5), (200, 200))
U[findall(.!( 0.3 .<= U .<=0.9 ))] .= NaN
writedlm("data.txt", U)

# Lecture des données depuis le fichier en utilisant DelimitedFiles.readdlm
U = readdlm("data.txt")

# Choix du nombre de sites
number_of_candidate_sites = min(200, count(!isnan, U))
number_of_sites = min(50, number_of_candidate_sites)

locations = U |>
    seed(BalancedAcceptance(; numpoints = number_of_candidate_sites)) |>
    refine(AdaptiveSpatial(; numpoints = number_of_sites)) |>
    first

# Sauvegarde des coordonées au format ligne/colonne (il y à une façon plus élégante mais 🤷)
grid_coordinates = rotr90(hcat([[location[2], location[1]] for location in locations]...))
writedlm("coord.txt", grid_coordinates)

# Figure en utilisant CairoMakie (pas important pour toi)
using CairoMakie
CairoMakie.activate!(px_per_unit = 2)
fig = Figure()
ax = Axis(fig[1,1])
heatmap!(ax, U, colormap=:navia)
scatter!(ax, [location[1] for location in locations], [location[2] for location in locations], color=:white, strokecolor=:black, strokewidth=2)
hidedecorations!(ax)
save("map.png", current_figure())
current_figure()

#julia siteselection.jl