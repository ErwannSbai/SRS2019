using CSV
using DataFrames
using Query
using Plots
using FixedEffects
using FixedEffectModels
using CategoricalArrays
using LinearAlgebra
using RegressionTables
using Distributions

fatalities = CSV.read("C:\\Users\\jpche\\AppData\\Local\\JuliaPro-1.2.0-1\\fatalities.csv") #from CSV.jl; use the CSV object's read method to import the 'fatalities.csv' file as a DataFrame object and define it as 'fatalities'

fatalities.fatality_rate = fatalities.fatal ./ fatalities.pop * 10000 #define a new column 'fatality_rate' in the DataFrame 'fatalities' which takes, from each row, the total number of fatalities from the variable 'fatal',  divides it by the total population from the variable 'pop', and multiplies the value by 10,000 to obtain the fatality rate per 10,000 people in a given state and time period
fatalities.state = categorical(fatalities.state) #redefine the column 'state' in the DataFrame 'fatalities' as a categorical variable by taking the 'state' column of given states and converting it from an ordinary Array into a CategoricalArray
fatalities.year = categorical(fatalities.year) #redefine the column 'year' in the DataFrame 'fatalities' as a categorical variable by taking the 'year' column of given years and converting it from an ordinary Array into a CategoricalArray
fatalities.year1983 = fatalities.year .== 1983
fatalities.year1984 = fatalities.year .== 1984
fatalities.year1985 = fatalities.year .== 1985
fatalities.year1986 = fatalities.year .== 1986
fatalities.year1987 = fatalities.year .== 1987
fatalities.year1988 = fatalities.year .== 1988
fatalities.drinkagec = categorical(cut(fatalities.drinkage, 18:22, extend = true)) #define a new column 'drinkagec' in the DataFrame 'fatalities' as a CategoricalArray which takes the legal drinking age of a state from the variable 'drinkage' and categorises it as the range [18, 19), [19, 20), [20, 21), or [21, 22]
fatalities.drinkagec1819 = fatalities.drinkagec .== "[18, 19)" #define a new column 'drinkeagec1819' in the DataFrame 'fatalities' as a dummy variable which takes the categorical range of the legal drinking age of a state and returns 1 if the range is [18, 19) and 0 otherwise
fatalities.drinkagec1920 = fatalities.drinkagec .== "[19, 20)" #define a new column 'drinkeagec1920' in the DataFrame 'fatalities' as a dummy variable which takes the categorical range of the legal drinking age of a state and returns 1 if the range is [19, 20) and 0 otherwise
fatalities.drinkagec2021 = fatalities.drinkagec .== "[20, 21)" #define a new column 'drinkeagec2021' in the DataFrame 'fatalities' as a dummy variable which takes the categorical range of the legal drinking age of a state and returns 1 if the range is [20, 21) and 0 otherwise
fatalities.punish =  ((fatalities.jail .== "yes") .| (fatalities.service .== "yes")) ##define a new column 'punish' in the DataFrame 'fatalities' as a dummy variable which returns 1 if the given state has laws which punish drunk driving with either prison time or community service and 0 otherwise

fatalities_1982_and_1988 = @from i in fatalities begin #from Query.jl; use a LINQ style query to access each row 'i' in the DataFrame 'fatalities'
    @where i.year == 1982 || i.year == 1988 #filter each row 'i' such that the variable 'year' is equal to either '1982' or '1988'
    @select i #select all columns from the filtered rows 'i'
    @collect DataFrame #return the result as a DataFrame
end #end query

fatalities_mod_1 = reg( #from FixedEffectModels; initialise a FixedEffectModel and define it as fatalities_mod_1
                        fatalities, #pass the DataFrame 'fatalities' as the dataset to be used in fatalities_mod_1
                        @formula(fatality_rate ~ beertax) #pass the regression formula consisting of the dependent variable 'fatality_rate' and the exogenous variable 'beertax'
)

