library(ggplot2)
library(dplyr) 
data(mtcars)
data(mpg)
data(iris)

# 1.1 Plotting wt vs mpg for mtmcars dataset
wt_mpg_plot <- ggplot(mtcars, aes(x = wt, y = mpg, colour = factor(cyl)))
wt_mpg_plot <- wt_mpg_plot + geom_point(size = 3)
wt_mpg_plot <- wt_mpg_plot + labs(title = "Mileage vs Weight for Cylinder Count",
                    x = "Weight (in tonnes)",
                    y = "Mileage (int mpg)")
wt_mpg_plot


# 1.3 Plotting mpg vs wt with smooth curve
wt_mpg_plot_with_line <- ggplot(mtcars, aes(x = wt, y = mpg))
wt_mpg_plot_with_line <- wt_mpg_plot_with_line + geom_point(size = 2)
wt_mpg_plot_with_line <- wt_mpg_plot_with_line + 
                          labs(title = "Mileage vs Weight for Cylinder Count",
                                  x = "Weight (in tonnes)",
                                  y = "Mileage (int mpg)")
wt_mpg_plot_with_line <- wt_mpg_plot_with_line + stat_smooth(se = TRUE)
wt_mpg_plot_with_line <- wt_mpg_plot_with_line + 
                          stat_smooth(method = "lm", se = FALSE, linetype = "dashed")
wt_mpg_plot_with_line



# 1.4 Bar plots for mpg
car_class_count <- ggplot(mpg, aes(y = class))
car_class_count <- car_class_count + aes(fill = factor(drv))
#car_class_count <- car_class_count + geom_bar()
car_class_count <- car_class_count + labs(
  title = "Proportions of Car by Drivetrain by Class", 
  x = "Proportions")
car_class_count <- car_class_count + geom_bar(position = "fill")
car_class_count


# 1.5 Histogram and Densities
sepal_length_histo <- ggplot(iris, aes(Sepal.Length, fill = Species))
sepal_length_histo <- sepal_length_histo + geom_histogram(binwidth = 0.1)
sepal_length_histo <- sepal_length_histo + labs(
  title = "Sepal length count for different Species",
  y = "Total Count of Plants",
  x = "Sepal Length") + scale_x_continuous(breaks = seq(3.5, 8, .25))
sepal_length_histo


sepal_length_den <- ggplot(iris, aes(Sepal.Length))
sepal_length_den <- sepal_length_den + geom_density(aes(color = Species))
sepal_length_den


# 1.6 Boxplots and Violins
hwy_class_boxplot <- ggplot(mpg, aes(x = class, y = hwy))
hwy_class_boxplot <- hwy_class_boxplot + geom_boxplot()
hwy_class_boxplot <- hwy_class_boxplot + geom_jitter(width = 0.1)
hwy_class_boxplot

hwy_class_vplot <- ggplot(mpg, aes(x = class, y = hwy))
hwy_class_vplot <- hwy_class_vplot + geom_violin(trim = FALSE)
hwy_class_vplot <- hwy_class_vplot + geom_boxplot(width = 0.2)
hwy_class_vplot


# 1.7 Facet Grid and Wrap
hwy_disp_sct <- ggplot(mpg, aes(x = hwy, y = displ, colour = factor(class)))
hwy_disp_sct <- hwy_disp_sct + geom_point(alpha = 0.5, size = 1)
hwy_disp_sct <- hwy_disp_sct + facet_wrap(vars(drv))
hwy_disp_sct

hwy_disp_sct_grid <- ggplot(mpg, aes(x = hwy, y = displ, colour = factor(class)))
hwy_disp_sct_grid <- hwy_disp_sct_grid + geom_point(size = 1)
hwy_disp_sct_grid <- hwy_disp_sct_grid + facet_grid(rows = vars(drv), cols = vars(cyl))
hwy_disp_sct_grid


# 1.8 Scales, labels and themes
hwy_disp_sct_class <- ggplot(mpg, aes(y = hwy, x = displ, colour = factor(class)))
hwy_disp_sct_class <- hwy_disp_sct_class + geom_point()
hwy_disp_sct_class <- hwy_disp_sct_class + scale_color_brewer(palette = "Dark2")
hwy_disp_sct_class <- hwy_disp_sct_class + labs(
  title = "Highway Mileage vs Engine Capacity by Car Class",
  x = "Displacement (in L)",
  y = "Highway Mileage (in mpg)",
  colour = "Car Class")
hwy_disp_sct_class <- hwy_disp_sct_class + theme_minimal() + theme(legend.position = "bottom")
hwy_disp_sct_class


# 1.9 Summaries and Error Bars
summary(mpg[, c("hwy")])
hwy_stats_by_class <- mpg |> 
  group_by(class) |> 
  summarise(mean = mean(hwy), 
            sd = sd(hwy), 
            n = n(), 
            se = sd/sqrt(n),
            ci_95 = 1.96 * sd / sqrt(n)) |>
  ungroup()

mean_hwy_by_class_plot <- ggplot(hwy_stats_by_class, aes(y = reorder(class, -mean), x = mean))
mean_hwy_by_class_plot <- mean_hwy_by_class_plot + geom_col()
mean_hwy_by_class_plot <- mean_hwy_by_class_plot + labs(
  x = "Class (sorted by mean hwy)",
  y = "Mean highway MPG")
mean_hwy_by_class_plot

# 1.10

