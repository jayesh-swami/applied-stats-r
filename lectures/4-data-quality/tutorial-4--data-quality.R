library(tidyr)
library(ggplot2)
library(visdat)
library(mice)
library(naniar)
library(VIM)

data("airquality")

aq <- airquality

summary(aq)

# Count of na per col
na_count_by_col <- sapply(aq[, ], function(x) sum(is.na(x)))

# Total na count
sum(na_count_by_col)

# na count percentage
sapply(aq[, ], function(x) sum(is.na(x) * 100 / length(x) ))

# deleted all rows with na
aq_na_dropped <- drop_na(aq)

# impute mean
aq_mean_imputed_ozone <- aq
aq_mean_imputed_ozone$Ozone <- mean(aq_mean_imputed_ozone$Ozone, na.rm = TRUE)

aq_mean_imputed_all <- impute_mean(aq)

# seed

set.seed(12345)

# Visualizing the missing data
vis_miss(aq)

# mice pattern
md.pattern(aq)

aq_miced_5 <- mice(aq, m = 5, maxit = 5)
complete(aq_miced_5, 3)

stripplot(aq_miced_5)
