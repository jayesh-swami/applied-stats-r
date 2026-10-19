# Applied Statistics in R: Challenge Cheat Sheet

Covers: base R, dplyr/tidyverse, ggplot2, missing data (mice, naniar, VIM), hypothesis tests, power, MLE, and PCA (prcomp, FactoMineR, factoextra).

---

## 0. Setup and help

```r
install.packages(c("tidyverse", "mice", "naniar", "VIM", "FactoMineR", "factoextra"))

library(MASS)        # load BEFORE dplyr, or use MASS::fitdistr() without loading
library(tidyverse)   # ggplot2, dplyr, tidyr, readr, tibble, ...
library(mice); library(naniar); library(VIM)
library(FactoMineR); library(factoextra)

?rnorm; help(t.test); example(hist)
getwd(); setwd("~/path/to/folder")       # or Session > Set Working Directory
```

**Gotcha:** MASS masks `dplyr::select()`. Symptom: `unused arguments` error in `select()`. Fix: `dplyr::select(...)`.

---

## 1. Base R objects

**What/why:** everything in R is built from these. Data frames are the main object for analysis: columns are variables, rows are observations.

```r
v <- 1:10                                    # vector (one type only)
x <- sample(1:100, 20, replace = TRUE)       # 20 random integers in 1..100
m <- matrix(x, nrow = 4, ncol = 5)           # 4x5 matrix
m[, 2]                                       # 2nd column
L <- list(ids = 101:103, msg = "hello")      # list (mixed types)
df <- data.frame(name = c("Alice","Bob","Chloe"),
                 age  = c(21, 24, 22),
                 math = c(14, 9, 16),
                 phys = c(15, 12, 17))
```

### Inspecting

```r
str(df)          # types + preview: run this FIRST after loading data
summary(df)      # min/quartiles/mean/max, NA counts
head(df); dim(df); nrow(df); ncol(df); names(df)
class(x); typeof(x); is.numeric(x)
sapply(df, class)                            # type of every column
```

---

## 2. Indexing and filtering (base R)

**What/why:** `df[rows, cols]`. Left of comma filters rows, right selects columns. Blank means "all".

```r
df$math                       # column as vector
df[, "phys"]                  # same (vector)
df[, "phys", drop = FALSE]    # keep as data frame
df[df$math >= 12, ]           # rows matching condition
df[df$age > 22 & df$math >= 12, c("name","age","math")]
df[df$name %in% c("Alice","Bob"), ]
idx <- which(df$phys > 15); df$name[idx]
subset(df, age > 22 & math >= 12, select = c(name, age, math))
```

**Gotchas**
- `df[cond]` without a comma selects COLUMNS, not rows.
- Use `&` and `|` for filtering, never `&&` / `||`.
- NA in a condition gives NA rows: add `& !is.na(x)`.

---

## 3. Sorting, unique, tables

```r
df[order(df$math), ]                         # ascending
df[order(-df$math, df$name), ]               # math desc, name asc tiebreak
df[order(df$name, df$math, decreasing = c(TRUE, FALSE), method = "radix"), ]
unique(df$age)

tab <- table(df$age)                         # frequency counts
table(Age = df$age)                          # labelled dimension
prop.table(tab)                              # proportions
round(100 * prop.table(tab), 1)              # percentages
table(df$x, df$y); addmargins(table(df$x, df$y))
prop.table(table(df$x, df$y), 1)             # row %
sort(tab, decreasing = TRUE)
as.data.frame(tab)
```

---

## 4. Creating and recoding columns

```r
df$avg   <- rowMeans(df[, c("math","phys")])
df$pass  <- ifelse(df$avg >= 10, "Pass", "Fail")
df$grade <- cut(df$avg, breaks = c(-Inf, 10, 14, Inf), right = FALSE,
                labels = c("Fail", "OK", "Excellent"))   # [0,10) [10,14) [14,+)
df$phys  <- NULL                                         # delete column
```

### Factors

