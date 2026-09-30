library(ggplot2)
library(dplyr)
library(stringr)
library(tidyr)

### 3


# Read the prenom dataset
df_prenom <- read.csv(
  "./dataset/DS_PRENOM_2024_data.csv", 
  header = TRUE, 
  sep = ";")


# Filter for FRANCE
df_prenom_filtered_france <- df_prenom |> filter(df_prenom$GEO_OBJECT == "FRANCE")

# Count distinct names with underscore in them
df_prenom_filtered_france |> 
  filter(str_detect(df_prenom_filtered_france$FIRST_NAME, "_")) |> 
  pull(FIRST_NAME) |> 
  n_distinct()

# Separate the name using _ delim
accented_names_split <- 
  df_prenom_filtered_france |> 
  filter(str_detect(df_prenom_filtered_france$FIRST_NAME, "_")) |> 
  separate_wider_delim(FIRST_NAME, delim = "_", names = c("FIRST_NAME", "number"))

# Count the distinct names and sort them by count
accented_names_split |> count(FIRST_NAME, number, sort = TRUE)

## Fuse the name with different spellings

accented_names_split |> 
  group_by(FIRST_NAME, SEX, TIME_PERIOD) |> 
  summarise(OBS_VALUE = sum(OBS_VALUE)) |> 
  ungroup()


### 4

## 4.1

# min and max time of data 
summary(df_prenom_filtered_france$TIME_PERIOD)

# total num of birth per year
total_birth_per_year <- 
  df_prenom_filtered_france |> 
  group_by(TIME_PERIOD) |> 
  count(name = "NUM_BIRTHS") |>
  ungroup()

# highest and lowest 10 for num of birth years
# Could assign a var here to not sort twice
total_birth_per_year |> arrange(NUM_BIRTHS) |> slice_head(n = 5)
total_birth_per_year |> arrange(NUM_BIRTHS, desc()) |> slice_head(n = 5)


## 4.2

# My name in the dataset - 0 :(
df_prenom_filtered_france |> 
  filter(str_detect(df_prenom_filtered_france$FIRST_NAME, "JAYESH")) |> 
  count()

# People born before me - taking all people here as there is no on with my name
people_born_before_after_me <-
  df_prenom_filtered_france |> 
  select(TIME_PERIOD) |> 
  mutate(BORN_BEFORE = ifelse(TIME_PERIOD < 1999, 1, 0))

people_born_before_after_me |> filter(BORN_BEFORE == 1) |> count()

people_born_before_after_me |> filter(BORN_BEFORE == 0) |> count()


## 4.3

# Top name counts by year and sex
name_counts_by_year_sex <- 
  df_prenom_filtered_france |> 
  group_by(TIME_PERIOD, SEX) |> 
  slice_max(OBS_VALUE, n = 1) |>
  ungroup()

name_counts_by_year_sex |> select(FIRST_NAME, TIME_PERIOD, OBS_VALUE, SEX)

# Top names in 5 highest and lowest birth count years
top_5_years_by_birth_count <- 
  df_prenom_filtered_france |>
  select(TIME_PERIOD, OBS_VALUE) |>
  group_by(TIME_PERIOD) |>
  summarise(TOTAL_BIRTHS = sum(OBS_VALUE)) |>
  arrange(desc(TOTAL_BIRTHS)) |>
  slice_head(n = 5) |>
  select(TIME_PERIOD)

bottom_5_years_by_birth_count <- 
  df_prenom_filtered_france |>
  select(TIME_PERIOD, OBS_VALUE) |>
  group_by(TIME_PERIOD) |>
  summarise(TOTAL_BIRTHS = sum(OBS_VALUE)) |>
  arrange(desc(TOTAL_BIRTHS)) |>
  slice_tail(n = 5) |>
  select(TIME_PERIOD)

name_counts_by_year_sex |> 
  filter(TIME_PERIOD %in% (top_5_years_by_birth_count$TIME_PERIOD))

name_counts_by_year_sex |> 
  filter(TIME_PERIOD %in% (bottom_5_years_by_birth_count$TIME_PERIOD))








