%% Settings
% Pilot data directory
mainDir      = 'C:\\Users\\jdyea\\OneDrive\\MoDyCo\\_pilotSWOP';
% mainDir      = 'C:\\Users\\jdyea\\OneDrive\\MoDyCo\\SWOP\\dataFromSweden';
cd(mainDir);
eeglabTag = 'eeglabSet';
prepFolder   = 'ft_preprocess';
eegLabFolder = 'bandpass_05to100';
visRejFolder = 'ft_visRej';
icaFolder    = 'ft_icaComponents';
rmvArtfct    = 'ft_rmvArtfct';
LPF          = 40; % Hz
HPF          = .5; % Hz
zCutoff      = 4;

% Trial types
can = [212,214,222,224,231,232,233,234,241,242,243,244]; % canonical
vio = [112,114,122,124,131,132,133,134,141,142,143,144]; % violation
allTrig = [212,214,222,224,231,232,233,234,241,242,243,244,...
    112,114,122,124,131,132,133,134,141,142,143,144]; 

pilotSubs = {'s_500mk','s_501ml'};
% Swedish sub IDs
swedSubs = {'s_04nm','s_07ba','s_09lo','s_12wg','s_13ff','s_14mc','s_15rj','s_17oh','s_18ak',...
    's_19am','s_21ma','s_23nj','s_24zk','s_25ks','s_26nm','s_27lm','s_28js','s_29ld','s_30la','s_31bf'};
subs = pilotSubs;

%% Import; epoch; filter; separate & mean EOGs
for sub = 1:length(subs)
    subID            = subs{sub};
    EEGLABFILE       = [prepFolder,'\\',subID,'_',eeglabTag,'.set'];
%     EEG              = pop_biosig([mainDir,'\\raw_data\\',subID,'\\',subID,'.bdf'],...
%         'channels',1:70,'ref',[65 66] ,'refoptions',{'keepref' 'on'});
% %     EEG              = pop_rejchan(EEG, 'elec',1:70 ,'threshold',3,'norm','on','measure','kurt');
%     EEG              = eeg_checkset( EEG );
%     EEG              = pop_saveset( EEG, 'filename',[subID,'_',eeglabTag,'.set'],'filepath',[mainDir,'\\',EEGLABFILE]);
%     EEGLABFILE              = [eegLabFolder,'\\',subID,'_',eegLabFolder,'.set'];
    cfg                     = [];
    cfg.dataset             = EEGLABFILE;
    % Preprocessing parameters
    cfg.method              = 'trial';
    cfg.preproc.lpfilter    = 'yes'; cfg.preproc.lpfreq = LPF;
    cfg.preproc.hpfilter    = 'yes'; cfg.preproc.hpfreq = HPF;
    cfg.preproc.demean      = 'yes';
    cfg.lpfilter            = 'yes'; cfg.lpfreq = LPF;
    cfg.hpfilter            = 'yes'; cfg.hpfreq = HPF;
    cfg.demean              = 'yes';
    cfg.baselinewindow      = [-0.1 0];
    cfg.continuous          = 'yes';
    cfg.blocksize           = 15;
    cfg.layout              = 'biosemi64.lay';
    cfg.trialdef.eventtype  = 'trigger';
%     cfg.trialdef.eventvalue = 112;
    cfg.trialdef.eventvalue = [can vio];
    cfg.trialdef.prestim    = .1;
    cfg.trialdef.poststim   = 1;
    cfg.trialfun            = 'ft_trialfun_bdf';
    cfg                     = ft_definetrial(cfg);
    data                    = ft_preprocessing(cfg);
    % HEOG
    cfg                     = data.cfg;
    cfg.channel             = {'EXG3' 'EXG4'};
    cfg.reref               = 'yes';
    cfg.implicitref         = [];
    cfg.refchannel          = {'EXG4'};
    eogh                    = ft_preprocessing(cfg, data);
    cfg                     = data.cfg;
    cfg.channel             = 'EXG3';
    eogh                    = ft_selectdata(cfg, eogh);
    eogh.label              = {'HEOG'};
    % VEOG
    cfg                     = data.cfg;
    cfg.channel             = {'EXG5' 'EXG6'};
    cfg.reref               = 'yes';
    cfg.implicitref         = [];
    cfg.refchannel          = {'EXG6'};
    eogv                    = ft_preprocessing(cfg, data);
    cfg                     = data.cfg;
    cfg.channel             = 'EXG5';
    eogv                    = ft_selectdata(cfg, eogv);
    eogv.label              = {'VEOG'};
    cfg                     = data.cfg;
    cfg.channel             = setdiff(1:64, 65:70);
    data                    = ft_selectdata(cfg, data);
    % append the EOGH and EOGV channel to the EEG channels
    data                    = ft_appenddata(data.cfg, data, eogv, eogh);
    data.cfg.channel        = data.label;
    data                    = ft_preprocessing(data.cfg,data);
    save([prepFolder,'\\',subID,'_',prepFolder,'.mat'],'data')
