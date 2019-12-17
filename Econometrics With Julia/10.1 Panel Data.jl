using CSV
using DataFrames
using Query
using Plots
using Econometrics

fatalities = CSV.read("C:\\Users\\jpche\\AppData\\Local\\JuliaPro-1.2.0-1\\fatalities.csv")

fatalities1982 = @from i in fatalities begin
    @where i.year == 1982
    @select {i.beertax, fatality_rate = i.fatal / i.pop * 10000}
    @collect DataFrame
end

fatalities1988 = @from i in fatalities begin
    @where i.year == 1988
    @select {i.beertax, fatality_rate = i.fatal / i.pop * 10000}
    @collect DataFrame
end

fatalities1982_model = fit(
                        EconometricModel,
                        @formula(fatality_rate ~ beertax),
                        fatalities1982
)

fatalities1988_model = fit(
                        EconometricModel,
                        @formula(fatality_rate ~ beertax),
                        fatalities1988
)

println(fatalities1982_model)
println(fatalities1988_model)

x = fatalities1982.beertax
y = fatalities1982.fatality_rate

p1 = plot( #assign a plot object to the variable p1 using the following attributes
    x, #x series
    y, #y series
    st = :scatter, #series type
    title = "Traffic Fatality Rates and Beer Taxes in 1982", #plot title
    label = "US State", #legend labels
    xlabel = "Beer tax (in 1988 dollars)", #x axis label
    ylabel = "Fatality rate (fatalities per 10000)", #y axis label
    ylims = (0,4.5), #y axis limits
    yticks = 0:1:4.5, #y axis tick range
    ms = 4, #marker size
    mc = :blue #marker color
)

y_prediction_1982(xdata) = dot(coef(fatalities1982_model), [1, xdata])

x = [minimum(fatalities1982.beertax), maximum(fatalities1982.beertax)]
y = y_prediction_1982.(x)

plot!(
    p1,
    x,
    y,
    st = :line,
    label = "OLS"
)

display(p1)

x = fatalities1988.beertax
y = fatalities1988.fatality_rate

p2 = plot( #assign a plot object to the variable p1 using the following attributes
    x, #x series
    y, #y series
    st = :scatter, #series type
    title = "Traffic Fatality Rates and Beer Taxes in 1988", #plot title
    label = "US State", #legend labels
    xlabel = "Beer tax (in 1988 dollars)", #x axis label
    ylabel = "Fatality rate (fatalities per 10000)", #y axis label
    ylims = (0,4.5), #y axis limits
    yticks = 0:1:4.5, #y axis tick range
    ms = 4, #marker size
    mc = :blue #marker color
)

y_prediction_1988(xdata) = dot(coef(fatalities1988_model), [1, xdata])

x = [minimum(fatalities1988.beertax), maximum(fatalities1988.beertax)]
y = y_prediction_1988.(x)

plot!(
    p2,
    x,
    y,
    st = :line,
    label = "OLS"
)

display(p2)
