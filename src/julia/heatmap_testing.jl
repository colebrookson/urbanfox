using BiodiversityObservationNetworks
using NeutralLandscapes
using CairoMakie
#using PyPlot

#example
measurements = rand(MidpointDisplacement(), (200, 200)) .* 100
heatmap(measurements)

U = entropize(measurements)
heatmap(U)

locations =
    measurements |> entropize |> seed(BalancedAcceptance(; numpoints = 100)) |> first

fig = Makie.Figure()
CairoMakie.heatmap(U)
CairoMakie.scatter(getindex.(locations, 1), getindex.(locations, 2))

# trying to make the plot 
CairoMakie.activate!()
function plotPointsHeatmap() 
    fig = Figure(;
    figure_padding = (5,5,10,10))
    CairoMakie.heatmap!(U)
    CairoMakie.scatter!(getindex.(locations, 1), getindex.(locations, 2))
end 
plotPointsHeatmap()

# reading in the raster (outline of berlin)
using Pkg
using ArchGDAL
#Pkg.add("ArchGDAL")

file = ArchGDAL.read("C:\\Users\\abuss\\github\\urbanfox\\data\\clean\\krig_raster.tif")

#raster band 
band = ArchGDAL.getband(file, 1) 
data = ArchGDAL.read(band) # Read as UInt32
data_matrix = Float64.(data) # Convert to Float64

#entropize berlin map
CairoMakie.heatmap(data_matrix) #working

#map_e = entropize(data_matrix) 
#heatmap(map_e) #might work (still loading)

import Random
Random.seed!(12345)

locations =
    data_matrix |> 
    seed(BalancedAcceptance(; numpoints = 70)) |> 
    refine(AdaptiveSpatial(; numpoints=50)) |>
    first #might work (still loading)


    
fig = Makie.Figure()
CairoMakie.heatmap(data_matrix)
CairoMakie.scatter!(getindex.(locations, 1), getindex.(locations, 2), color=:orange)
current_figure()

density(filter(!isnan, vec(data_matrix)))
[data_matrix[location] for location in locations] |> density!
current_figure()

[(location[1], location[2], data_matrix[location]) for location in locations]

#exporter les données (coordonnées et prévalence pour le krigger)