**What:** categorical variable stored as integer codes + labels (levels).

```r
f <- factor(c("B","A","C"), levels = c("C","B","A"))
levels(f); nlevels(f); droplevels(f)
as.character(f)                  # labels
as.numeric(f)                    # internal CODES 1..k (not the values!)
as.numeric(as.character(f))      # correct way to get numbers back
```

### Type conversion

```r
as.numeric("3.5")
df[cols] <- lapply(df[cols], function(x) as.numeric(as.character(x)))  # [] keeps df
as.numeric(gsub(",", ".", x))     # decimal commas
readr::parse_number(x)            # strips junk characters
x[x == "."] <- NA                 # placeholder to NA
read.csv("f.csv", na.strings = c(".", "", "NA"), dec = ".")
```

---

## 5. Joining and binding

```r
merge(df, df2, by = "name")                  # inner
merge(df, df2, by = "name", all.x = TRUE)    # left
merge(df, df2, by.x = "city", by.y = "ville")
merge(df1, df2, by = "row.names")
cbind(df1, df2)     # side by side (same rows, same order!)
rbind(df1, df2)     # stacked (same columns)
```

---

## 6. Group summaries (base R)

**What/why:** "group by X, summarise Y", e.g. mean math per city.

```r
aggregate(math ~ age, data = df, FUN = mean)
aggregate(cbind(math, phys) ~ grade + city, data = df, FUN = mean)
tapply(df$math, df$grade, mean)              # named vector
tapply(df$math, list(df$grade, df$sex), mean)  # matrix
by(df[, c("math","phys")], df$age, colMeans)
```

---

## 7. Apply family

**What/why:** loop over rows/columns/elements without `for` loops.

| Function | Over | Returns |
|---|---|---|
| `apply(X, 1/2, f)` | rows (1) / cols (2) of matrix/df | vector/matrix |
| `lapply(X, f)` | elements / df columns | list |
| `sapply(X, f)` | elements / df columns | simplified vector/matrix |
| `vapply(X, f, numeric(1))` | like sapply, type-safe | vector |
| `tapply(x, g, f)` | groups | array |
| `mapply(f, a, b)` | several vectors in parallel | vector |

```r
apply(M, 1, mean); apply(M, 2, sd)
M5 <- matrix(1:25, 5); apply(M5, 1, sum); apply(M5, 2, mean)
lapply(df, class); sapply(df, is.numeric)
sapply(df, mean, na.rm = TRUE)               # extra args after f
sapply(df, function(x) c(mean = mean(x), sd = sd(x)))   # matrix
```

**Gotchas:** `apply()` turns a df into a matrix (one type). `lapply()` result assigned with `df <-` becomes a list: use `df[] <- lapply(...)`.

---

## 8. Descriptive stats and random numbers

```r
mean(x); median(x); var(x); sd(x); range(x); IQR(x)
quantile(x); quantile(x, c(0.1, 0.9)); summary(x)
cor(df$math, df$phys); cor(df[, c("math","phys","age")])
sum(x > 70); mean(x > 70)                    # count / proportion meeting condition
set.seed(42)
rnorm(100, mean = 12, sd = 3); runif(10); sample(1:6, 10, TRUE)
sum(rbinom(30, size = 1, prob = 0.5))        # heads in 30 tosses
```

Distribution functions: `d*` density, `p*` cumulative, `q*` quantile, `r*` random (`dnorm`, `pt`, `qchisq`, `rbinom`, ...).

---

## 9. Base R plotting

```r
plot(df$math, df$phys, main = "Math vs Physics", xlab = "Math", ylab = "Physics")
abline(lm(phys ~ math, data = df), lwd = 2)  # regression line
abline(h = 10, v = 12, lty = 2, col = "red")
hist(x, freq = FALSE, breaks = 20)           # density histogram
curve(dnorm(x, 12, 3), add = TRUE, col = "red", lwd = 2)
barplot(table(df$age))
boxplot(math ~ grade, data = df)
boxplot(us_vec, fr_vec, names = c("US","FR"))   # VECTORS (use pull(), not select())
pairs(df[, c("age","math","phys")])
qqnorm(x); qqline(x, col = "red")
par(mfrow = c(1, 2)); ...; par(mfrow = c(1, 1))
```

