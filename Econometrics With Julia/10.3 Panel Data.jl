using CSV
using DataFrames
using Query
using Plots
using Econometrics
using CategoricalArrays
using LinearAlgebra

fatalities = CSV.read("C:\\Users\\jpche\\AppData\\Local\\JuliaPro-1.2.0-1\\fatalities.csv")

fatalities.fatality_rate = fatalities.fatal ./ fatalities.pop * 10000
fatalities.state = categorical(fatalities.state)

fatalities_model = fit(
                        EconometricModel,
                        @formula(fatality_rate ~ beertax + absorb(state)),
                        fatalities
)

println(fatalities_model)

x = fatalities.beertax
y = fatalities.fatality_rate

p1 = plot( #assign a plot object to the variable p1 using the following attributes
    x, #x series
    y, #y series
    st = :scatter, #series type
    title = "Traffic Fatality Rates and Beer Taxes from 1982-1988", #plot title
    label = "Observation", #legend labels
    xlabel = "Beer tax (in 1988 dollars)", #x axis label
    ylabel = "Fatality rate (fatalities per 10000)", #y axis label
    ylims = (0, 5), #y axis limits
    yticks = 0:0.5:5, #y axis tick range
    ms = 4, #marker size
    mc = :blue #marker color
)

y_prediction_diff(x) = dot(coef(fatalities_model), [1, x])

x = [minimum(fatalities.beertax), maximum(fatalities.beertax)]
y = y_prediction_diff.(x)

plot!(
    p1,
    x,
    y,
    st = :line,
    label = "OLS Difference"
)

display(p1)
