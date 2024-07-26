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
    seed(BalancedAcceptance(; numpoints = 500)) |> 
    refine(AdaptiveSpatial(; numpoints=400)) |>
    first 

# saving coordinates
coord400 = [(location[1], location[2], data_matrix[location]) for location in locations]
writedlm("coord400.txt", coord400)

    