end
%% Visual channel rejection
for sub = 2%1:length(subs)
    subID      = subs{sub};
    load([prepFolder,'\\',subID,'_',prepFolder,'.mat'],'data');
    cfg        = data.cfg;
    cfg.artfctdef.reject          = 'partial';
    cfg.method = 'channel';
    data       = ft_rejectvisual(cfg,data);
    cfg.method = 'trial';
    data       = ft_rejectvisual(cfg,data);
    cfg.method = 'summary';
    data       = ft_rejectvisual(cfg,data);
    disp('Saving file...');
    save([visRejFolder,'\\',subID,'_',visRejFolder,'.mat'],'data');
end
%% ICA decomposition
for sub = 2%1:length(subs)
    subID      = subs{sub};
    load([visRejFolder,'\\',subID,'_',visRejFolder,'.mat'],'data');
    cfg        = data.cfg;
    cfg.method = 'runica';
    comp       = ft_componentanalysis(cfg, data);
    disp('Saving file...');
    save([icaFolder,'\\',subID,'_',icaFolder,'.mat'],'data','comp');
end

%% Component rejection
for sub = 2%1:length(subs)
    subID      = subs{sub};
    load([icaFolder,'\\',subID,'_',icaFolder,'.mat'],'data','comp');
    cfg = [];%data.cfg;
    cfg.layout = 'biosemi64.lay';
    cfg.component = 1:20;
    cfg.comment = 'no';
    cfg.viewmode = 'component';
%     figure; ft_topoplotIC(cfg, comp)
%     ft_databrowser(cfg, comp)
    artComp = [1,3,4,5,6,7,8,9,10,12,14];
    cfg.component = artComp;
    data = ft_rejectcomponent(cfg, comp, data);
    % Automatic EOG rejection
    cfg                           = data.cfg;
    cfg.artfctdef.reject          = 'complete';
    cfg.artfctdef.feedback        = 'yes';
    cfg.continuous                = 'no';
    eogChans                      = {'HEOG','VEOG'};
    cfg.artfctdef.zvalue.channel  = find(ismember(data.label,eogChans));
    data                          = ft_selectdata(cfg,data);
    [~, data.cfg.artfctdef.eog.artifact]      = ft_artifact_eog(cfg,data);
    % cfg.artfctdef.zvalue.cutoff        = zCutoff;
    % cfg.artfctdef.zvalue.channel       = 1:64;
    % [cfg, data.cfg.artfctdef.zvalue.artifact]          = ft_artifact_zvalue(cfg,data);
    data = ft_databrowser(data.cfg,data);
    data_no_artifacts              = ft_rejectartifact(data.cfg,data);
    disp('Saving file...');
    data = data_no_artifacts;
    data.cfg.viewmode = 'channel';
    save([rmvArtfct,'\\',subID,'_',rmvArtfct,'.mat'],'data');
end
ft_databrowser(data.cfg,data)
%%
dataAll = ft_timelockanalysis(data.cfg,data)
%%
cfg = dataAll.cfg;
cfg.trials = can;
dataCan = ft_timelockanalysis(cfg,data)

cfg = dataAll.cfg;
cfg.trials = vio;
dataVio = ft_timelockanalysis(cfg,data)
%%
cfg.trial
%% Automatic artifact rejection
sub = 1;
subID = subs{sub};
load([prepFolder,'\\',subID,'_',prepFolder,'.mat'],'data');
cfg                           = data.cfg;
cfg.trl                       = data.cfg.previous.trl;
cfg.artfctdef.reject          = 'complete';
cfg.artfctdef.feedback        = 'yes';
cfg.continuous                = 'no';
eogChans                      = {'HEOG','VEOG'};
cfg.artfctdef.zvalue.channel  = find(ismember(data.label,eogChans));
data                          = ft_selectdata(cfg,data);
[cfg, data.cfg.artfctdef.eog.artifact]      = ft_artifact_eog(cfg,data);

cfg.artfctdef.zvalue.cutoff        = zCutoff;
cfg.artfctdef.zvalue.channel       = 1:64;
[cfg, data.cfg.artfctdef.zvalue.artifact]          = ft_artifact_zvalue(cfg,data);
data_no_artifacts              = ft_rejectartifact(data.cfg,data);



