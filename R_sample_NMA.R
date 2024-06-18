# Load packages and data
library(netmeta)
library(readxl)
library(dplyr)
data<-read_excel("C:/Users/Chronic_Migraine_Dataset.xlsx")

data2 <- data[data$trt != "Placebo", ]
data2$trt2 <- "Placebo"


# Calculate relative mean difference (y) between Galcanezumab and Eptinezumab in Crisp
rel_mean_diff_Galc <- -4.2
rel_mean_diff_Epti <- -4.9

rel_mean_diff_combined <- rel_mean_diff_Galc - rel_mean_diff_Epti

# Print the results
cat("Relative mean difference between Galcanezumab and Eptinezumab:", rel_mean_diff_combined, "\n")
## Relative mean difference between Galcanezumab and Eptinezumab: 0.7 

new_row <- c(y = 0.7, se = NA, trt = "Galcanezumab ", study = "Crisp", year = "2012", na = "3", trt2 = "Eptinezumab")

# Add the new row to the dataframe using rbind
data2 <- rbind(data2, new_row)

# Change to numeric
data2$y <- as.numeric(as.character(data2$y))
data2$se <- as.numeric(as.character(data2$se))
data2$na <- as.numeric(as.character(data2$na))

# Calculate the mean of non-missing seTE values
mean_se <- mean(data2$se, na.rm = TRUE)

# Replace NA values in seTE with the calculated mean
data2 <- data2 %>%
  mutate(se = ifelse(is.na(se), mean_se, se))

# Conduct network meta-analysis
nm <- netmeta(
  TE = y,
  seTE = se,   
  treat1 = trt,
  treat2 = trt2,
  studlab = study,
  data = data2,
  reference="Galcanezumab",
  sm = "MD",         # Summary measure (Mean Difference)
  fixed = TRUE,
  random = FALSE
)

# Print the summary
summary(nm)

# Plot netgraph
netgraph(nm,
         start ="circle", 
         cex = 1, 
         col = "#5C8286", 
         plastic = F, 
         points = TRUE, 
         col.points = "#BFBFBF",
         cex.points = 2,
         thickness = "number.of.studies")

# Plot forest graph
forest(nm,
       reference.group = "Galcanezumab",
       smlab = paste("Galcanezumab versus Others"),
       drop.reference.group = TRUE,
       col.square = "#5C8286",
       sortvar = TE,
       label.left = "Favors the other",
       label.right = "Favors Galcanezumab"
       )

# Ranking
netrank(nm, small.values = "good")

# Pairwise Comparison Table
netleague <- netleague(nm, 
                       bracket = "(", 
                       digits=2)  
netleague

write.csv(netleague$common, "C:/Users/netleague.csv")

