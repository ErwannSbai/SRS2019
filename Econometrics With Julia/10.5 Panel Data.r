library(AER)
library(plm)
library(stargazer)

Fatalities = read.csv("fatalities.csv", header = TRUE)

#data("Fatalities")

Fatalities$fatal_rate <- Fatalities$fatal / Fatalities$pop * 10000

# discretize the minimum legal drinking age
Fatalities$drinkagec <- cut(Fatalities$drinkage,
                            breaks = 18:22, 
                            include.lowest = TRUE, 
                            right = FALSE)

# set minimum drinking age [21, 22] to be the baseline level
Fatalities$drinkagec <- relevel(Fatalities$drinkagec, "[21,22]")

# mandadory jail or community service?
Fatalities$punish <- with(Fatalities, factor(jail == "yes" | service == "yes", 
                                             labels = c("no", "yes")))

# the set of observations on all variables for 1982 and 1988
Fatalities_1982_1988 <- Fatalities[with(Fatalities, year == 1982 | year == 1988), ]

print(Fatalities_1982_1988$drinkagec)

# estimate all seven models
fatalities_mod1 <- lm(fatal_rate ~ beertax, data = Fatalities)

fatalities_mod2 <- plm(fatal_rate ~ beertax + state, data = Fatalities)

fatalities_mod3 <- plm(fatal_rate ~ beertax + state + year,
                       index = c("state","year"),
                       model = "within",
                       effect = "twoways", 
                       data = Fatalities)

fatalities_mod4 <- plm(fatal_rate ~ beertax + state + year + drinkagec 
                       + punish + miles + unemp + log(income), 
                       index = c("state", "year"),
                       model = "within",
                       effect = "twoways",
                       data = Fatalities)

fatalities_mod5 <- plm(fatal_rate ~ beertax + state + year + drinkagec 
                       + punish + miles,
                       index = c("state", "year"),
                       model = "within",
                       effect = "twoways",
                       data = Fatalities)

fatalities_mod6 <- plm(fatal_rate ~ beertax + year + drinkage 
                       + punish + miles + unemp + log(income), 
                       index = c("state", "year"),
                       model = "within",
                       effect = "twoways",
                       data = Fatalities)

fatalities_mod7 <- plm(fatal_rate ~ beertax + state + year + drinkagec 
                       + punish + miles + unemp + log(income), 
                       index = c("state", "year"),
                       model = "within",
                       effect = "twoways",
                       data = Fatalities_1982_1988)

summary(fatalities_mod7)$coefficients["beertax","Std. Error"]
summary(fatalities_mod7)$coefficients["drinkagec[18,19)","Std. Error"]
summary(fatalities_mod7)$coefficients["drinkagec[19,20)","Std. Error"]
summary(fatalities_mod7)$coefficients["drinkagec[20,21)","Std. Error"]
summary(fatalities_mod7)$coefficients["punishyes","Std. Error"]
summary(fatalities_mod7)$coefficients["miles","Std. Error"]
summary(fatalities_mod7)$coefficients["unemp","Std. Error"]
summary(fatalities_mod7)$coefficients["log(income)","Std. Error"]
sqrt(diag(vcovHC(fatalities_mod7, type = "HC1")))

# gather clustered standard errors in a list
rob_se <- list(sqrt(diag(vcovHC(fatalities_mod1, type = "HC1"))),
               sqrt(diag(vcovHC(fatalities_mod2, type = "HC1"))),
               sqrt(diag(vcovHC(fatalities_mod3, type = "HC1"))),
               sqrt(diag(vcovHC(fatalities_mod4, type = "HC1"))),
               sqrt(diag(vcovHC(fatalities_mod5, type = "HC1"))),
               sqrt(diag(vcovHC(fatalities_mod6, type = "HC1"))),
               sqrt(diag(vcovHC(fatalities_mod7, type = "HC1"))))

print(vcovHC(fatalities_mod2, type = "HC1"))

# generate the table
stargazer(fatalities_mod1, fatalities_mod2, fatalities_mod3, 
          fatalities_mod4, fatalities_mod5, fatalities_mod6, fatalities_mod7, 
          digits = 3,
          header = FALSE,
          type = "html", 
          se = rob_se,
          title = "Linear Panel Regression Models of Traffic Fatalities due to Drunk Driving",
          model.numbers = FALSE,
          column.labels = c("(1)", "(2)", "(3)", "(4)", "(5)", "(6)", "(7)"))

