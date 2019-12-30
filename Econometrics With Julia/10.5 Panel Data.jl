using CSV
using DataFrames
using Query
using Plots
using FixedEffects
using FixedEffectModels
using CategoricalArrays
using LinearAlgebra
using RegressionTables

fatalities = CSV.read("C:\\Users\\jpche\\AppData\\Local\\JuliaPro-1.2.0-1\\fatalities.csv") #from CSV.jl; use the CSV object's read method to import the 'fatalities.csv' file as a DataFrame object and define it as 'fatalities'

fatalities.fatality_rate = fatalities.fatal ./ fatalities.pop * 10000 #define a new column 'fatality_rate' in the DataFrame 'fatalities' which takes, from each row, the total number of fatalities from the variable 'fatal',  divides it by the total population from the variable 'pop', and multiplies the value by 10,000 to obtain the fatality rate per 10,000 people in a given state and time period
fatalities.state = categorical(fatalities.state) #redefine the column 'state' in the DataFrame 'fatalities' as a categorical variable by taking the 'state' column of given states and converting it from an ordinary Array into a CategoricalArray
fatalities.year = categorical(fatalities.year) #redefine the column 'year' in the DataFrame 'fatalities' as a categorical variable by taking the 'year' column of given years and converting it from an ordinary Array into a CategoricalArray
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
            renderSettings = asciiOutput(), #set the output to be diverted to the file 'test.html' in the form of html in the current working directory (check using the function pwd())
            regression_statistics = [:nobs, :adjr2, :f], #set the regression statistics to be displayed as the number of observations, the adjusted r squared, and the f-statistic
            labels = Dict( #set the labels using a Dict that maps user-defined labels to pre-existing variable names
                            "fatality_rate" => "Linear Panel Regression Models of Traffic Fatalities Due to Drunk Driving <br><br> (fatality_rate)",
                            "drinkagec1819" => "drinkagec: [18, 19)",
                            "drinkagec1920" => "drinkagec: [19, 20)",
                            "drinkagec2021" => "drinkagec: [20, 21)",
                            "punish" => "punish: yes"
                        )
        )