### Input/output

```r
write.csv(df, "students.csv", row.names = FALSE)
df  <- read.csv("students.csv")
mc  <- read.csv("mcdo.csv", sep = ";", dec = ",")   # adapt to file
vil <- read.table("villes.txt", header = TRUE, row.names = 1)
```

---

## 10. dplyr / tidyverse

**What/why:** readable verbs chained with the pipe `|>`. `x |> f(y)` is `f(x, y)`.

```r
df |> filter(age > 22, math >= 12)                  # comma = AND
df |> filter(eye_color %in% c("yellow","brown"), !is.na(mass))
df |> group_by(gender) |> filter(mass > mean(mass, na.rm = TRUE))
df |> select(name, starts_with("h"), where(is.numeric), -phys)
df |> pull(math)                                    # one column as VECTOR
df |> mutate(bmi = mass / (height/100)^2,
             heavy = if_else(mass > 100, TRUE, FALSE))
df |> arrange(desc(math), name)
df |> slice_head(n = 5)                             # n MUST be named
df |> group_by(grade) |> slice_max(math, n = 1)     # top per group
df |> count(class); df |> distinct(city)
```

### summarise vs mutate

- `summarise()` gives ONE row per group (aggregation).
- `mutate()` keeps ALL rows, adds a column (group value repeated).

```r
df |> group_by(Type, Pays) |>
  summarise(n = n(), mean = mean(x, na.rm = TRUE), sd = sd(x, na.rm = TRUE),
            .groups = "drop")
df |> summarise(avg = mean(x), .by = c(Type, Pays))     # inline grouping
df |> group_by(grade) |> mutate(grp_mean = mean(math)) |> ungroup()
df |> summarise(across(where(is.numeric), list(mean = mean, sd = sd)))
df |> mutate(across(c(a, b), \(v) as.numeric(scale(v))))
```

**Gotcha:** leftover grouping makes later `slice_*()`/`filter()` work per group. Use `.groups = "drop"` or `ungroup()`.

### Joins, binding, pivoting

```r
left_join(a, b, by = "name"); inner_join(); full_join(); right_join()
left_join(a, b, by = c("city" = "ville"))
bind_rows(a, b); bind_cols(a, b)
iris |> pivot_longer(1:4, names_to = "Parameter", values_to = "Value")
sleep |> pivot_wider(names_from = group, names_prefix = "Group_", values_from = extra)
starwars |> select(-where(is.list)) |> mutate(across(where(is.character), as.factor)) |> summary()
```

---

## 11. ggplot2

**What/why:** layered grammar: data + `aes()` mappings + geoms + scales + facets + theme. Map variables INSIDE `aes()`, set constants OUTSIDE.

```r
p <- ggplot(mtcars, aes(wt, mpg)) + geom_point(aes(color = factor(cyl)), size = 2.5, alpha = .8) +
  labs(title = "Fuel consumption vs weight", subtitle = "mtcars",
       x = "Weight (1000 lbs)", y = "MPG", color = "Cylinders")
ggsave("plot.png", p, width = 5.5, height = 3.5, dpi = 300)
```

### Recipes

