using BiodiversityObservationNetworks
using NeutralLandscapes
using CairoMakie
using PyPlot

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
using GMT
file = gmtread("C:\\Users\\abuss\\github\\urbanfox\\data\\clean\\krig_raster.tif")

# trying to figure out why I can't entropize it
map_entropy = convert.(Float64, file)

#entropize berlin map
heatmap(map_entropy) #working

map_e = entropize(map_entropy) 
heatmap(map_e) #not working

locations =
    map_entropy |> 
    entropize |> 
    seed(BalancedAcceptance(; numpoints = 100)) |> 
    first