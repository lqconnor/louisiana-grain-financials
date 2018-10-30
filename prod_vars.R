# Pre - Amble -----------------------------------------------------------------------------
rm(list = ls())
cat("\f")
getwd()

Sys.setenv(NASSQS_TOKEN = readLines(".secret"))

pckgs <- c("tidyverse", "stargazer", "rnassqs")
lapply(pckgs, library, character.only = TRUE)

corn_f <- read_csv("../../Data/zcz19_price-history-10-29-2018_1.csv") %>%
  filter(!str_detect(Time, "^8/"), !str_detect(Time, "^7/")) %>%
  mutate(avg_prc = mean(Last))

# Get and clean NASS API data -------------------------------------------------------------
# List parameters of interest to feed to rnassqs package
params = list(source_desc = "SURVEY", 
              state_alpha = "LA",
              year__GE = "2010",
              reference_period_desc = "YEAR",
              agg_level_desc = "STATE")

# Commodities and values of interest
commodities <- c("WHEAT", "CORN", "SOYBEANS", "SORGHUM")
vars <- c("YIELD", "PLANTED")
nass_cleaner <- c("NET", "SWEET", "FOLLOWING", "IRRIGATED", "PIMA", "FORAGE", 
                  "EXCL", "SPRING", "WINTER", "PLANTED ACRE", "TREATED", "PEST")


# Feed parameters to rnassqs package
yield_c <- nassqs(params = params) %>%
  filter(str_detect(short_desc, paste(commodities, collapse = '|'))) %>%
  filter(str_detect(short_desc, paste(vars, collapse = '|'))) %>%
  filter(!(str_detect(short_desc, paste(nass_cleaner, collapse = '|')))) %>%
  filter(!(str_detect(util_practice_desc, "SILAGE"))) %>%
  select(state_name, state_alpha, state_fips_code, county_code, agg_level_desc, short_desc, Value, year) %>%  # keep variables of interest
  mutate(Value = as.numeric(gsub(",","", Value, fixed = TRUE)))

# SHORT_DESC: Clean ---------------------------------------------------------------------------
# Use regex to make all SHORT_DESC observations consistent to convert to tidy form
yield_c <- mutate(yield_c, short_desc = sub(",[[:blank:]][A-Z]+", "", short_desc), 
                  short_desc = sub(",.*", "", short_desc),
                  short_desc = gsub("- ", "-", short_desc),
                  short_desc = gsub(" -", "-", short_desc),
                  short_desc = gsub("YIELD", "YIELD ", short_desc),
                  short_desc = gsub("////[[:blank:]].*", "", short_desc),
                  short_desc = gsub(" IN.*", "", short_desc))

# Convert to tidy form ------------------------------------------------------------------------
yield_c <- separate(yield_c, short_desc, into = c("commodity", "description"), sep = "-") %>%
  spread(key = description, value = Value) %>%
  rename(yield = `YIELD `) %>%
  rename(plnt_acr = `ACRES PLANTED`) %>%
  group_by(state_fips_code, county_code, commodity) %>%
  arrange(state_fips_code, county_code, commodity, year) %>%
  mutate(sum = cumsum(yield)) %>%
  mutate(lag = lag(sum, 10)) %>%
  ungroup()