fatalities_mod_2 = reg( #from FixedEffectModels; initialise a FixedEffectModel and define it as fatalities_mod_2
                        fatalities, #pass the DataFrame 'fatalities' as the dataset to be used in fatalities_mod_2
                        @formula(fatality_rate ~ beertax + fe(state)), #pass the regression formula consisting of the dependent variable 'fatality_rate', the exogenous variable 'beertax', and the fixed effect variable 'state'
                        Vcov.cluster(:state) #set the standard error Vcov to be clustered by the variable 'state'
)

fatalities_mod_3 = reg( #from FixedEffectModels; initialise a FixedEffectModel and define it as fatalities_mod_3
                        fatalities, #pass the DataFrame 'fatalities' as the dataset to be used in fatalities_mod_3
                        @formula(fatality_rate ~ beertax + fe(state) + fe(year)), #pass the regression formula consisting of the dependent variable 'fatality_rate', the exogenous variable 'beertax', and the fixed effect variables 'state' and 'year'
                        Vcov.cluster(:state) #set the standard error Vcov to be clustered by the variable 'state'
)

fatalities_mod_4 = reg( #from FixedEffectModels; initialise a FixedEffectModel and define it as fatalities_mod_4
                        fatalities, #pass the DataFrame 'fatalities' as the dataset to be used in fatalities_mod_4
                        @formula(fatality_rate ~ beertax + punish + miles + unemp + log(income) + drinkagec1819 + drinkagec1920 + drinkagec2021 + fe(state) + fe(year)), #pass the regression formula consisting of the dependent variable 'fatality_rate', the exogenous variables 'beertax', 'punish', 'miles', 'unemp' and 'log(income)', the exogenous dummy variables 'drinkagec1819', 'drinkagec1920' and 'drinkagec2021', and the fixed effect variables 'state' and 'year'
                        Vcov.cluster(:state) #set the standard error Vcov to be clustered by the variable 'state'
)

fatalities_mod_5 = reg( #from FixedEffectModels; initialise a FixedEffectModel and define it as fatalities_mod_5
                        fatalities, #pass the DataFrame 'fatalities' as the dataset to be used in fatalities_mod_5
                        @formula(fatality_rate ~ beertax + punish + miles + drinkagec1819 + drinkagec1920 + drinkagec2021 + fe(state) + fe(year)), #pass the regression formula consisting of the dependent variable 'fatality_rate', the exogenous variables 'beertax', 'punish', 'miles', 'unemp' and 'log(income)', the exogenous dummy variables 'drinkagec1819', 'drinkagec1920' and 'drinkagec2021', and the fixed effect variables 'state' and 'year'
                        Vcov.cluster(:state) #set the standard error Vcov to be clustered by the variable 'state'
)

fatalities_mod_6 = reg( #from FixedEffectModels; initialise a FixedEffectModel and define it as fatalities_mod_6
                        fatalities, #pass the DataFrame 'fatalities' as the dataset to be used in fatalities_mod_6
                        @formula(fatality_rate ~ beertax + punish + miles + unemp + log(income)  + drinkage + fe(state) + fe(year)), #pass the regression formula consisting of the dependent variable 'fatality_rate', the exogenous variables 'beertax', 'punish', 'miles', 'unemp', 'log(income)' and 'drinkage', and the fixed effect variables 'state' and 'year'
                        Vcov.cluster(:state) #set the standard error Vcov to be clustered by the variable 'state'
)

fatalities_mod_7 = reg( #from FixedEffectModels; initialise a FixedEffectModel and define it as fatalities_mod_7
                        fatalities_1982_and_1988, #pass the DataFrame 'fatalities_1982_and_1988' as the dataset to be used in fatalities_mod_7
                        @formula(fatality_rate ~ beertax + punish + miles + unemp + log(income) + drinkagec1819 + drinkagec1920 + drinkagec2021 + fe(state) + fe(year)), #pass the regression formula consisting of the dependent variable 'fatality_rate', the exogenous variables 'beertax', 'punish', 'miles', 'unemp' and 'log(income)', the exogenous dummy variables 'drinkagec1819', 'drinkagec1920' and 'drinkagec2021', and the fixed effect variables 'state' and 'year'
                        Vcov.cluster(:state) #set the standard error Vcov to be clustered by the variable 'state'
)

