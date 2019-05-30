## Load in Libraries
library(dplyr)
library(tidyr)
library(neuropsychology)
library(ggplot2)

## Read in Data
dataStroop = read.table(file = '..\\EFdata\\stroopAll.csv', header = TRUE, sep = ',')

dataNavon = read.table(file = '..\\EFdata\\navonAll.csv', header = TRUE, sep = ',')

dataBeh = read.table(file = '..\\EFdata\\resultsBeh.csv', header = TRUE, sep = ',') %>%
  spread(task,score) %>%
  mutate(ajt_dprime = dprime(can, 240-can, 240-vio, vio)$dprime)



## Summarize into tbbles
stroopSum <- dataStroop %>%
  filter(Block == 2) %>%
  group_by(subject_id,Type) %>%
  summarise(acc = mean(acc),RT = mean(RT, na.rm = TRUE))

navonSum <- dataNavon %>%
  group_by(subject_id,cond,Block) %>%
  summarise(acc = mean(acc),RT = mean(RT, na.rm = TRUE))

stroopAcc <- stroopSum %>%
  select(subject_id,Type,acc) %>%
  mutate(meanAcc = mean(acc)) %>%
  spread(Type,acc) %>%
  mutate(CongMu = (cong-meanAcc),
         IncongMu = (incong-meanAcc),
         neutMu=(neut-meanAcc))

stroopRT <- stroopSum %>%
  select(subject_id,Type,RT) %>%
  mutate(meanRT = mean(RT)) %>%
  spread(Type,RT) %>%
  mutate(CongMu = (cong-meanRT),
         IncongMu = (incong-meanRT),
         NeutMu=(neut-meanRT))