# -*- coding: utf-8 -*-
"""
Created on Sat May 18 17:38:14 2019

@author: Jeremy Yeaton
"""

import os, csv
#%%
os.chdir('C:\\Users\\jdyea\\OneDrive\\MoDyCo\\_pilotSWOP')
#% Process Stroop and Navon
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
					glob, loc = 0,0
					entry = line
					if line[7] == line[8]:
						entry.append('1')
					else:
						entry.append('0')
					if entry[9] == 'None':
						entry[9] = ''
					if entry[4] in entry[6]:
						glob = 1
					if entry[5] in entry[6]:
						loc = 1
					if glob and loc:
						entry.append('GL')
					elif glob:
						entry.append('G')
					elif loc:
						entry.append('L')
					else:
						entry.append('')
					# Establish hits, misses, FA, and CR
					if entry[1] == 'gbLc':
						if entry[11] != '' and entry[10] == '1':
							entry.append('H')
						elif entry[11] != '' and entry[10] == '0':
							entry.append('M')
						elif entry[11] == '' and entry[10] == '0':
							entry.append('FA')
						else:
							entry.append('CR')
					elif entry[1] == 'glob':
						if entry[11] in ['G','GL'] and entry[10] == '1':
							entry.append('H')
						elif entry[11] in ['G','GL'] and entry[10] == '0':
							entry.append('M')
						elif entry[11] in ['','L'] and entry[10] == '0':
							entry.append('FA')
						else:
							entry.append('CR')
					elif entry[1] == 'loca':
						if entry[11] in ['L','GL'] and entry[10] == '1':
							entry.append('H')
						elif entry[11] in ['L','GL'] and entry[10] == '0':
							entry.append('M')
						elif entry[11] in ['','G'] and entry[10] == '0':
							entry.append('FA')
						else:
							entry.append('CR')
					entry.append('1')
					navon.append(entry)
			f.close()
		elif file.endswith('.xpd') and file[:6] == 'stroop':
			f = open(os.path.join(rawDir,sub,file), 'r')
			g = csv.reader(f,delimiter = ',')
			for line in g:
				if not line[0][0] == '#':
					entry = line
					if line[6] == line[7]:
						entry.append('1')
					else:
						entry.append('0')
					if entry[8] == 'None':
						entry[8] = ''
					stroop.append(entry)
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
				

#%%
os.chdir('C:\\Users\\jdyea\\OneDrive\\MoDyCo\\_pilotSWOP\\swopEEGpipeline\\EFdata')


stroop = cleanSet(stroop)
navon = cleanSet(navon)

fileName = 'stroopAll.csv'
f = open(fileName,'w')
stroop[0][-1] = 'acc'
for line in stroop:
	f.write(''.join([','.join(line),'\n']))
f.close()

fileName = 'navonAll.csv'
f = open(fileName,'w')
navon[0][-3:] = 'acc','cond','hitMiss','ct'
for line in navon:
	f.write(''.join([','.join(line),'\n']))
f.close()

fileName = 'ajt_pilot.txt'
f = open(fileName,'w')
for line in ajt:
	f.write(''.join([','.join(line),'\n']))
f.close()

#%% Process Swedex, SCT, and Oxford
results = [['subject_id','task','score']]


subNums = [sub[2:5] for sub in subs]
tasks = ['swedex','sct','oxford','ajt','stroop','navon']
for task in tasks[:3]:
	f = open(''.join([task,'_pilot.txt']),'r')
	g = csv.reader(f,delimiter = '\t')
	readout = []
	key = []
	for line in g:
		readout.append(line)
	for line in readout:
		if line[9] == '999':
			key = line
		elif line[9] == '998':
			key1 = line
	correct = 0
	for line in readout:
		if line[9] in subNums:
			correct = 0
			correct1 = 0
			for Idx, rep in enumerate(line[10:]):
				if line[Idx] == key[Idx]:
					correct += 1
				elif task == 'swedex' and line[Idx] == key1[Idx]:
					correct += 1
			entry = [[],[],[]]
			if task == 'swedex':
				mult = 10
			else:
				mult = 1
			entry = [line[9],task,str(round(correct/len(line[10:]),5)*mult)]
			results.append(entry)
for sub in subNums:
	can,vio = 0,0
	for line in ajt:
		if line[0] == sub:
			if line[1] == '1':
				vio += int(line[2])
			elif line[1] == '2':
				can += int(line[2])
	results.append([sub,'ajt_vio',str(vio)])
	results.append([sub,'ajt_can',str(can)])
	

f = open('resultsBeh.csv','w')
for line in results:
	f.write(''.join([','.join(line),'\n']))
f.close()