```r
# Smoothing: LOESS with CI + dashed linear fit
ggplot(mtcars, aes(wt, mpg)) + geom_point() +
  geom_smooth(se = TRUE) + geom_smooth(method = "lm", se = FALSE, linetype = "dashed")

# Bars: counts / dodged / proportions / precomputed & sorted
ggplot(mpg, aes(class)) + geom_bar()
ggplot(mpg, aes(class, fill = drv)) + geom_bar(position = "dodge")
ggplot(mpg, aes(class, fill = drv)) + geom_bar(position = "fill") + labs(y = "Proportion")
mpg |> count(class) |> ggplot(aes(reorder(class, n), n)) + geom_col() + coord_flip()

# Histogram + density per group
ggplot(iris, aes(Sepal.Length)) +
  geom_histogram(aes(y = after_stat(density)), binwidth = 0.25, boundary = 0, fill = "grey80") +
  geom_density(aes(color = Species))

# Histogram + superimposed normal curve
ggplot(data.frame(x), aes(x)) +
  geom_histogram(aes(y = after_stat(density)), bins = 15, fill = "grey80", colour = "white") +
  stat_function(fun = dnorm, args = list(mean = m, sd = s), colour = "red", linewidth = 1, n = 500)

# Boxplot + jitter; violin + embedded boxplot
ggplot(mpg, aes(class, hwy)) + geom_boxplot() + geom_jitter(width = .2, alpha = .3)
ggplot(mpg, aes(class, hwy)) + geom_violin(trim = FALSE) + geom_boxplot(width = .15)

# Facets
ggplot(mpg, aes(displ, hwy, color = class)) + geom_point(alpha = .6) + facet_wrap(~ drv)
ggplot(mpg, aes(displ, hwy)) + geom_point() + facet_grid(drv ~ cyl)

# Styling
p + scale_color_brewer(palette = "Dark2") + theme_minimal() +
  theme(legend.position = "bottom", panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold"))
```

### Means with 95% CI error bars

```r
s <- mpg |> group_by(class) |>
  summarise(n = n(), mean = mean(hwy), sd = sd(hwy), se = sd / sqrt(n),
            lo = mean - 1.96 * se, hi = mean + 1.96 * se)
ggplot(s, aes(reorder(class, mean), mean)) + geom_col(fill = "steelblue") +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = .2) + coord_flip() +
  labs(x = "Class (sorted by mean hwy)", y = "Mean highway MPG")
```

### 100% stacked bars with % labels

```r
ggplot(mpg, aes(class, fill = drv)) + geom_bar(position = "fill") +
  geom_text(aes(label = paste0(round(after_stat(count / tapply(count, x, sum)[x]) * 100), "%")),
            stat = "count", position = position_fill(vjust = 0.5), size = 3) +
  scale_y_continuous(labels = scales::percent) + labs(y = "Proportion")
```

### Overplotting and time series

```r
ggplot(mtcars, aes(wt, mpg)) + geom_bin2d() + labs(title = "2D binning")
ggplot(mtcars, aes(wt, mpg)) + geom_point(alpha = .4) + geom_density_2d()

economics |> mutate(unemprate = unemploy / pop) |>
  ggplot(aes(date, unemprate)) + geom_line() +
  geom_smooth(method = "loess", span = 0.2, se = FALSE) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  labs(title = "US unemployment rate", x = "Year", y = "Unemployment rate")
```

### Advanced (optional packages)

```r
ggridges::geom_density_ridges()                         # ggplot(mpg, aes(hwy, class)) + ...
ggrepel::geom_text_repel(aes(label = name))             # non-overlapping labels
gghighlight::gghighlight(hp / wt > quantile(hp / wt, .75))
GGally::ggpairs(d, upper = list(continuous = "cor"), diag = list(continuous = "densityDiag"))
patchwork: p1 + p2; (p1 + p2) / p3
```

**Common errors:** `stat_count() requires x` (use `geom_col` with y); use `after_stat(count)` not `..count..`; reorder bars with `reorder()`.

---

## 12. Missing data

**Why it matters:** NAs break calculations, and how you handle them can bias results. Deletion loses information; mean imputation keeps the mean but **shrinks variance** and weakens correlations; mice draws plausible values and preserves distributions.

**MCAR** = missing completely at random (deletion/mean imputation least harmful).

### Identify

```r
summary(airquality)
colSums(is.na(airquality))                         # count per column
sapply(airquality, function(x) sum(is.na(x)))      # same
sum(is.na(airquality))                             # total (44)
sapply(airquality, function(x) mean(is.na(x)) * 100)  # % per column
sum(!complete.cases(airquality))                   # incomplete rows
```

