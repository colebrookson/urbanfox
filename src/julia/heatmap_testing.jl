using BiodiversityObservationNetworks
using NeutralLandscapes
using CairoMakie
using PyPlot

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