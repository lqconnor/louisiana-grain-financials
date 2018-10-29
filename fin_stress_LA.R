
# Pre - Amble -----------------------------------------------------------------------------
rm(list = ls())
cat("\f")
getwd()

Sys.setenv(NASSQS_TOKEN = readLines(".secret"))

pckgs <- c("tidyverse", "stargazer", "rnassqs")
lapply(pckgs, library, character.only = TRUE)


income <- read_csv("../../Data/FarmIncome_WealthStatisticsData_August2018.csv") %>%
  filter(str_detect(VariableDescriptionTotal, "Net cash income"), State == "LA", Year >= 2010)

cash <- read_csv("../../Data/FarmIncome_WealthStatisticsData_August2018.csv") %>%
  filter(str_detect(VariableDescriptionTotal, "receipts"), Year >= 2010)



# Get and clean NASS API data -------------------------------------------------------------
# List parameters of interest to feed to rnassqs package
params = list(source_desc = "SURVEY", 
              state_alpha = "LA",
              year = "2017")

# County Cash Rent
# Feed parameters to rnassqs package
asset <- nassqs(params = params) %>%
  select(state_name, state_alpha, agg_level_desc, short_desc, Value, year)  # keep variables of interest