### Visualize

```r
mice::md.pattern(airquality)                       # missingness patterns table
VIM::aggr(airquality, numbers = TRUE, sortVars = TRUE, prop = TRUE,
          labels = names(airquality), cex.axis = .7, gap = 3)
naniar::vis_miss(airquality)
naniar::gg_miss_var(airquality)
```

### Delete

```r
aq_del <- na.omit(airquality); dim(aq_del)         # listwise: 111 x 6
tidyr::drop_na(airquality, Ozone)                  # only rows with NA in Ozone
airquality[rowSums(is.na(airquality)) != ncol(airquality), ]   # drop all-NA rows
airquality[, colMeans(is.na(airquality)) <= 0.5]   # drop cols > 50% NA
airquality[apply(airquality, 1, function(r) mean(is.na(r))) <= 0.5, ]  # rows > 50% NA
```

### Mean imputation

```r
aq_mean1 <- airquality                              # ONE column (Ozone only)
aq_mean1$Ozone[is.na(aq_mean1$Ozone)] <- mean(aq_mean1$Ozone, na.rm = TRUE)

aq_mean <- airquality                               # ALL numeric columns
aq_mean[] <- lapply(aq_mean, function(x) {
  if (is.numeric(x)) x[is.na(x)] <- mean(x, na.rm = TRUE); x })

airquality |> mutate(across(where(is.numeric), ~ coalesce(.x, mean(.x, na.rm = TRUE))))
naniar::impute_mean(x)      # vector version
```

### Compare original / deleted / imputed

```r
comp <- bind_rows(Original = airquality, Deleted = aq_del, Mean = aq_mean, .id = "source")
ggplot(comp, aes(Ozone, colour = source)) + geom_density(na.rm = TRUE)
# imputed data shows a spike at the mean (~42)
```

### mice

```r
set.seed(12345)
imp <- mice(airquality, m = 5, method = "pmm", maxit = 50, seed = 12345)
summary(imp); imp$imp$Ozone                         # imputed values
plot(imp)                                           # convergence (choose maxit)
stripplot(imp, pch = 20, cex = 1.2)                 # 0 = observed, 1..m = imputed
xyplot(imp, Ozone ~ Wind + Temp + Solar.R, pch = 18, cex = 1)
densityplot(imp)                                    # blue observed, magenta imputed
completed <- complete(imp, 1)
fit <- with(imp, lm(Ozone ~ Temp + Wind)); summary(pool(fit))
```

- `m` = number of imputed datasets (captures uncertainty).
- `maxit` = iterations of the chained equations per dataset (convergence).
- `pmm` only imputes values that were actually observed (plausible).
- Good imputations: magenta inside the blue range with a similar shape.

---

## 13. Inference: hypothesis tests

**Core logic:** assume H0, compute a statistic with known distribution under H0, reject if the observed value is too extreme.

| Decision \ Truth | H0 true | H1 true |
|---|---|---|
| keep H0 | correct (1 - α) | Type II (β) |
| reject H0 | Type I (α) | correct: power (1 - β) |

- p-value = P(result at least this extreme | H0). Reject if p ≤ α.
- Not rejecting H0 does NOT prove H0.
- p-value is not P(H0 true) and not effect size: report CIs.
- Lower α means larger β unless n increases. Multiple tests inflate false positives: `p.adjust(p, "BH")`.

**Test-building checklist:** 1) H0/H1, 2) statistic, 3) α and critical region, 4) power, 5) compute statistic, 6) decide.

### Power and sample size (power.t.test)

**Why:** plan n so a real effect has a good chance of being detected. Leave out exactly the one argument you want computed.

