library(FactoMineR)
library(dplyr)
library(factoextra)

data(decathlon)

df <- decathlon

df_cont <- df |> dplyr::select(-one_of(c("Competition", "Rank")))

df_cont_scaled <- scale(df_cont)

pca <- prcomp(df_cont, scale. = TRUE)

summary(pca)

# 5-6 seems like a good spot - with 83/88 percent coverage

fviz_pca_var(pca, repel = TRUE)


## Villes dataset
villes <- read.csv2("./villes.txt", sep = ';')

# First 12 cols
villes_cont <- villes[, 1:12]
villes_cont <- as.data.frame(lapply(villes_cont, as.numeric))

villes_cont_pca <- prcomp(villes_cont, scale. = TRUE)

rownames(villes_cont_pca$x) <- rownames(villes)

fviz_pca_var(villes_cont_pca, repel = TRUE)
fviz_eig(villes_cont_pca, addlabels = TRUE) 
fviz_pca_biplot(villes_cont_pca, repel = TRUE, labelsize = 3)

# Just 2 PCs represent 98 percent of the variance
# First axis - 79.8 %
# Second axis - 19 %

# Does the angle of months in same direction represent that one month being hotter
# means other months are a bit hotter too? All have positive correlation okay

cor(villes_cont)

# All months have positive correlation, but months closer to each other have higher
# correlation than lets say july with december


unique(villes$Region)
# There are 4 distinct regions for the cities
# from the plot we can also see 4 kinda clusters well not really
# But this might suggest that the 2 PCs might just be lat and long


# Lets check how much correlation exists between lat lon and PC1 and PC2

pcs <- villes_cont_pca$x[, 1:2]


villes$Lati <- as.numeric(as.character(villes$Lati))
villes$Long <- as.numeric(as.character(villes$Long))
cor(pcs, villes[, c("Lati", "Long")])

#         Lati       Long
# PC1  0.8389348 -0.1714839
# PC2 -0.3064996  0.7922192

# Wohooo, lat is highly correlated with pc1 and long with pc2 and weak to none 
# for the other