regtable( #from RegressionTables.jl; function produces a regression table
            fatalities_mod_1, fatalities_mod_2, fatalities_mod_3, fatalities_mod_4, fatalities_mod_5, fatalities_mod_6, fatalities_mod_7; #pass the FixedEffectModels 'fatalities_mod_1', 'fatalities_mod_2', 'fatalities_mod_3', 'fatalities_mod_4', 'fatalities_mod_5', 'fatalities_mod_6' and 'fatalities_mod_7' as the models to be displayed in the regression table
            renderSettings = htmlOutput("fatalities.html"), #set the output to be diverted to the file 'test.html' in the form of html in the current working directory (check using the function pwd())
            regression_statistics = [:nobs, :adjr2, :f], #set the regression statistics to be displayed as the number of observations, the adjusted r squared, and the f-statistic
            labels = Dict( #set the labels using a Dict that maps user-defined labels to pre-existing variable names
                            "fatality_rate" => "Linear Panel Regression Models of Traffic Fatalities Due to Drunk Driving <br><br> (fatality_rate)",
                            "drinkagec1819" => "drinkagec: [18, 19)",
                            "drinkagec1920" => "drinkagec: [19, 20)",
                            "drinkagec2021" => "drinkagec: [20, 21)",
                            "punish" => "punish: yes"
            )
)

function robust_f_test(reg_model, restricted_variable_array, reg_model_name)

    num_restrictions = length(restricted_variable_array)
    num_coef = length(reg_model.coef)

    restriction_matrix = zeros(num_restrictions, num_coef)

    for i in 1:num_restrictions
        restricted_variable_index = findall(x -> x == restricted_variable_array[i], reg_model.coefnames)[1]

        restriction_matrix[i, restricted_variable_index] = 1

    end

    restricted_variable_coef_matrix = restriction_matrix * reg_model.coef


    f_statistic = transpose(restricted_variable_coef_matrix) * inv(restriction_matrix * reg_model.vcov * transpose(restriction_matrix)) * restricted_variable_coef_matrix / num_restrictions

    f_dist = FDist(num_restrictions, Inf64)

    f_statistic_p_value = 1 - cdf(f_dist, f_statistic)

    println("Robust F-Test on the model " * string(reg_model_name) * " with restrictions " * string(restricted_variable_array))
    println("F-Statistic: " * string(f_statistic))
    println("F-Statistic P-Value: " * string(f_statistic_p_value))
    println()

end

fatalities_mod_3_year_dummy = reg( #from FixedEffectModels; initialise a FixedEffectModel and define it as fatalities_mod_3
                        fatalities, #pass the DataFrame 'fatalities' as the dataset to be used in fatalities_mod_3
                        @formula(fatality_rate ~ beertax + fe(state) + year1983 + year1984 + year1985 + year1986 + year1987 + year1988), #pass the regression formula consisting of the dependent variable 'fatality_rate', the exogenous variable 'beertax', and the fixed effect variables 'state' and 'year'
                        Vcov.cluster(:state) #set the standard error Vcov to be clustered by the variable 'state'
)

fatalities_mod_4_year_dummy = reg( #from FixedEffectModels; initialise a FixedEffectModel and define it as fatalities_mod_4
                        fatalities, #pass the DataFrame 'fatalities' as the dataset to be used in fatalities_mod_4
                        @formula(fatality_rate ~ beertax + punish + miles + unemp + log(income) + drinkagec1819 + drinkagec1920 + drinkagec2021 + fe(state) + year1983 + year1984 + year1985 + year1986 + year1987 + year1988), #pass the regression formula consisting of the dependent variable 'fatality_rate', the exogenous variables 'beertax', 'punish', 'miles', 'unemp' and 'log(income)', the exogenous dummy variables 'drinkagec1819', 'drinkagec1920' and 'drinkagec2021', and the fixed effect variables 'state' and 'year'
                        Vcov.cluster(:state) #set the standard error Vcov to be clustered by the variable 'state'
)

