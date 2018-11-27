rm(list = ls())
cat("\f")
getwd()

#Load Packages
pckgs <- c("tidyverse", "stargazer", "rnass", "rnassqs", "plm", "Quandl")
lapply(pckgs, library, character.only = TRUE)

Quandl.api_key("T37zVjH_yydVNbjMs8Rg")

z <- 2018

data <- Quandl(str_c('CME/SX',z),start_date= str_c(z,"-10-1"), end_date=str_c(z,"-10-30")) %>%
  mutate(avg_prc = mean(Settle))