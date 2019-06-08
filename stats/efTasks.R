## Load in Libraries
library(dplyr)
library(tidyr)
library(neuropsychology)
library(ggplot2)

## Read in Data ####
dataStroop = read.table(file = '..\\EFdata\\stroopAll.csv', header = TRUE, sep = ',') %>%
  select(subject_id,Block,Type,RT,acc)%>%
  filter(Block == 2 | Block == 3) %>%
  group_by(subject_id,Type) %>%
  summarise(acc = mean(acc),RT = mean(RT, na.rm = TRUE))
  
S = dataStroop 
  
t.test(S$RT[S$Type == 'incong' & S$subject_id == 101],S$RT[S$Type == 'cong' & S$subject_id == 101])
t.test(S$RT[S$Type == 'incong' & S$subject_id == 102],S$RT[S$Type == 'cong' & S$subject_id == 102])
t.test(S$RT[S$Type == 'incong' & S$subject_id == 104],S$RT[S$Type == 'cong' & S$subject_id == 104])

dataNavon = read.table(file = '..\\EFdata\\navonAll.csv', header = TRUE, sep = ',') 

N = dataNavon
t.test(N$RT[N$cond == 'G' & N$hitMiss == 'H' & N$subject_id == 101],N$RT[N$cond == 'L' & N$hitMiss == 'H' & N$subject_id == 101])
t.test(N$RT[N$cond == 'G' & N$hitMiss == 'H' & N$subject_id == 102],N$RT[N$cond == 'L' & N$hitMiss == 'H' & N$subject_id == 102])
t.test(N$RT[N$cond == 'G' & N$hitMiss == 'H' & N$subject_id == 104],N$RT[N$cond == 'L' & N$hitMiss == 'H' & N$subject_id == 104])
t.test(N$RT[N$cond == 'G' & N$hitMiss == 'H' & N$subject_id != 103],N$RT[N$cond == 'L' & N$hitMiss == 'H' & N$subject_id != 103])



dataBeh = read.table(file = '..\\EFdata\\resultsBeh.csv', header = TRUE, sep = ',') %>%
  spread(task,score) %>%
  mutate(ajt_dprime = dprime(ajt_can, 240-ajt_can, 240-ajt_vio, ajt_vio)$dprime) %>%
  select(subject_id, oxford, sct, swedex, ajt_dprime)

## Summarize into tables ####
# Navon 
navonAcc <- dataNavon %>%
  filter(Block != 'gbLc') %>%
  select(subject_id, Block, cond, RT, acc, hitMiss, ct) %>%
  group_by(subject_id,Block,hitMiss) %>%
  summarise(RT = mean(RT, na.rm = TRUE), ct = sum(ct)) %>%
  select(subject_id,Block,hitMiss,ct) %>%
  spread(hitMiss, ct)
navonAcc[is.na(navonAcc)] <- 0 
navonAcc <- navonAcc %>%
  mutate(nv_dprime = dprime(H,M,FA,CR)$dprime) %>%
  select(subject_id,Block,nv_dprime) %>%
  spread(Block,nv_dprime) %>%
  rename(glob_dprime = glob,
    loc_dprime = loca)


navonRT <- dataNavon %>%
  filter(cond != 'GL') %>%
  select(subject_id, Block, cond, RT, acc, hitMiss, ct) %>%
  group_by(subject_id,cond,hitMiss) %>%
  filter(hitMiss == 'H') %>% 
  group_by(subject_id,cond) %>%
  summarise(hitRT = mean(RT)) %>%
  spread(cond,hitRT) %>%
  rename(glob_hitrt = G,
         loc_hitrt = L) %>%
  mutate(diff_hitrt = loc_hitrt - glob_hitrt)
  
# Stroop
stroopAcc <- dataStroop %>%
  select(subject_id,Type,acc) %>%
  mutate(meanAcc = mean(acc)) %>%
  spread(Type,acc) %>%
  mutate(accFacilCong = (cong-neut),
         accCostIncong = (incong-neut)) %>%
  select(subject_id,accFacilCong,accCostIncong)

stroopRT <- dataStroop %>%
  select(subject_id,Type,RT) %>%
  mutate(meanRT = mean(RT)) %>%
  spread(Type,RT) %>%
  mutate(rtFacilCong = (neut-cong),
         rtCostIncong = (neut-incong),
         rtDiff = incong-cong) %>%
  select(subject_id,rtFacilCong,rtCostIncong,rtDiff)

# Create DF
df <- dataBeh %>%
  merge(navonAcc,by = 'subject_id') %>%
  merge(navonRT,by = 'subject_id') %>%
  merge(stroopAcc,by = 'subject_id') %>%
  merge(stroopRT,by = 'subject_id')

write.csv(df,file = "..\\offlineMeasures.csv")

## Plot stuff ####
ggplot(stroopRT,aes(color = asfactor(subject_id))) +
  geom_point(aes(x=facil,y=cost,color = meanRT))

  