## PART - B

# B1 - 20 element vector with random number until 100
v <- sample.int(100, 20, replace = FALSE)

# B2 - Conversion of v into a 4x5 matrix
m <- matrix(v, nrow = 4, ncol = 5, byrow = TRUE)

# B2 - Accesing the second col of m
m[,2]

# B3 - Creating a df with students name, age, math, phys

df <- data.frame(
  name = c("Nouh", "Jayesh", "Imad", "Becky", "Shavvot", "Matre"),
  age = c(50, 20, 20, 30, 25, 25),
  math = c(15, 15, 10, 11, 12, 14),
  phys = sample.int(20, 6, replace = TRUE),
  philo = sample.int(20, 6, replace = TRUE)
)


## PART - C

# C1 - name, age and math for students age > 22 and math >= 12
df[df$age >= 22 & df$math >= 12, c("name", "age", "math")]


# C2 - Name of students with phy > 15 using which()
idx_phy_fifteen <- which(df$phys > 15)
df[idx_phy_fifteen, c("name")]


# C3 - sort by math desc then by age asc

# This works but only with radix sort
df[order(df$math, df$name, decreasing = c(TRUE, FALSE), method = "radix"), ]

# Neat trick to sort when one col is numeric
df[order(-df$math, df$name), ]


# C4 - create a freq count of age and convert it to proportions
tab_age = table(df$age)
prop_age = prop.table(tab_age)

# C5 - Grade column to df
df$grade_phys = cut(
  df$phys, 
  breaks = c(0, 10, 14, Inf),
  labels = c("Fail", "OK", "Excellent"))

df$grade_math = cut(
  df$math, 
  breaks = c(0, 10, 14, Inf),
  labels = c("Fail", "OK", "Excellent"))

df$grade_philo = cut(
  df$philo, 
  breaks = c(0, 10, 14, Inf),
  labels = c("Fail", "OK", "Excellent"))


# C6 - merge with table of cities, choosing all = TRUE for full join 

df_cities = data.frame(
  name = c("Nouh", "Jayesh", "Imad", "Becky", "Shavvot", "Matre"),
  city = c("Paris", "Paris", "Nice", "Lyon", "Lyon", "Saint-Tropez")
)

merged_df = merge(df, df_cities, by="name", all = TRUE)

tapply(merged_df$math, merged_df$city, mean)


## PART - D

class(df$grade_math)

df$grade_math = as.character(df$grade_math)

class(df$grade_math)
# output character

# the as.numeric returns the label codes and ignores the labels


## PART - E

# E - 1

mean(df$math)
variance <- sd(df$math) * sd(df$math)
quantile(df$math)

# E - 2

coin_toss_exp <- rbinom(30, 1, 0.5)
sum(coin_toss_exp)

# E - 3

m25 <- matrix(1:25, nrow = 5, ncol = 5, byrow = TRUE)
apply(m25, 1, sum)
apply(m25, 2, mean)


## PART - F

# F - 1
tapply(df$math, df$grade_math, colM)

# F - 2
by(df[, c("math", "phys")], df$age, colMeans)


## PART - I

# I - 1
plot(df$math, df$phys, main = "Math vs Physics", xlab = "math", ylab = "physics")
abline(lm(phys ~ math, data = df))

# I - 2

simul_normal = rnorm(100, mean = 12, sd = 3)
hist(simul_normal, main = "Histogram of simulated 100 data points of normal dist", xlab = "value")

# I - 3 -> this is comparative plot of all pairs across three vars
pairs(df[,c("age","math","phys")])

