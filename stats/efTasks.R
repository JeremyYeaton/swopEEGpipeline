## Load in Libraries
library(dplyr)
library(ggplot2)

## Read in Data
dataStroop = read.table(file = '..\\EFdata\\stroopAll.csv', header = TRUE, sep = ',')

dataNavon = read.table(file = '..\\EFdata\\navonAll.csv', header = TRUE, sep = ',')

## Clean the data
dataStr <- dataStr %>%
  group_by(Type) %>%
  filter(Block < 4)