# -*- coding: utf-8 -*-
"""
Created on Sat May 18 17:38:14 2019

@author: Jeremy Yeaton
"""

import os, csv
os.chdir('C:\\Users\\jdyea\\OneDrive\\MoDyCo\\_pilotSWOP')
#%%
rawDir = os.path.join(os.getcwd(),'raw_data')
subs = ['f_101mc','f_102bg']
stroop = []
navon = []
ajt = []
to_pop = []


for sub in subs:
	for r,d,f in os.walk(os.path.join(rawDir,sub)):
		files = f
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
#		elif file.endswith('-1.txt'):
#			f = open(os.path.join(rawDir,sub,file), 'r')
#			g = csv.reader(f,delimiter = '\t')
#			for line in g:
#				print(line)
		elif file == 'Untitled.txt':#file[:4] == 'ajt_' and file.endswith('.csv'):
			f = open(os.path.join(rawDir,sub,file), 'r')
			g = csv.reader(f,delimiter = '\t')
			for Idx, line in enumerate(g):
				if Idx == 0:
					print(line)

#%%

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

stroop = cleanSet(stroop)
navon = cleanSet(navon)

fileName = 'swopEEGpipeline\\EFdata\\stroopAll.csv'
f = open(fileName,'w')
for line in stroop:
	f.write(''.join([','.join(line),'\n']))
f.close()
fileName = 'swopEEGpipeline\\EFdata\\navonAll.csv'
f = open(fileName,'w')
for line in navon:
	f.write(''.join([','.join(line),'\n']))
f.close()