%% Visual artifact rejection
chansToPop = {'P8','PO4','POz','P10'}; %(60)
allChans = ones(length(data.label),1);
chans = ismember(data.label,chansToPop)
    
data.cfg.channel = setdiff(1:64, find(chans));
ft_databrowser(data.cfg,data)
    %%
    % ARTIFACT IDENTIFICATION
    cfg = [];
%     cfg.feedback  = 'yes';
    cfg.artfctdef.reject = 'complete';
%     % Z-value rejection
    cfg.artfctdef.zvalue.cutoff        = zCutoff;
    cfg.artfctdef.zvalue.channel       = 1:64;
%     cfg.artfctdef.zvalue.trlpadding    = 0.5;
    cfg.artfctdef.zvalue.fltpadding    = 0.1;
    cfg.artfctdef.zvalue.artpadding    = 0.1;
    % algorithmic parameters
    cfg.artfctdef.zvalue.cumulative    = 'yes';
    cfg.artfctdef.zvalue.medianfilter  = 'yes';
    cfg.artfctdef.zvalue.medianfiltord = 9;
    cfg.artfctdef.zvalue.absdiff       = 'yes';
%     % make the process interactive
%     cfg.artfctdef.zvalue.interactive = 'yes';
    % EOG rejection
    cfg.artfctdef.eog.cutoff       = zCutoff;
    cfg.artfctdef.eog.channel      = {'HEOG' 'VEOG'};
%     cfg.artfctdef.eog.trlpadding   = 0.5;
    cfg.artfctdef.eog.fltpadding   = 0.1;
    cfg.artfctdef.eog.artpadding   = 0.1;
%     cfg.artfctdef.eog.interactive = 'yes';
    cfg = rmfield(cfg,{'dataset','headerfile','datafile'});
    cfg                     = ft_definetrial(cfg);
    cfg.artfctdef.zvalue.artifact = ft_artifact_zvalue(cfg,data); %
    cfg.artfctdef.eog.artifact     = ft_artifact_eog(cfg,data);%
    data_no_artifacts              = ft_rejectartifact(cfg);
    % END ARTIFACT %%
    data             = ft_preprocessing(cfg,data);
    
%     save([prepFolder,'\\',subID,'_',prepFolder,'.mat'],'data')
end
% save([prepFolder,'\\',subID,'_',prepFolder,'.mat'],'data')
%% Artifact rejection: Automatic and visual
for sub = 2%1:1%length(pilotSubs)
    subID         = pilotSubs{sub};
    load([prepFolder,'\\',subID,'_',prepFolder,'.mat'],'data')
    cfg           = [];
%     cfg.headerfile = data.cfg.previous{1, 1}.previous.headerfile;
    cfg.method    = 'trial';
    cfg.feedback  = 'yes';
    cfg.artfctdef.reject = 'complete';
    % Z-value rejection
    cfg.artfctdef.zvalue.cutoff  = zCutoff;
    cfg.artfctdef.zvalue.channel = 1:66;
%     cfg.artfctdef.zvalue.trlpadding   = 0.5;
    cfg.artfctdef.zvalue.fltpadding   = 0.1;
    cfg.artfctdef.zvalue.artpadding   = 0.1;
    % algorithmic parameters
    cfg.artfctdef.zvalue.cumulative = 'yes';
    cfg.artfctdef.zvalue.medianfilter = 'yes';
    cfg.artfctdef.zvalue.medianfiltord = 9;
    cfg.artfctdef.zvalue.absdiff = 'yes';
    % make the process interactive
    cfg.artfctdef.zvalue.interactive = 'yes';
    [cfg, artifact_jump] = ft_artifact_zvalue(cfg);
end
%%
    cfg.artfctdef.zvalue.artifact  = ft_artifact_zvalue(cfg,data);
    % EOG rejection
    cfg.artfctdef.eog.cutoff       = zCutoff;
    cfg.artfctdef.eog.channel      = {'HEOG' 'VEOG'};
    cfg.artfctdef.eog.trlpadding   = 0.5;
    cfg.artfctdef.eog.fltpadding   = 0.1;
    cfg.artfctdef.eog.artpadding   = 0.1;
    cfg.artfctdef.eog.artifact     = ft_artifact_eog(cfg,data);
    data_no_artifacts              = ft_rejectartifact(cfg,data);
%     data_clean   = ft_rejectvisual(cfg, data);
% end