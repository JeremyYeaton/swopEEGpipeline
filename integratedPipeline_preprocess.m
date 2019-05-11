%% Settings
% Pilot data directory
mainDir      = 'C:\\Users\\jdyea\\OneDrive\\MoDyCo\\_pilotSWOP';
% mainDir      = 'C:\\Users\\jdyea\\OneDrive\\MoDyCo\\SWOP\\dataFromSweden';
cd(mainDir);
addpath('swopEEGpipeline')
prepFolder   = 'ft_preprocess';
visRejFolder = 'ft_visRej';
icaFolder    = 'ft_icaComponents';
rmvArtfct    = 'ft_rmvArtfct';
LPF          = 40; % Hz
HPF          = .5; % Hz
zCutoff      = 4;

origin = 'sw'; % 'sw' for Humlab, 'fr' for MoDyCo

pilotSubs = {'s_500mk','s_501ml'};
% Swedish sub IDs
swedSubs = {'s_04nm','s_07ba','s_09lo','s_12wg','s_13ff','s_14mc','s_15rj','s_17oh','s_18ak',...
    's_19am','s_21ma','s_23nj','s_24zk','s_25ks','s_26nm','s_27lm','s_28js','s_29ld','s_30la','s_31bf'};

if strcmp(origin,'fr') == 1
    % MoDyCo data settings
    elecLayout   = 'biosemi64.lay';
    eeglabTag    = 'eeglabSet';
    subs         = pilotSubs;
elseif strcmp(origin,'sw') == 1
    % Humlab data settings
    elecLayout   = 'easycapM22.mat';
    eeglabTag    = 'bandpass_05to100';
    subs         = swedSubs;
end

% Trial types
can = [212,214,222,224,231,232,233,234,241,242,243,244]; % canonical
vio = [112,114,122,124,131,132,133,134,141,142,143,144]; % violation
%% Import; epoch; filter; separate & mean EOGs
tic
for sub = 1:length(subs)
    subID            = subs{sub};
    EEGLABFILE       = [prepFolder,'\\',subID,'_',eeglabTag,'.set'];
    if strcmp(origin,'fr') == 1
        EEG              = pop_biosig([mainDir,'\\raw_data\\',subID,'\\',subID,'.bdf'],...
            'channels',1:70,'ref',[65 66] ,'refoptions',{'keepref' 'on'});
        %     EEG              = pop_rejchan(EEG, 'elec',1:70 ,'threshold',3,'norm','on','measure','kurt');
        EEG              = eeg_checkset( EEG );
        EEG              = pop_saveset( EEG, 'filename',[subID,'_',eeglabTag,'.set'],'filepath',[mainDir,'\\',EEGLABFILE]);
    end
    cfg                     = [];
    cfg.dataset             = EEGLABFILE;
    % Preprocessing parameters
    cfg.method              = 'trial';
    cfg.preproc.lpfilter    = 'yes'; cfg.preproc.lpfreq = LPF;
    cfg.preproc.hpfilter    = 'yes'; cfg.preproc.hpfreq = HPF;
    cfg.preproc.demean      = 'yes';
%     cfg.lpfilter            = 'yes'; cfg.lpfreq = LPF;
%     cfg.hpfilter            = 'yes'; cfg.hpfreq = HPF;
%     cfg.demean              = 'yes';
    cfg.baselinewindow      = [-0.1 0];
    cfg.continuous          = 'yes';
    cfg.blocksize           = 15;
    cfg.layout              = elecLayout;
    cfg.trialdef.eventtype  = 'trigger';
%     cfg.trialdef.eventvalue = 112;
    cfg.trialdef.eventvalue = [can vio];
    cfg.trialdef.prestim    = .1;
    cfg.trialdef.poststim   = 1;
%     cfg.trialfun            = trialFunc;
    cfg.trialfun = 'ft_trialfun_swop';
    cfg                     = ft_definetrial(cfg);
    data                    = ft_preprocessing(cfg);
    % Only separate and recombine EOG for French data
    if strcmp(origin,'fr') == 1 
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
        data.cfg.trl % data1
        % append the EOGH and EOGV channel to the EEG channels
        cfg = data.cfg;
        data                    = ft_appenddata(cfg, data, eogv, eogh);
        data.cfg.channel        = data.label;
    end
%     save([prepFolder,'\\',subID,'_',prepFolder,'.mat'],'data')
    clear cfg data
    toc
