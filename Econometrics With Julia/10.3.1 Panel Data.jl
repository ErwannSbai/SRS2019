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

unique_states = []
for state in fatalities.state
    if !(state in unique_states)
        push!(unique_states, state)
    end
end

data = @from i in fatalities begin
    @where i.state == unique_states[1]
    @select i
    @collect DataFrame
end

x = data.beertax
y = data.fatality_rate

p1 = plot( #assign a plot object to the variable p1 using the following attributes
    x, #x series
    y, #y series
    st = :scatter, #series type
    title = "Traffic Fatality Rates and Beer Taxes from 1982-1988", #plot title
    label = "", #legend labels
    xlabel = "Beer tax (in 1988 dollars)", #x axis label
    ylabel = "Fatality rate (fatalities per 10000)", #y axis label
    ms = 4, #marker size
    mc = :blue #marker color
)

data_model = fit(
                        EconometricModel,
                        @formula(fatality_rate ~ beertax),
                        data
)

y_prediction(x) = dot(coef(data_model), [1, x])

x = [minimum(data.beertax), maximum(data.beertax)]
y = y_prediction.(x)

plot!(
    p1,
    x,
    y,
    st = :line,
    label = "",
    lc = :blue
)

for index in 2:length(unique_states)

    data = @from i in fatalities begin
        @where i.state == unique_states[index]
        @select {i.beertax, i.fatality_rate}
        @collect DataFrame
    end

    x = data.beertax
    y = data.fatality_rate

    plot!( #assign a plot object to the variable p1 using the following attributes
        x, #x series
        y, #y series
        st = :scatter, #series type
        title = "Traffic Fatality Rates and Beer Taxes from 1982-1988", #plot title
        label = "", #legend labels
        xlabel = "Beer tax (in 1988 dollars)", #x axis label
        ylabel = "Fatality rate (fatalities per 10000)", #y axis label
        ms = 4, #marker size
        mc = index #marker color
    )

    data_model = fit(
                            EconometricModel,
                            @formula(fatality_rate ~ beertax),
                            data
    )

    y_prediction(x) = dot(coef(data_model), [1, x])

    x = [minimum(data.beertax), maximum(data.beertax)]
    y = y_prediction.(x)

    plot!(
        p1,
        x,
        y,
        st = :line,
        label = "",
        lc = index
    )

end

display(p1)
