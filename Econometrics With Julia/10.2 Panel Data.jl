using CSV
using DataFrames
using Query
using Plots
using Econometrics
using Statistics
using LinearAlgebra

fatalities = CSV.read("C:\\Users\\jpche\\AppData\\Local\\JuliaPro-1.2.0-1\\fatalities.csv")

fatalities.fatality_rate = fatalities.fatal ./ fatalities.pop * 10000

fatalities1982 = @from i in fatalities begin
    @where i.year == 1982
    @select i
    @collect DataFrame
end

fatalities1988 = @from i in fatalities begin
    @where i.year == 1988
    @select i
    @collect DataFrame
end

diff_fatalities = DataFrame(
                    fatality_rate = fatalities1988.fatality_rate - fatalities1982.fatality_rate,
                    beertax = fatalities1988.beertax - fatalities1982.beertax
)

diff_fatalities_model = fit(
                        EconometricModel,
                        @formula(fatality_rate ~ beertax),
                        diff_fatalities
)

println(diff_fatalities_model)

x = diff_fatalities.beertax
y = diff_fatalities.fatality_rate

p1 = plot( #assign a plot object to the variable p1 using the following attributes
    x, #x series
    y, #y series
    st = :scatter, #series type
    title = "Changes in Traffic Fatality Rates and Beer Taxes in 1982-1988", #plot title
    label = "Observation", #legend labels
    xlabel = "Change in beer tax (in 1988 dollars)", #x axis label
    ylabel = "Change in fatality rate (fatalities per 10000)", #y axis label
    ylims = (-1.5, 1), #y axis limits
    yticks = -1.5:0.5:1, #y axis tick range
    ms = 4, #marker size
    mc = :blue #marker color
)

y_prediction_diff(x) = dot(coef(diff_fatalities_model), [1, x])

x = [minimum(diff_fatalities.beertax), maximum(diff_fatalities.beertax)]
y = y_prediction_diff.(x)

plot!(
    p1,
    x,
    y,
    st = :line,
    label = "OLS Difference"
)

display(p1)

println("Mean fatality rate over all states for all time : " * string(mean(fatalities.fatality_rate)))
