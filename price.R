# Pre - Amble -----------------------------------------------------------------------------
rm(list = ls())
cat("\f")
getwd()

Sys.setenv(NASSQS_TOKEN = readLines(".secret"))

pckgs <- c("tidyverse", "stargazer", "rnassqs")
lapply(pckgs, library, character.only = TRUE)

corn_f <- read_csv("../../Data/zcu19_price-history-11-07-2018.csv") %>%
  filter(!str_detect(Time, "^8/"), !str_detect(Time, "^7/"), !str_detect(Time, "^11/")) %>%
  mutate(avg_prc = mean(Last))

# Get and clean NASS API data -------------------------------------------------------------
# List parameters of interest to feed to rnassqs package
svy_yr = 2015
params = list(source_desc = "SURVEY", 
              state_alpha = "US",
              year__GE = svy_yr,
              sector_desc = "CROPS",
              reference_period_desc = "YEAR")

# Commodities and values of interest
commodities <- c("WHEAT", "CORN", "SOYBEANS", "SORGHUM", "COTTON", "^RICE")          # Commodities we want to keep
vars <- c("PRICE")                                                                   # Specifies production variables we want to keep
nass_cleaner <- c("NET", "SWEET", "FOLLOWING", "IRRIGATED", "PIMA", "FORAGE",        # Remove commodity breakdowns we don't want
                  "EXCL", "SPRING", "WINTER", "PLANTED ACRE", "TREATED",
                  "BIOTECH", "PEST", "UPLAND", "LONG", "MEDIUM", "FLAXSEED")

# Feed parameters to rnassqs package
price <- nassqs(params = params) %>%
  filter(str_detect(short_desc, paste(commodities, collapse = '|'))) %>%
  filter(str_detect(short_desc, paste(vars, collapse = '|'))) %>%
  filter(!(str_detect(short_desc, paste(nass_cleaner, collapse = '|')))) %>%
  filter(!(str_detect(util_practice_desc, "SILAGE"))) %>%
  select(state_name, state_alpha, state_fips_code, county_code, agg_level_desc, short_desc, Value, year) %>%  # keep variables of interest
  mutate(Value = as.numeric(gsub(",","", Value, fixed = TRUE)))
