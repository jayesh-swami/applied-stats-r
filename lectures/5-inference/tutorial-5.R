library(dplyr)
# library(ggplot2)
library(MASS)

power.t.test(delta = 1, sd = 1.7, sig.level = 0.05, power = 0.8,
            type = "two.sample", alternative = "two.sided")

# Two-sample t test power calculation 
# 
# n = 46.34674
# delta = 1
# sd = 1.7
# sig.level = 0.05
# power = 0.8
# alternative = two.sided
# 
# NOTE: n is number in *each* group

power.t.test(delta = 1, sd = 1.7, sig.level = 0.05, 
            n = 20, type = "two.sample", alternative = "two.sided")

# Two-sample t test power calculation 
# 
# n = 20
# delta = 1
# sd = 1.7
# sig.level = 0.05
# power = 0.4416243
# alternative = two.sided
# 
# NOTE: n is number in *each* group

power.t.test(power = 0.8, sd = 1.7, sig.level = 0.05, 
             n = 20, type = "two.sample", alternative = "two.sided")

# Two-sample t test power calculation 
# 
# n = 20
# delta = 1.545522
# sd = 1.7
# sig.level = 0.05
# power = 0.8
# alternative = two.sided
# 
# NOTE: n is number in *each* group


# Loop to generate multiple risk levels and plot n against them

delta <- 1     # difference to detect
sd    <- 1.7     # standard deviation
power <- 0.8    # desired power

alphas <- c(0.10, 0.05, 0.025, 0.01, 0.001)
n_needed <- numeric(length(alphas))

for (i in seq_along(alphas)) {
  res <- power.t.test(delta = delta, sd = sd, sig.level = alphas[i],
                      power = power, type = "two.sample")
  n_needed[i] <- ceiling(res$n)
}

results <- data.frame(alpha = alphas, n_per_group = n_needed)

n_vs_sig_plot <- ggplot(data = results, aes(x = alpha, y = n_per_group))
n_vs_sig_plot <- n_vs_sig_plot + geom_line()
n_vs_sig_plot

##
## MCDO DATASET

mc <- read.csv2("mcdo.csv", header = TRUE, sep = ',')

mc_by_type <- mc |> group_by(Type) |> summarize(
  avg_energy_per_g = mean(Energie.kcal / Masse.g),
  avg_protein_percent = mean(100 * Proteines.g / Masse.g), 
  avg_fiber_percent = mean(100 * Fibres.g / Masse.g), 
  avg_sugar_percent = mean(100 * Sucres.g / Masse.g),
  avg_sat_fat_percent = mean(100 * as.numeric(SatMatGras.g) / Masse.g),
  avg_fat_percent = mean(100 * MatGras.g / Masse.g))

mc |> group_by(Type, Pays) |> summarize(
  avg_energy_per_g = mean(Energie.kcal / Masse.g),
  avg_protein_percent = mean(100 * Proteines.g / Masse.g), 
  avg_fiber_percent = mean(100 * Fibres.g / Masse.g), 
  avg_sugar_percent = mean(100 * Sucres.g / Masse.g),
  avg_sat_fat_percent = mean(100 * as.numeric(SatMatGras.g) / Masse.g),
  avg_fat_percent = mean(100 * MatGras.g / Masse.g))

# Type    Pays  avg_energy_per_g avg_protein_percent avg_fiber_percent avg_sugar_percent avg_sat_fat_percent avg_fat_percent
# <chr>   <chr>            <dbl>               <dbl>             <dbl>             <dbl>               <dbl>           <dbl>
#   1 Burger  FR                2.45                12.9              1.43            3.56                  4.25           11.6 
# 2 Burger  US                2.52                13.5              1.38            4.60                  4.02           11.7 
# 3 Croque  FR                2.74                14.7              2.11            4.21                  6.32           10.5 
# 4 Nuggets FR                2.46                15.4              1.23            0.0694                1.69           12.6 
# 5 Nuggets US                2.91                13.6              1.13            0.0310                3.09           18.4 
# 6 Wrap    FR                2.37                10.5              1.37            2.01                  2.62           12.1 
# 7 Wrap    US                2.08                10.7              1.09            3.33                  2.84            9.27


usa_burgers <- mc |> filter(Pays == "US" & Type == "Burger")

us_fat <- usa_burgers[, c("MatGras.g")]
use_mean = mean(us_fat)
use_sd = sqrt(sum((us_fat - use_mean)^2) / length(us_fat))

# from MASS lib
fitdistr(us_fat, "normal")

# density histo

use_plot <- ggplot(data.frame(us_fat), aes(x = us_fat))
use_plot <- use_plot + geom_histogram(aes(y = after_stat(density)), bins = 10)
use_plot <- use_plot + stat_function(fun = dnorm, args = list(mean = use_mean, sd = use_sd), colour = "red", linewidth = 1)
use_plot

# Shapiro wilk test

shapiro.test(us_fat)

# Shapiro-Wilk normality test
# 
# data:  us_fat
# W = 0.97464, p-value = 0.6001
# So we don't reject normal distribution

qqnorm(us_fat); qqline(us_fat, col = "red")

# Test whether mean protein content in wrap style sandwich is 26g

mc_wrap <- mc |> filter(Type == "Wrap") |> dplyr::select(Proteines.g)

t.test(mc_wrap, mu = 26)

# One Sample t-test
# 
# data:  mc_wrap
# t = -1.8476, df = 17, p-value = 0.08214
# alternative hypothesis: true mean is not equal to 26
# 95 percent confidence interval:
#   18.86028 26.47306
# sample estimates:
#   mean of x 
# 22.66667 

# Here we get p > 0.05, so we cant reject the hypothesis that avg protein is 26

# Comparing the sugar contents

mc_us_sug <- mc |> filter(Pays == "US") |> dplyr::select(Sucres.g) |> pull(Sucres.g)
mc_fr_sug <- mc |> filter(Pays == "FR") |> dplyr::select(Sucres.g) |> pull(Sucres.g)

boxplot(mc_us_sug, mc_fr_sug, 
        names = c("US", "France"),
        col = c("lightblue", "lightpink"))

# Comparing the energy contents

mc_us_eng <- mc |> filter(Pays == "US") |> dplyr::select(Energie.kcal) |> pull(Energie.kcal)
mc_fr_eng <- mc |> filter(Pays == "FR") |> dplyr::select(Energie.kcal) |> pull(Energie.kcal)

boxplot(mc_us_eng, mc_fr_eng, 
        names = c("US", "France"),
        col = c("lightblue", "lightpink"))

## On average the average fat contents in US are higher but energy contents are more
## comparable except a couple of outliers

var.test(mc_us_sug, mc_fr_sug)

# F test to compare two variances
# 
# data:  mc_us_sug and mc_fr_sug
# F = 1.8812, num df = 53, denom df = 22, p-value = 0.1059
# alternative hypothesis: true ratio of variances is not equal to 1
# 95 percent confidence interval:
#   0.8701017 3.6554523
# sample estimates:
#   ratio of variances 
# 1.881245 

t.test(mc_us_sug, mc_fr_sug)


