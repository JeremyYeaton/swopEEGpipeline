# -*- coding: utf-8 -*-
"""
Created on Sat May 18 17:38:14 2019

@author: Jeremy Yeaton
"""

import os, csv
os.chdir('C:\\Users\\jdyea\\OneDrive\\MoDyCo\\_pilotSWOP')
#%% Process Stroop and Navon
rawDir = os.path.join(os.getcwd(),'raw_data')
subs = ['f_101mc','f_102bg','f_103tn','f_104sb']
stroop = []
navon = []
ajt = [['subject_id','condition','acc']]
to_pop = []

def cleanSet(results):
	to_pop = []
	for Idx, line in enumerate(results):
		if Idx != 0 and line[0] == 'subject_id':
			to_pop.append(Idx)
		elif line[1].endswith('Practice'):
			to_pop.append(Idx)
	to_pop.sort(reverse = True)
	for i in to_pop:
		results.pop(i)
	return results


for sub in subs:
	for r,d,f in os.walk(os.path.join(rawDir,sub)):
		files = f
		del r,d
	for file in files:
		if file.endswith('.xpd') and file[:5] == 'navon':
			f = open(os.path.join(rawDir,sub,file), 'r')
			g = csv.reader(f,delimiter = ',')
			for line in g:					
				if not line[0][0] == '#':
					navon.append(line)
			f.close()
		elif file.endswith('.xpd') and file[:6] == 'stroop':
			f = open(os.path.join(rawDir,sub,file), 'r')
			g = csv.reader(f,delimiter = ',')
			for line in g:
				if not line[0][0] == '#':
					stroop.append(line)
			f.close()
		elif file.endswith('-1.txt'):
			rawData = []
			responses = []
			f = open(os.path.join(rawDir,sub,file), 'r')
			g = csv.reader(f,delimiter = '\t')
			for row in csv.reader((line.replace('\0','') for line in f), delimiter="\t"):
				rawData.append(row)
			for line in rawData:
				if len(line) > 2:
					if line[2][:19] == 'questiondisplay.ACC':
						responses.append(line)
					elif line[2][:9] == 'Condition':
						responses.append(line)
			del rawData
			vio, can = 0,0
			for Idx,line in enumerate(responses):
				entry = [[],[],[]]
				if line[2][0] == 'C':
					entry[0] = sub[2:5]
					entry[1] = line[2][-1]
					entry[2] = responses[Idx + 1][2][-1]
					ajt.append(entry)
#				if line[2][0] == 'C' and line[2][-1] == '1':
#					vio += int(responses[Idx + 1][2][-1])
#				elif line[2][0] == 'C' and line[2][-1] == '2':
#					can += int(responses[Idx + 1][2][-1])
				

#%%
os.chdir('C:\\Users\\jdyea\\OneDrive\\MoDyCo\\_pilotSWOP\\swopEEGpipeline\\EFdata')


stroop = cleanSet(stroop)
navon = cleanSet(navon)

fileName = 'stroopAll.csv'
f = open(fileName,'w')
for line in stroop:
	f.write(''.join([','.join(line),'\n']))
f.close()
fileName = 'navonAll.csv'
f = open(fileName,'w')
for line in navon:
	f.write(''.join([','.join(line),'\n']))
f.close()

fileName = 'ajtAll.csv'
f = open(fileName,'w')
for line in ajt:
	f.write(''.join([','.join(line),'\n']))
f.close()

#%% Process Swedex, SCT, and Oxford

subNums = [sub[2:5] for sub in subs]
tasks = ['swedex','sct','oxford']
for task in tasks:
	f = open(''.join([task,'_pilot.txt']),'r')
	g = csv.reader(f,delimiter = '\t')
	readout = []
	key = []
	for line in g:
		readout.append(line)
	for line in readout:
		if line[9] == '999':
			key = line
	correct = 0
	for line in readout:
		if line[9] in subNums:
			correct = 0
			print(line[9])
			for Idx, rep in enumerate(line[10:]):
				if line[Idx] == key[Idx]:
					correct += 1
			print(correct/len(line))