```r
# n per group to detect delta = 1 g, sd = 1.7, alpha = 5%, power = 80%
power.t.test(delta = 1, sd = 1.7, sig.level = 0.05, power = 0.8)   # n ~ 46.3 -> 47 per group
ceiling(power.t.test(delta = 1, sd = 1.7, power = 0.8)$n)

# n vs risk level alpha
alphas <- c(0.10, 0.05, 0.025, 0.01, 0.001)
n <- sapply(alphas, function(a) ceiling(power.t.test(delta = 1, sd = 1.7, sig.level = a, power = .8)$n))
data.frame(alpha = alphas, n_per_group = n); plot(alphas, n, type = "b", log = "x")
# smaller alpha -> larger n

power.t.test(n = 20, delta = 1, sd = 1.7)$power          # power with 20 per group
power.t.test(n = 20, sd = 1.7, power = 0.8)$delta        # detectable difference with 20
```

`type = "two.sample"` (default, n per group), `"one.sample"`, `"paired"`; `alternative = "one.sided"`.

### Maximum likelihood (normal)

MLE: mu_hat = mean(x); sigma2_hat = (1/n) * sum((x - mean)^2) (divides by **n**; `var()` divides by n - 1).

```r
mu_hat <- mean(fat); s2_hat <- mean((fat - mu_hat)^2); s_hat <- sqrt(s2_hat)
MASS::fitdistr(fat, "normal")                              # same, with SEs
nll <- function(p) if (p[2] <= 0) Inf else -sum(dnorm(fat, p[1], p[2], log = TRUE))
optim(c(mean(fat), sd(fat)), nll)$par                      # numerical check

hist(fat, freq = FALSE, main = "Fat, US burgers", xlab = "Fat (g)")
curve(dnorm(x, mu_hat, s_hat), add = TRUE, col = "red", lwd = 2)
```

### Normality: Shapiro-Wilk

H0: data are normal. p > 0.05 means no evidence against normality ("consistent with", not "proven"). Pair with a Q-Q plot.

```r
shapiro.test(fat); qqnorm(fat); qqline(fat, col = "red")
```

### t-tests (means)

```r
wrap <- mc |> filter(Type == "Wrap") |> pull(Proteines.g)
t.test(wrap, mu = 26)                                      # one-sample, H0: mu = 26
t.test(wrap, mu = 26, alternative = "greater")
t.test(us, fr)                                             # Welch two-sample (default)
t.test(us, fr, var.equal = TRUE)                           # Student (equal variances)
t.test(y ~ group, data = d)                                # formula, 2 groups
t.test(after, before, paired = TRUE)
wilcox.test(x, mu = 26)                                    # non-parametric fallback
```

Read: t, df, p-value, 95% CI (does it contain mu0?), sample mean.

### F-test (Fisher-Snedecor): compare variances

F = s1² / s2² ~ F(n1 - 1, n2 - 1). H0: equal variances. Sensitive to non-normality.

```r
var.test(us_sug, fr_sug)                                   # then choose t.test var.equal
var.test(Sucres.g ~ Pays, data = burgers)
bartlett.test(y ~ g, data = d); fligner.test(y ~ g, data = d)   # alternatives
```

**Workflow for Q7:** `shapiro.test` each group, then `var.test`, then `t.test(..., var.equal = <result>)`.

### Other tests

```r
prop.test(x = 90, n = 200, p = 0.5, correct = FALSE)       # proportion (45% of 200 vs 50%: p ~ 0.16)
binom.test(90, 200, p = 0.5)                               # exact
chisq.test(table(d$a, d$b))                                # independence
cor.test(x, y)                                             # correlation significance
z <- (mean(x) - mu0) / (sigma / sqrt(n)); 2 * pnorm(-abs(z))   # z-test, known sigma
chi <- (n - 1) * var(x) / s0^2                             # variance test ~ chi2(n-1)
```

### Write-up template

> "H0: ... vs H1: ... . The [test] gives statistic = ..., df = ..., p = ... . At α = 5%, we [reject / do not reject] H0. The 95% CI is [...], so [interpretation in context]."

---

## 14. McDonald's lab quick path