end
waitbar(1,'Done! Now do visual rejection!');
%% Visual rejection (Summary, channel, or trial)
for sub = 1%1:length(subs)
    subID                = subs{sub};
    load([prepFolder,'\\',subID,'_',prepFolder,'.mat'],'data');
    cfg                  = data.cfg;
    cfg.artfctdef.reject = 'complete';
    cfg.method           = 'summary';
    data                 = ft_rejectvisual(cfg,data);
    rep = input('Further review necessary? [y/n]: ','s');
    while strcmp(rep,'y') == 1
        cfg.method = input('Channel or trial? ','s');
        data                 = ft_rejectvisual(cfg,data);
        rep = input('Further review necessary? [y/n]: ','s');
    end
    disp('Saving file...');
    save([visRejFolder,'\\',subID,'_',visRejFolder,'.mat'],'data');
end

%% ICA decomposition
for sub = 1%1:length(subs)
    subID      = subs{sub};
    load([visRejFolder,'\\',subID,'_',visRejFolder,'.mat'],'data');
    cfg        = data.cfg;
    cfg.method = 'runica';
    comp       = ft_componentanalysis(cfg, data);
    disp('Saving file...');
    save([icaFolder,'\\',subID,'_',icaFolder,'.mat'],'data','comp');
end
waitbar(1,'Done! Now do component rejection!');
%% Component rejection
for sub = 1%1:length(subs)
    subID      = subs{sub};
    load([icaFolder,'\\',subID,'_',icaFolder,'.mat'],'data','comp');
    cfg = [];
    cfg.layout = 'biosemi64.lay';
    cfg.component = 1:20;
    cfg.comment = 'no';
    cfg.viewmode = 'component';
    figure; ft_topoplotIC(cfg, comp)
    ft_databrowser(cfg, comp)
%     artComp = [1,3,4,5,6,7,8,9,10,12,14]; % sub 2
    artComp = [1 2 3 4 5 6 8 10 12 14 16 20]; % sub 1
%     artComp = input('Enter components for removal separated by spaces: ','s');
%     artComp = sscanf(artComp,'%f')';
    cfg.component = artComp;
    data = ft_rejectcomponent(cfg, comp, data);
%     % Automatic EOG rejection
%     cfg                           = data.cfg;
%     cfg.artfctdef.reject          = 'complete';
%     cfg.artfctdef.feedback        = 'yes';
%     cfg.continuous                = 'no';
%     eogChans                      = {'HEOG','VEOG'};
%     cfg.artfctdef.zvalue.channel  = find(ismember(data.label,eogChans));
%     data                          = ft_selectdata(cfg,data);
%     [~, data.cfg.artfctdef.eog.artifact]      = ft_artifact_eog(cfg,data);
%     % cfg.artfctdef.zvalue.cutoff        = zCutoff;
%     % cfg.artfctdef.zvalue.channel       = 1:64;
%     % [cfg, data.cfg.artfctdef.zvalue.artifact]          = ft_artifact_zvalue(cfg,data);
%     data_no_artifacts              = ft_rejectartifact(data.cfg,data);
    disp('Saving file...');
    save([rmvArtfct,'\\',subID,'_',rmvArtfct,'.mat'],'data');
end
data.cfg.viewmode = 'vertical';
%% Mean and store data
for sub = 1%:length(subs)
    subID = subs{sub};
    disp(['Loading subject ',subID,'...']);
    load([rmvArtfct,'\\',subID,'_',rmvArtfct,'.mat'],'data');
    try
        trls = data.cfg.trl;
    catch
        trls = data.cfg.previous{1,1}.trl;
    end
    disp('Averaging over Canonical trials...');
    cfg = data.cfg;
    cfg.trials = find(ismember(data.cfg.trl(:,4),can));
    dataCan = ft_timelockanalysis(cfg,data);
    disp('Averaging over Violation trials...');
    cfg = data.cfg;
    cfg.trials = find(ismember(data.cfg.trl(:,4),vio));
    dataVio = ft_timelockanalysis(cfg,data);
    disp('Computing difference between conditions...');
    cfg = data.cfg;
    cfg.operation = 'subtract';
    cfg.parameter = 'avg';
    difference = ft_math(cfg, dataCan, dataVio);
    cfg.interactive = 'yes';
    cfg.showoutline = 'yes';
    disp('Storing data in struct...');
    dataStruc.participant{sub} = subID;
    dataStruc.data{sub} = data;
    dataStruc.Vio{sub} = dataVio;
    dataStruc.Can{sub}= dataCan;
    dataStruc.Diff{sub} = difference;
end
%%
cfg = data.cfg;
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
ft_multiplotER(cfg, dataVio, dataCan,difference)
%%
cfg = data.cfg;
cfg.operation = 'subtract';
cfg.parameter = 'avg';
difference = ft_math(cfg, dataVio, dataCan);
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
ft_multiplotER(cfg, difference);
%%
cfg.channel = 'FC4';
clf;
ft_singleplotER(cfg,dataVio,dataCan,difference);
%%
sub = 1

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