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

data = CSV.read("C:\\Users\\jpche\\AppData\\Local\\JuliaPro-1.2.0-2\\datapaper.csv")

reg_mod_1 = reg(
                        data,
                        @formula(lnkl ~ ln_kl_cty + fra_lab + fra_credit),
                        Vcov.cluster(:cno_year)
)

reg_mod_2 = reg(
                        data,
                        @formula(lnkl ~ ln_kl_cty + fra_lab + fra_credit + fe(year) + fe(isic3d_3dig) + fe(cno)),
                        Vcov.cluster(:cno_year)
)

reg_mod_3 = reg(
                        data,
                        @formula(lnkl ~ ln_kl_cty  + fra_credit + fra_min_wage + fra_hire_fire + fra_unemp_ins + fra_coll_barg + fra_conscp + fe(year) + fe(isic3d_3dig) + fe(cno)),
                        Vcov.cluster(:cno_year)
)

reg_mod_4 = reg(
                        data,
                        @formula(lnkl ~ ln_kl_cty  + fra_credit + fra_min_wage + fra_hire_fire + fra_coll_barg + fra_conscp + fe(year) + fe(isic3d_3dig) + fe(cno)),
                        Vcov.cluster(:cno_year)
)

reg_mod_5 = reg(
                        data,
                        @formula(lnkl ~ ln_kl_cty  + fra_credit + fra_min_wage + fra_hire_fire + fra_unemp_ins + fra_conscp + fe(year) + fe(isic3d_3dig) + fe(cno)),
                        Vcov.cluster(:cno_year)
)

regtable( #from RegressionTables.jl; function produces a regression table
            reg_mod_1, reg_mod_2, reg_mod_3, reg_mod_4, reg_mod_5; #pass the FixedEffectModels 'fatalities_mod_1', 'fatalities_mod_2', 'fatalities_mod_3', 'fatalities_mod_4', 'fatalities_mod_5', 'fatalities_mod_6' and 'fatalities_mod_7' as the models to be displayed in the regression table
            renderSettings = htmlOutput("sundaram_regtable1.html"), #set the output to be diverted to the file 'test.html' in the form of html in the current working directory (check using the function pwd())
            labels = Dict( #set the labels using a Dict that maps user-defined labels to pre-existing variable names
                "lnkl" => "Ln(Capital per worker)",
                "ln_kl_cty" => "Ln(Capital per worker) country level",
                "fra_lab" => "Composite labor freedom index",
                "fra_credit" => "Credit market freedom index",
                "fra_min_wage" => "Labor freedom—minimum wage",
                "fra_hire_fire" => "Labor freedom—hiring and firing",
                "fra_unemp_ins" => "Labor freedom—unemployment benefits",
                "fra_coll_barg" => "Labor freedom—collective bargaining",
                "fra_conscp" => "Labor freedom—conscription",
                "year" => "Year fixed effects",
                "isic3d_3dig" => "Industry fixed effects",
                "cno" => "Country fixed effects",
            )
)

reg_mod_1 = reg(
                        data,
                        @formula(lnkl ~ ln_gdp_pc + fra_lab + fra_credit),
                        Vcov.cluster(:cno_year)
)

reg_mod_2 = reg(
                        data,
                        @formula(lnkl ~ ln_gdp_pc + fra_lab + fra_credit + fe(year) + fe(isic3d_3dig) + fe(cno)),
                        Vcov.cluster(:cno_year)
)

reg_mod_3 = reg(
                        data,
                        @formula(lnkl ~ ln_gdp_pc +  fra_credit + fra_min_wage + fra_hire_fire + fra_unemp_ins + fra_coll_barg + fra_conscp + fe(year) + fe(isic3d_3dig) + fe(cno)),
                        Vcov.cluster(:cno_year)
)

reg_mod_4 = reg(
                        data,
                        @formula(lnkl ~ ln_gdp_pc  + fra_credit + fra_min_wage + fra_hire_fire + fra_unemp_ins + fra_conscp + fe(year) + fe(isic3d_3dig) + fe(cno)),
                        Vcov.cluster(:cno_year)
)

reg_mod_5 = reg(
                        data,
                        @formula(lnkl ~ ln_gdp_pc  + fra_credit + fra_min_wage + fra_hire_fire + fra_coll_barg + fra_conscp + fe(year) + fe(isic3d_3dig) + fe(cno)),
                        Vcov.cluster(:cno_year)
)

regtable( #from RegressionTables.jl; function produces a regression table
            reg_mod_1, reg_mod_2, reg_mod_3, reg_mod_4, reg_mod_5; #pass the FixedEffectModels 'fatalities_mod_1', 'fatalities_mod_2', 'fatalities_mod_3', 'fatalities_mod_4', 'fatalities_mod_5', 'fatalities_mod_6' and 'fatalities_mod_7' as the models to be displayed in the regression table
            renderSettings = htmlOutput("sundaram_regtable2.html"), #set the output to be diverted to the file 'test.html' in the form of html in the current working directory (check using the function pwd())
            labels = Dict( #set the labels using a Dict that maps user-defined labels to pre-existing variable names
                "lnkl" => "Ln(Capital per worker)",
                "ln_gdp_pc" => "Ln(GDP per capita) country level",
                "fra_lab" => "Composite labor freedom index",
                "fra_credit" => "Credit market freedom index",
                "fra_min_wage" => "Labor freedom—minimum wage",
                "fra_hire_fire" => "Labor freedom—hiring and firing",
                "fra_unemp_ins" => "Labor freedom—unemployment benefits",
                "fra_coll_barg" => "Labor freedom—collective bargaining",
                "fra_conscp" => "Labor freedom—conscription",
                "year" => "Year fixed effects",
                "isic3d_3dig" => "Industry fixed effects",
                "cno" => "Country fixed effects",
            )
)