fatalities_mod_5_year_dummy = reg( #from FixedEffectModels; initialise a FixedEffectModel and define it as fatalities_mod_5
                        fatalities, #pass the DataFrame 'fatalities' as the dataset to be used in fatalities_mod_5
                        @formula(fatality_rate ~ beertax + punish + miles + drinkagec1819 + drinkagec1920 + drinkagec2021 + fe(state) + year1983 + year1984 + year1985 + year1986 + year1987 + year1988), #pass the regression formula consisting of the dependent variable 'fatality_rate', the exogenous variables 'beertax', 'punish', 'miles', 'unemp' and 'log(income)', the exogenous dummy variables 'drinkagec1819', 'drinkagec1920' and 'drinkagec2021', and the fixed effect variables 'state' and 'year'
                        Vcov.cluster(:state) #set the standard error Vcov to be clustered by the variable 'state'
)

fatalities_mod_6_year_dummy = reg( #from FixedEffectModels; initialise a FixedEffectModel and define it as fatalities_mod_6
                        fatalities, #pass the DataFrame 'fatalities' as the dataset to be used in fatalities_mod_6
                        @formula(fatality_rate ~ beertax + punish + miles + unemp + log(income)  + drinkage + fe(state) + year1983 + year1984 + year1985 + year1986 + year1987 + year1988), #pass the regression formula consisting of the dependent variable 'fatality_rate', the exogenous variables 'beertax', 'punish', 'miles', 'unemp', 'log(income)' and 'drinkage', and the fixed effect variables 'state' and 'year'
                        Vcov.cluster(:state) #set the standard error Vcov to be clustered by the variable 'state'
)

fatalities_mod_7_year_dummy = reg( #from FixedEffectModels; initialise a FixedEffectModel and define it as fatalities_mod_7
                        fatalities_1982_and_1988, #pass the DataFrame 'fatalities_1982_and_1988' as the dataset to be used in fatalities_mod_7
                        @formula(fatality_rate ~ beertax + punish + miles + unemp + log(income) + drinkagec1819 + drinkagec1920 + drinkagec2021 + fe(state) + year1988), #pass the regression formula consisting of the dependent variable 'fatality_rate', the exogenous variables 'beertax', 'punish', 'miles', 'unemp' and 'log(income)', the exogenous dummy variables 'drinkagec1819', 'drinkagec1920' and 'drinkagec2021', and the fixed effect variables 'state' and 'year'
                        Vcov.cluster(:state) #set the standard error Vcov to be clustered by the variable 'state'
)

robust_f_test(fatalities_mod_3_year_dummy, ["year1983", "year1984", "year1985", "year1986", "year1987", "year1988"], "fatalities_mod_3_year_dummy")
robust_f_test(fatalities_mod_4_year_dummy, ["year1983", "year1984", "year1985", "year1986", "year1987", "year1988"], "fatalities_mod_4_year_dummy")
robust_f_test(fatalities_mod_4, ["drinkagec1819", "drinkagec1920", "drinkagec2021"], "fatalities_mod_4")
robust_f_test(fatalities_mod_4, ["log(income)", "unemp"], "fatalities_mod_4")
robust_f_test(fatalities_mod_5_year_dummy, ["year1983", "year1984", "year1985", "year1986", "year1987", "year1988"], "fatalities_mod_5_year_dummy")
robust_f_test(fatalities_mod_5, ["drinkagec1819", "drinkagec1920", "drinkagec2021"], "fatalities_mod_5")
robust_f_test(fatalities_mod_6_year_dummy, ["year1983", "year1984", "year1985", "year1986", "year1987", "year1988"], "fatalities_mod_6_year_dummy")
robust_f_test(fatalities_mod_6, ["log(income)", "unemp"], "fatalities_mod_6")
robust_f_test(fatalities_mod_7_year_dummy, ["year1988"], "fatalities_mod_7_year_dummy")
robust_f_test(fatalities_mod_7, ["drinkagec1819", "drinkagec1920", "drinkagec2021"], "fatalities_mod_7")
robust_f_test(fatalities_mod_7, ["log(income)", "unemp"], "fatalities_mod_7")
