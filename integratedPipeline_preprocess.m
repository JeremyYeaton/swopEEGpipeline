%% Settings
% Pilot data directory
% mainDir      = 'C:\\Users\\jdyea\\OneDrive\\MoDyCo\\_pilotSWOP';
mainDir      = 'C:\\Users\\jdyea\\OneDrive\\MoDyCo\\SWOP\\dataFromSweden';
prepFolder   = 'ft_preprocess';
eegLabFolder = 'bandpass_05to100';
artRejFolder = 'ft_artRej';
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
Tag = 'eeglabSet';
% for sub = 2%:length(subs)
    subID            = subs{sub};
%     EEG              = pop_biosig([mainDir,'\\raw_data\\',subID,'\\',subID,'.bdf'],...
%         'channels',1:70,'ref',[65 66] ,'refoptions',{'keepref' 'on'});
% %     EEG              = pop_rejchan(EEG, 'elec',1:70 ,'threshold',3,'norm','on','measure','kurt');
%     EEG              = eeg_checkset( EEG );
    EEGLABFILE       = [subID,'_',Tag,'.set'];
%     EEG              = pop_saveset( EEG, 'filename',[subID,'_',Tag,'.set'],'filepath',[mainDir,'\\',prepFolder,'\\']);
    EEGLABFILE       = [prepFolder,'\\',EEGLABFILE];
%     EEGLABFILE              = [eegLabFolder,'\\',subID,'_',eegLabFolder,'.set'];
    cfg                     = [];
    cfg.dataset             = EEGLABFILE;
    cfg.trialdef.eventtype  = 'trigger';
    cfg.trialdef.eventvalue = [112 212];
%     cfg.trialdef.eventvalue = [can vio];
    cfg.trialdef.prestim    = .1;
    cfg.trialdef.poststim   = 1;
    cfg.method    = 'trial';
    cfg.preproc.lpfilter            = 'yes'; cfg.preproc.lpfreq = LPF;
    cfg.preproc.hpfilter            = 'yes'; cfg.preproc.hpfreq = HPF;
    cfg.preproc.demean              = 'yes';
    cfg.continuous          = 'yes';
    cfg.blocksize           = 15;
    cfg.trialfun            = 'ft_trialfun_bdf';
    cfg                     = ft_definetrial(cfg);
    data_raw                = ft_preprocessing(cfg); % read in raw data
    % HEOG
    cfg              = [];
    cfg.channel      = {'EXG3' 'EXG4'};
    cfg.reref        = 'yes';
    cfg.implicitref  = [];
    cfg.refchannel   = {'EXG4'};
    eogh             = ft_preprocessing(cfg, data_raw);
    cfg              = [];
    cfg.channel      = 'EXG3';
    eogh             = ft_selectdata(cfg, eogh);
    eogh.label       = {'HEOG'};
    % VEOG
    cfg              = [];
    cfg.channel      = {'EXG5' 'EXG6'};
    cfg.reref        = 'yes';
    cfg.implicitref  = [];
    cfg.refchannel   = {'EXG6'};
    eogv             = ft_preprocessing(cfg, data_raw);
    cfg              = [];
    cfg.channel      = 'EXG5';
    eogv             = ft_selectdata(cfg, eogv);
    eogv.label       = {'VEOG'};
    cfg              = [];
    cfg.channel      = setdiff(1:64, 65:70);
    data             = ft_selectdata(cfg, data_raw);
    % append the EOGH and EOGV channel to the EEG channels
    data             = ft_appenddata(cfg, data, eogv, eogh); % data1
    data1 = data;
    %%
    data = data1;
    % Preprocessing parameters   
    cfg = [];
%     cfg.headerfile = EEGLABFILE;
%     cfg.trialdef.eventtype  = 'trigger';
%     cfg.trialdef.eventvalue = [can vio];
%     cfg.trialdef.prestim    = .1;
%     cfg.trialdef.poststim   = 1;
%     cfg.method    = 'trial';
%     cfg.preproc.lpfilter            = 'yes'; cfg.preproc.lpfreq = LPF;
%     cfg.preproc.hpfilter            = 'yes'; cfg.preproc.hpfreq = HPF;
%     cfg.preproc.demean              = 'yes';
%     cfg.continuous          = 'yes';
%     cfg.blocksize           = 15;
%     cfg.trialfun            = 'ft_trialfun_bdf';
%     cfg                     = ft_definetrial(cfg);
    cfg = rmfield(cfg,{'dataset','headerfile','datafile','trl'});
    data             = ft_preprocessing(cfg,data);
    %%
    cfg = [];
    cfg.layout = 'biosemi64.lay';
    cfg.channel = 1:64;
    data2 = ft_rejectvisual(cfg,data);
    %%
    % ARTIFACT IDENTIFICATION
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
    data_no_artifacts              = ft_rejectartifact(cfg,data2);
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