## Load in Libraries
library(dplyr)
library(tidyr)
library(neuropsychology)
library(ggplot2)

## Read in Data
dataStroop = read.table(file = '..\\EFdata\\stroopAll.csv', header = TRUE, sep = ',') %>%
  select(subject_id,Block,Type,RT,acc)

dataNavon = read.table(file = '..\\EFdata\\navonAll.csv', header = TRUE, sep = ',') %>%
  filter(Block != 'gbLc') %>%
  select(subject_id, Block, RT, acc, hitMiss, ct)

dataBeh = read.table(file = '..\\EFdata\\resultsBeh.csv', header = TRUE, sep = ',') %>%
  spread(task,score) %>%
  mutate(ajt_dprime = dprime(ajt_can, 240-ajt_can, 240-ajt_vio, ajt_vio)$dprime) %>%
  select(subject_id, oxford, sct, swedex, ajt_dprime)


## Summarize into tibbles
stroopSum <- dataStroop %>%
  filter(Block == 2) %>%
  group_by(subject_id,Type) %>%
  summarise(acc = mean(acc),RT = mean(RT, na.rm = TRUE))

navonSum <- dataNavon %>%
  group_by(subject_id,Block,hitMiss) %>%
  summarise(RT = mean(RT, na.rm = TRUE), ct = sum(ct)) 

navonAcc <- navonSum %>%
  select(subject_id,Block,hitMiss,ct) %>%
  spread(hitMiss, ct)
  
navonAcc[is.na(navonAcc)] <- 0
navonAcc <- navonAcc %>%
  mutate(nv_dprime = dprime(H,M,FA,CR)$dprime)

stroopAcc <- stroopSum %>%
  select(subject_id,Type,acc) %>%
  mutate(meanAcc = mean(acc)) %>%
  spread(Type,acc) %>%
  mutate(accFacil = (cong-neut),
         accCost = (incong-neut))

stroopRT <- stroopSum %>%
  select(subject_id,Type,RT) %>%
  mutate(meanRT = mean(RT)) %>%
  spread(Type,RT) %>%
  mutate(rtFacil = (cong-neut),
         rtCost = (incong-neut))
## Plot stuff
ggplot(stroopRT,aes(color = asfactor(subject_id))) +
  geom_point(aes(x=facil,y=cost,color = meanRT))

  