```r
mc <- read.csv("mcdo.csv"); str(mc); summary(mc); table(mc$Type, mc$Pays)
num <- c("Proteines.g","Energie.kcal","Sucres.g","MatGras.g","SatMatGras.g","Masse.g")
mc[num] <- lapply(mc[num], function(x) as.numeric(as.character(x)))   # fixes "." values

# Healthiest type: nutrients per 100 g
mc |> group_by(Type) |>
  summarise(across(c(Proteines.g, Sucres.g, MatGras.g, SatMatGras.g),
                   \(v) mean(100 * v / Masse.g, na.rm = TRUE)),
            kcal_100g = mean(100 * Energie.kcal / Masse.g, na.rm = TRUE), n = n())

us_fat <- mc |> filter(Type == "Burger", Pays == "US") |> pull(MatGras.g) |> na.omit()
burg   <- mc |> filter(Type == "Burger")          # adapt filter for "sandwiches" if needed
boxplot(Sucres.g ~ Pays, data = mc, ylab = "Sugar (g)")
boxplot(Energie.kcal ~ Pays, data = mc, ylab = "Energy (kcal)")
var.test(Sucres.g ~ Pays, data = mc); t.test(Sucres.g ~ Pays, data = mc)
```

Column names (French): `MatGras` = total fat, `SatMatGras` = saturated fat (subset of fat), `Sucres` = sugars, `Proteines` = protein, `Energie` = kcal, `Masse` = mass.

---

## 15. Scaling

**Why:** puts variables in different units on a common scale (needed for PCA, clustering, distances).

```r
as.numeric(scale(x))                          # z-score: mean 0, sd 1
df[cols] <- scale(df[cols])
(x - min(x)) / (max(x) - min(x))              # min-max [0,1]
(x - median(x)) / IQR(x)                      # robust
```

---

## 16. PCA

**What:** finds orthogonal directions (principal components) of maximum variance; each PC is a weighted combination of variables. **Why:** summarises many correlated variables in 2-3 axes, reveals structure, groups of individuals, and correlated variables.

**Key vocabulary**
- **Eigenvalue:** variance carried by an axis. % inertia = eigenvalue / total.
- **How many axes:** elbow in scree plot; Kaiser rule eigenvalue > 1 (scaled PCA); enough cumulative % (e.g., > 80%).
- **Loadings / variable coordinates:** correlation of a variable with an axis (scaled PCA). Used to name the axis.
- **Correlation circle:** arrows close together = correlated; opposite = negatively correlated; at 90° = uncorrelated; long arrow (near circle) = well represented.
- **Contribution (ind/var):** how much a point builds the axis (%). Average = 100/n. Above average = important.
- **cos²:** quality of representation of a point on an axis (0-1).
- **Supplementary (illustrative) variables/individuals:** projected afterwards, do NOT influence the axes. Used to interpret.

### Base R (prcomp)

```r
X <- villes[, 1:12]; X[] <- lapply(X, as.numeric)    # keeps rownames (city names)
pca <- prcomp(X, scale. = TRUE)
summary(pca)                                          # % variance explained
eig <- pca$sdev^2; round(100 * eig / sum(eig), 1)
pca$rotation[, 1:2]                                   # loadings (signs are arbitrary)
pca$x[, 1:2]                                          # individual coordinates (scores)
biplot(pca, scale = 0, cex = .6)
cor(pca$x[, 1:2], villes[, c("Lati","Long")])        # link PCs to other variables
```

### FactoMineR (recommended for the lab)

```r
library(FactoMineR); library(factoextra)

# Villes: 12 active monthly temperatures, last 4 supplementary
villes <- read.table("villes.txt", header = TRUE, row.names = 1)
summary(villes); round(cor(villes[, 1:12]), 2)        # descriptive stats + correlations
res <- PCA(villes, scale.unit = TRUE, quanti.sup = 13:16, graph = FALSE)

# Decathlon: 10 events active, rank & points (11:12) quantitative sup, competition (13) qualitative sup
data(decathlon, package = "FactoMineR")
res_d <- PCA(decathlon, scale.unit = TRUE, quanti.sup = 11:12, quali.sup = 13, graph = FALSE)
```

