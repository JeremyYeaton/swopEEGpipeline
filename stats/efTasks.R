## Load in Libraries
library(dplyr)
library(ggplot2)

## Read in Data
dataStroop = read.table(file = '..\\EFdata\\stroopAll.csv', header = TRUE, sep = ',')

dataNavon = read.table(file = '..\\EFdata\\navonAll.csv', header = TRUE, sep = ',')

dataBeh = read.table(file = '..\\EFdata\\resultsBeh.csv', header = TRUE, sep = ',')

## Clean the data
stroopSum <- dataStroop %>%
  filter(Block == 2) %>%
  group_by(subject_id,Type) %>%
  summarise(acc = mean(acc),RT = mean(RT, na.rm = TRUE))

navonSum <- dataNavon %>%
  group_by(subject_id,cond,Block) %>%
  summarise(acc = mean(acc),RT = mean(RT, na.rm = TRUE))
