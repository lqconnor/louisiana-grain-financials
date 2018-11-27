# Pre - Amble -----------------------------------------------------------------------------
rm(list = ls())
cat("\f")
getwd()

Sys.setenv(NASSQS_TOKEN = readLines(".secret"))

pckgs <- c("tidyverse", "stargazer", "rnassqs")
lapply(pckgs, library, character.only = TRUE)

# ARC payment data from FSA (yields here usually higher than RMA data)
aph <- read_csv("../../Data/AreaPlanHistoricalYields.csv") %>%
  filter(`Commodity Year` == 2018, `Yield Year` >= 2007) %>%
  group_by(`Commodity Code`, `Irrigation Practice Code`) %>%
  mutate(m_yld = mean(`Yield Amount`)) %>%
  ungroup() %>%
  select(-`Yield Amount`, -`Trended Yield Amount`, 
         -`Detrended Yield Amount`, -`County Code`, 
         -`County Name`, -`Yield Year`,
         -`Reference Irrigation Practice Name`,
         -`Reference Irrigation Practice Code`,
         -`Insurance Policy Name`) %>%
  distinct()

# SCO data from the RMA
sco <- read_csv("../../Data/SCOYieldsRevenuesPaymentIndicators_2.csv") %>%
  filter(!str_detect(`Practice Name`, "Organic")) %>%
  group_by(`Commodity Code`, `Practice Code`) %>%
  mutate(m_yld = mean(`Expected County Yield`)) %>%
  ungroup() %>%
  select(-(`County Code`:`Insurance Option Name`),
  -(`Commodity Type Code`:`Supp Cov Opt - Rev Prot with Harv Price Excl (33)`),
  -`Commodity Year`) %>%
  distinct()