### Extracting results

```r
res$eig                          # eigenvalues, % variance, cumulative %
res$var$coord[, 1:2]             # variable coordinates = correlations with axes
res$var$cos2; res$var$contrib    # quality / contribution of variables
res$ind$coord[, 1:2]             # individual coordinates
res$ind$contrib[, 1]             # contributions to axis 1
sort(res$ind$contrib[, 1], decreasing = TRUE)[1:5]     # top contributors axis 1
res$ind$coord[names(sort(res$ind$contrib[, 1], decreasing = TRUE))[1:3], 1:2]  # their coords
res$ind$cos2
res$quanti.sup$coord             # supplementary variables on axes
res$quali.sup$coord              # category centroids (decathlon competitions)
dimdesc(res, axes = 1:2)         # variables significantly correlated with each axis
```

### Plots (factoextra)

```r
fviz_eig(res, addlabels = TRUE)                                     # scree plot
fviz_pca_var(res, col.var = "contrib", repel = TRUE)                # correlation circle
fviz_pca_ind(res, col.ind = "cos2", repel = TRUE)                   # individuals
fviz_contrib(res, choice = "ind", axes = 1)                         # contributions axis 1
fviz_contrib(res, choice = "var", axes = 2)
fviz_pca_biplot(res, repel = TRUE, labelsize = 3)
fviz_pca_ind(res_d, habillage = 13, addEllipses = TRUE, repel = TRUE)   # colour by competition
fviz_pca_ind(res, axes = c(1, 2), select.ind = list(contrib = 5))   # top 5 only
```

Labels missing? Point labels come from **row names**: `rownames(X) <- villes[, 1]` before fitting.

### Interpretation templates

- **Villes (temperatures):** PC1 usually has all months loading with the same sign, so it is an **overall temperature level** axis (warm south vs cold north), correlated with latitude. PC2 contrasts summer vs winter months, so it is a **thermal amplitude** axis (oceanic west, e.g., Brest, vs continental east, e.g., Strasbourg), correlated with longitude / amplitude. Typology: quadrants of the individuals map (warm-oceanic, warm-continental, cold-oceanic, cold-continental).
- **Decathlon:** PC1 often opposes running times (100m, 400m, 110m hurdles: lower is better) to jumps/points, so it is an **overall performance** axis correlated with Points (and negatively with Rank). PC2 often captures **endurance vs power/throwing** (1500m vs shot put/discus).
- Write-up: "Axes 1 and 2 explain X% and Y% of inertia (Z% cumulative). Axis 1 is correlated with ... and opposes ... to ... . Cities A, B contribute most to axis 1 (coords ...). The supplementary variable ... is well correlated with axis 1 (r = ...), confirming ... ."

---

## 17. Troubleshooting

| Error / symptom | Cause | Fix |
|---|---|---|
| `unused arguments` in `select()` | MASS masks dplyr | `dplyr::select()` |
| `non-numeric argument to binary operator` | column is character | `as.numeric(as.character(x))` |
| `'x' must be numeric` (prcomp/colMeans) | text column or list input | numeric columns only; `df[] <- lapply(...)` |
| `dim(X) must have a positive length` | `apply()` on a vector | use `sapply()` or a df/matrix |
| boxplot `'names' attribute [2] must be...` | first arg is a data frame | use `pull()` vectors |
| `slice_head()` returns too many rows | data still grouped / `n` unnamed | `ungroup()`, `n = 5` |
| `mean()` returns NA | NAs present | `na.rm = TRUE` |
| factor to number gives 1,2,3 | internal codes | `as.numeric(as.character(f))` |
| `there is no package called 'x'` | not installed | `install.packages("x")` |
| compile fails, missing `.h` (Fedora) | system lib missing | `sudo dnf install <lib>-devel` (e.g., `nlopt-devel`, `libuv-devel`) |
