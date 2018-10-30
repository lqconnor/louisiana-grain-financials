rm(list = ls())
cat("\f")
getwd()

#Load Packages
pckgs <- c("tidyverse", "stargazer", "rnass", "rnassqs", "plm", "Quandl")
lapply(pckgs, library, character.only = TRUE)

Quandl.api_key("T37zVjH_yydVNbjMs8Rg")

z <- 2018

data <- Quandl(str_c('CME/CZ',z),start_date= str_c(z,"-2-1"), end_date=str_c(z,"-3-1"))
data <- filter(data, Date != str_c(z,"-3-1")) %>%         #Takes data point for 3-1-2018 out. Pulled that date to account for leap years
  mutate(avg_prc = mean(Settle))