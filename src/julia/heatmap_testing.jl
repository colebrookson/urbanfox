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

map_e = entropize(data_matrix) 
heatmap(map_e) #maybe working (still loading)

locations =
    data_matrix |> 
    entropize |> 
    seed(BalancedAcceptance(; numpoints = 100)) |> 
    first #maybe working (still loading)