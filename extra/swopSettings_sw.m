%% Settings
% Pilot data directory
mainDir             = 'C:\\Users\\jdyea\\OneDrive\\MoDyCo\\_pilotSWOP';
cd(mainDir); addpath('swopEEGpipeline');
% load('swopEEGpipeline\\biosemi_neighbours.mat','neighbors');
load('swopEEGpipeline\\sw_neighbours.mat','neighbors');
% allElecs = readtable('biosemi64.txt');
load('swElectrodeTable.mat','swElecs');
allElecs = swElecs;
% Directory names
folders             = [];
folders.prep        = 'ft_preprocess';
folders.visRej      = 'ft_visRej';
folders.ica         = 'ft_icaComponents';
folders.rmvArtfct   = 'ft_rmvArtfct';
folders.timelock    = 'ft_timelock';

% Preprocessing parameters
preproc             = [];
preproc.lpfilter    = 'yes'; 
preproc.lpfreq      = 40; % Hz
preproc.hpfilter    = 'yes'; 
preproc.hpfreq      = .5; % Hz
preproc.demean      = 'yes';
preproc.reref       = 'yes';
preproc.refchannel  = {'M1' 'M2'};%{'EXG1' 'EXG2'};

% Artifact rejection parameters
eegChannels                  = 3:32;
artfctdef                    = [];
artfctdef.reject             = 'complete';
artfctdef.feedback           = 'no';
artfctdef.eog.channel        = {'HEOG','VEOG'};
artfctdef.zvalue.cutoff      = 4;
artfctdef.zvalue.channel     = eegChannels;
artfctdef.zvalue.demean      = 'yes';
artfctdef.jump.channel       = eegChannels;
artfctdef.threshold.channel  = eegChannels;
artfctdef.threshold.range    = 1500;

% Trial types (trigger labels)
trials              = [];
trials.can          = [212,214,222,224,231,232,233,234,241,242,243,244]; % canonical
trials.vio          = [112,114,122,124,131,132,133,134,141,142,143,144]; % violation
% Trial definition parameters
trialdef            = [];
trialdef.eventtype  = 'trigger';
trialdef.eventvalue = [trials.can trials.vio];
trialdef.prestim    = .1;
trialdef.poststim   = 1;

% French pilot - native swedish sub IDs
pilotSubs = {'s_500mk','s_501ml'};
frSubs    = {'f_101mc','f_102bg','f_103tn','f_104sb'};

% Swedish sub IDs
swedSubs  = {'s_04nm','s_07ba','s_09lo','s_12wg','s_13ff','s_14mc','s_15rj','s_17oh','s_18ak',...
    's_19am','s_21ma','s_23nj','s_24zk','s_25ks','s_26nm','s_27lm','s_28js','s_29ld','s_30la','s_31bf'};
% Initialize cfg
cfg          = [];
cfg.method   = 'template';
cfg.feedback = 'no';

% Parameters by location
if strcmp(origin,'fr')
    % MoDyCo data settings
%     elecLayout           = 'biosemi64.lay';
    elecLayout           = 'biosemi64.lay';
    folders.eeglabTag    = 'eeglabSet';
%     subs                 = pilotSubs;
    subs                 = frSubs;
elseif strcmp(origin,'sw') == 1
    % Humlab data settings
%     elecLayout           = 'swLayout.lay';
%     elecLayout           = 'easycapM22.mat';
    elecLayout           = 'swedishLayout.mat';
%     elecLayout           = 'biosemi64.lay';
    folders.eeglabTag    = 'bandpass_05to100';
    subs                 = swedSubs;
%     load(elecLayout);
%     allElecs             = lay;
end
%%
% Default cfg
% cfg = []

% cfg.method = 'distance';
% cfg.neighbourdist = .25;
% cfg.feedback = 'yes';
% neighbors               = ft_prepare_neighbours(cfg);
%%
cfg.layout              = elecLayout;
cfg                     = [];
cfg.neighbours          = neighbors;
cfg.method              = 'trial';
cfg.preproc             = preproc;
cfg.baselinewindow      = [-0.1 0];
cfg.continuous          = 'yes';
cfg.blocksize           = 15;
cfg.trialdef            = trialdef;
% cfg.artfctdef           = artfctdef;
cfg.trialfun            = 'ft_trialfun_swop';
cfg.keepchannel         = 'repair';
cfg.demean              = 'yes';
cfg.reref               = 'yes';
cfg.refchannel          = {'M1' 'M2'};%{'EXG1' 'EXG2'};
default_cfg             = cfg;

% Weird swedish labels
badLabs = {'CZ','FP1','FP2','FZ','PZ'};
goodLabs = {'Cz','Fp1','Fp2','Fz','Pz'};