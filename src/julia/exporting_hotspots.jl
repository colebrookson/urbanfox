using BiodiversityObservationNetworks
using NeutralLandscapes
using CairoMakie
using Pkg
using ArchGDAL
using DelimitedFiles

file = ArchGDAL.read("C:\\Users\\abuss\\github\\urbanfox\\data\\clean\\krig_raster.tif")

#raster band 
band = ArchGDAL.getband(file, 1) 
data = ArchGDAL.read(band) # Read as UInt32
data_matrix = Float64.(data) # Convert to Float64

import Random
Random.seed!(12345)

locations =
    data_matrix |> 
    seed(BalancedAcceptance(; numpoints = 1500)) |> 
    refine(AdaptiveSpatial(; numpoints=1000)) |>
    first 

# saving coordinates for 1000 points
coord1000 = [(location[1], location[2], data_matrix[location]) for location in locations]
writedlm("coord1000.txt", coord1000)

locations =
    data_matrix |> 
    seed(BalancedAcceptance(; numpoints = 2500)) |> 
    refine(AdaptiveSpatial(; numpoints=2000)) |>
    first 

# saving coordinates for 2000 points
coord2000 = [(location[1], location[2], data_matrix[location]) for location in locations]
writedlm("coord2000.txt", coord2000)

locations =
    data_matrix |> 
    seed(BalancedAcceptance(; numpoints = 5500)) |> 
    refine(AdaptiveSpatial(; numpoints=5000)) |>
    first 

# saving coordinates for 5000 points
coord5000 = [(location[1], location[2], data_matrix[location]) for location in locations]
writedlm("coord5000.txt", coord5000)

locations =
    data_matrix |> 
    seed(BalancedAcceptance(; numpoints = 10500)) |> 
    refine(AdaptiveSpatial(; numpoints=10000)) |>
    first 

# saving coordinates for 10 000 points
coord10000 = [(location[1], location[2], data_matrix[location]) for location in locations]
writedlm("coord10000.txt", coord10000)

locations =
    data_matrix |> 
    seed(BalancedAcceptance(; numpoints = 25500)) |> 
    refine(AdaptiveSpatial(; numpoints=25000)) |>
    first 

# saving coordinates for 25000
coord25000 = [(location[1], location[2], data_matrix[location]) for location in locations]
writedlm("coord25000.txt", coord25000)

#please send me these .txt data of 1000, 2000, 5000, 10000, 25000 points :) Thanks!!!