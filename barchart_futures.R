# Pre - Amble -----------------------------------------------------------------------------
rm(list = ls())
cat("\f")
getwd()

Sys.setenv(NASSQS_TOKEN = readLines(".secret"))

pckgs <- c("tidyverse", "stargazer", "rnassqs")
lapply(pckgs, library, character.only = TRUE)

corn_f <- read_csv("../../Data/zcu19_price-history-11-07-2018.csv") %>%
  filter(!str_detect(Time, "^8/"), !str_detect(Time, "^7/")) %>%
  mutate(avg_prc = mean(Last))

# Get and clean NASS API data -------------------------------------------------------------
# List parameters of interest to feed to rnassqs package
params = list(source_desc = "SURVEY", 
              state_alpha = "LA",
              year__GE = "2010",
              reference_period_desc = "YEAR",
              agg_level_desc = "STATE")

# County Cash Rent
# Feed parameters to rnassqs package
yield_c <- nassqs(params = params) %>%
  filter(str_detect(short_desc, "CORN, GRAIN - YIELD, MEASURED IN BU / ACRE")) %>% 
  select(state_name, state_alpha, agg_level_desc, short_desc, Value, year) %>%  # keep variables of interest
  mutate(Value = as.numeric(Value))

mean(yield_c$Value)