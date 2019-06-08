%% Settings
% Pilot data directory
mainDir             = 'C:\\Users\\jdyea\\OneDrive\\MoDyCo\\_pilotSWOP';
cd(mainDir); addpath('swopEEGpipeline')
load('swopEEGpipeline\\biosemi_neighbours.mat','neighbors');
allElecs = readtable('biosemi64.txt');
elecLayout           = 'biosemi64.lay';
% Directory names
folders             = [];
folders.prep        = 'ft_preprocess';
folders.visRej      = 'ft_visRej';
folders.ica         = 'ft_icaComponents';
folders.rmvArtfct   = 'ft_rmvArtfct';
folders.timelock    = 'ft_timelock';
folders.results     = 'ft_results';

% French sub IDs
frSubs    = {'f_101mc','f_102bg','f_103tn','f_104sb'};
% Swedish sub IDs
swedSubs  = {'s_04nm','s_07ba','s_09lo','s_12wg','s_13ff','s_14mc','s_15rj','s_17oh','s_18ak',...
    's_19am','s_21ma','s_23nj','s_24zk','s_25ks','s_26nm','s_27lm','s_28js','s_29ld','s_30la','s_31bf'};

% Latencies for ERP analysis
lats = {[.3 .5],[.5 .7],[.7 .9],[.9 1]};
mint = [.300,.500,.700,.900];
maxt = [.500,.700,.900,1];

% Electrode subsets
elecs = [];
elecs.exclude = {'Fz','Cz','Pz','Fp1','Fp2'};
elecs.left = {'F7','F3','FT7','FC3','T7','C3','TP7','CP3','P7','P3','PO7','O1'};
elecs.right = {'F8','F4','FT8','FC4','T8','C4','TP8','CP4','P8','P4','PO8','O2'};
elecs.lateral = {'F7','F8','FT7','FT8','T7','T8','TP7','TP8','P7','P8','PO7','PO8'};
elecs.medial = {'FC3','FC4','C3','C4','CP3','CP4','P3','P4','O1','O2'};
elecs.frontal = {'F4','F3','F7','F8'};
elecs.frontotemporal = {'FT7','FT8','FC3','FC4'};
elecs.temporal = {'T7','T8','TP7','TP8'};
elecs.central = {'C3','C4','CP3','CP4'};
elecs.parietal = {'P3','P4','P7','P8'};
elecs.occipital = {'O1','O2','PO7','PO8'};

% Load data
load('ft_results\struc_fr.mat','strucFr')
load('ft_results\struc_sw.mat','strucSw')
load('grandavg_sw.mat','grandavgsw');
load('grandavg_fr.mat','grandavgfr');
load('time.mat','time');
load('64chanlocs.mat');
load('swedChans.mat','swedChans')
offline = readtable('offlineMeasures.csv');