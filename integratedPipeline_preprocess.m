 %% Import settings from file
mainDir      = 'C:\\Users\\jdyea\\OneDrive\\MoDyCo\\_pilotSWOP';
cd(mainDir); addpath('swopEEGpipeline')

% Indicate origin for data-specific parameters
origin = 'fr'; % 'sw' for Humlab, 'fr' for MoDyCo
swopSettings
%% Import; epoch; filter; separate & mean EOGs
tic
currSub = 1;
for sub = currSub:2%length(subs)
    subID            = subs{sub};
    EEGLABFILE       = [folders.prep,'\\',subID,'_',folders.eeglabTag,'.set'];
    if strcmp(origin,'fr') && ~isfile(EEGLABFILE)
        EEG              = pop_biosig([mainDir,'\\raw_data\\',subID,'\\',subID,'.bdf'],...
            'channels',1:70,'ref',[65 66] ,'refoptions',{'keepref' 'on'});
%         EEG              = pop_rejchan(EEG, 'elec',1:70 ,'threshold',5,'norm','on','measure','kurt');
        EEG              = eeg_checkset( EEG );
        EEG              = pop_saveset( EEG, 'filename',EEGLABFILE,'filepath',[mainDir,'\\']);
    end
    cfg                     = default_cfg;
    cfg.dataset             = EEGLABFILE;
    cfg                     = ft_definetrial(cfg);
%     diff                    = 844195;
%     a                       = find(data.cfg.trl(:,1) > diff);
%     cfg.trials              = a;
%     cfg.trl                 = cfg.trl(a,:);
    data                    = ft_preprocessing(cfg);
    % Only separate and recombine EOG for French data
    if strcmp(origin,'fr')
        % HEOG
        cfg                     = data.cfg;
        cfg.channel             = {'HEOG1','HEOG2'};%{'EXG3' 'EXG4'};
        cfg.reref               = 'yes';
        cfg.implicitref         = [];
        cfg.refchannel          = {'HEOG2'};%{'EXG4'};
        eogh                    = ft_preprocessing(cfg, data);
        cfg                     = data.cfg;
        cfg.channel             = 'HEOG1';%'EXG3';
        eogh                    = ft_selectdata(cfg, eogh);
        eogh.label              = {'HEOG'};
        % VEOG
        cfg                     = data.cfg;
        cfg.channel             = {'VEOG1','VEOG2'};%{'EXG5' 'EXG6'};
        cfg.reref               = 'yes';
        cfg.implicitref         = [];
        cfg.refchannel          = {'VEOG2'};%{'EXG6'};
        eogv                    = ft_preprocessing(cfg, data);
        cfg                     = data.cfg;
        cfg.channel             = 'VEOG1';%'EXG5';
        eogv                    = ft_selectdata(cfg, eogv);
        eogv.label              = {'VEOG'};
        % Mastoid reference
        cfg                     = data.cfg;
        cfg.channel             = {'M1','M2'};%{'EXG1' 'EXG2'};
        cfg.reref               = 'yes';
        cfg.implicitref         = [];
        cfg.refchannel          = {'M2'};%{'EXG2'};
        mast                    = ft_preprocessing(cfg, data);
        cfg                     = data.cfg;
        cfg.channel             = 'M1';%'EXG1';
        mast                    = ft_selectdata(cfg, mast);
        mast.label              = {'M'};
        cfg                     = data.cfg;
        cfg.channel             = setdiff(1:64, 65:70);
        data                    = ft_selectdata(cfg, data);
        % append the Mast EOGH and EOGV channel to the EEG channels
        cfg                     = data.cfg;
        data                    = ft_appenddata(cfg, data, eogv, eogh, mast);
        cfg.reref               = 'yes';
        cfg.refchannel          = 'M';
        cfg.preproc.refchannel  = 'M';
        cfg.demean              = 'yes';
        data.cfg.channel        = data.label;
    end
    % Automatic artifact rejection
    cfg.artfctdef                    = artfctdef;
    [cfg, artifact_eog]              = ft_artifact_eog(cfg,data);
    cfg.artfctdef.zvalue.cutoff      = 20;
    [cfg, artifact_zval]             = ft_artifact_zvalue(cfg,data);
    [cfg, artifact_jump]             = ft_artifact_jump(cfg,data);
    [cfg, artifact_thresh]           = ft_artifact_threshold(cfg,data);
    % Add artifacts to cfg
    cfg.artfctdef.eog.artifact       = artifact_eog;
    cfg.artfctdef.zvalue.artifact    = artifact_zval;
    cfg.artfctdef.jump.artifact      = artifact_jump;
    cfg.artfctdef.threshold.artifact = artifact_thresh;
    % Reject artifacts and save
    data                             = ft_rejectartifact(cfg,data);
    fileName = [folders.prep,'\\',subID,'_',folders.prep,'.mat'];
    disp(['Saving ',fileName,' (',num2str(sub),')...']);
    save(fileName,'data')
%     clear cfg data
    toc
end
waitbar(1,'Done! Now do visual rejection!');
%% Visual rejection (Summary, channel, or trial)
for sub = 2%:length(subs)
    subID                = subs{sub};
    disp(['Loading subject ',subID,' (',num2str(sub),')...']);
    load([folders.prep,'\\',subID,'_',folders.prep,'.mat'],'data');
    % Visual inspection
    cfg                  = data.cfg;
    cfg.channel          = 'all';
    cfg.method           = 'summary';
    cfg.layout           = elecLayout;
    cfg.keepchannel      = 'no';
    data                 = ft_rejectvisual(cfg,data);
    rep = input('Further review necessary? [y/n]: ','s');
    while ~strcmp(rep,'n')
        if ismember(rep,{'summary','trial','channel'})
            cfg.method = rep;
        else
            cfg.method = input('Summary, channel or trial? ','s');
        end
        data             = ft_rejectvisual(cfg,data);
        rep = input('Further review necessary? [y/n]: ','s');
    end
    cfg.method           = 'average';
    cfg.missingchannel   = setdiff(allElecs.label,data.label);
    cfg.feedback         = 'no';
    if ~isempty(cfg.missingchannel)
        disp('Interpolating missing electrodes:');
        for chan = cfg.missingchannel
            disp(chan);
        end
        data            = ft_channelrepair(cfg,data);
    end
    disp(['Saving file ',subID,' (',num2str(sub),')...']);
    save([folders.visRej,'\\',subID,'_',folders.visRej,'.mat'],'data');
end
waitbar(1,'Done! Now do ICA decomposition!');
%% ICA decomposition
for sub = 2%1:length(subs)
    subID      = subs{sub};
    saveName   = [folders.ica,'\\',subID,'_',folders.ica,'.mat'];
    saveFile   = 'y';
%     if isfile(saveName)
%         saveFile = input(['File for ',subID,' already exists. Overwrite? [y/n]'],'s');
%         if strcmp(saveFile,'n')
%             disp('File not saved. ICA decomp already exists.');
%         end
%     end
    if strcmp(saveFile,'y')
        disp(['Loading subject ',subID,' (',num2str(sub),')...']);
        load([folders.visRej,'\\',subID,'_',folders.visRej,'.mat'],'data');
        cfg              = data.cfg;
        cfg.numcomponent = 25;
        cfg.method       = 'runica';
        comp             = ft_componentanalysis(cfg, data);
        disp(['Saving file ',subID,' (',num2str(sub),')...']);
        save(saveName,'data','comp');
    end
end
waitbar(1,'Done! Now do component rejection!');
%% Component rejection
for sub = 1:length(subs)
    subID         = subs{sub};
    disp(['Loading subject ',subID,' (',num2str(sub),')...']);
    load([folders.ica,'\\',subID,'_',folders.ica,'.mat'],'data','comp');
%     cfg           = data.cfg;
%     cfg           = rmfield(cfg,'previous');
    cfg           = [];
    cfg.trl       = data.cfg.trl;
    cfg.layout    = 'biosemi64.lay';
    cfg.component = 1:20;
    cfg.comment   = 'no';
    cfg.viewmode  = 'component';
    figure; ft_topoplotIC(cfg, comp)
    ft_databrowser(cfg, comp)
    artComp       = input('Enter components for removal separated by spaces: ','s');
    artComp       = sscanf(artComp,'%f')';
%     artComp       = 1:20;
    cfg.component = artComp;
    data          = ft_rejectcomponent(cfg, comp, data);
    disp(['Saving file ',subID,' (',num2str(sub),')...']);
    save([folders.rmvArtfct,'\\',subID,'_',folders.rmvArtfct,'.mat'],'data');
    close all
end
waitbar(1,'Done! Now do time lock analysis!');
%% Mean and store data
for sub = [1,3,4]%:length(subs)
    subID = subs{sub};
    disp(['Loading subject ',subID,' (',num2str(sub),')...']);
    load([folders.rmvArtfct,'\\',subID,'_',folders.rmvArtfct,'.mat'],'data');
    data.cfg          = rmfield(data.cfg,'previous');
    data.cfg.viewmode = 'butterfly';
    data.cfg.method   = 'trial';
    data.cfg.reref    = 'yes';
    data.cfg.refchannel = {'M'};
%     data              = ft_rejectvisual(data.cfg,data);
    disp('Averaging over Canonical trials...');
    cfg           = data.cfg;
    cfg.trials    = find(ismember(data.trialinfo,trials.can));
    dataCan       = ft_timelockanalysis(cfg,data);
    disp('Averaging over Violation trials...');
    cfg           = data.cfg;
    cfg.trials    = find(ismember(data.trialinfo,trials.vio));
    dataVio       = ft_timelockanalysis(cfg,data);
    disp('Computing difference between conditions...');
    cfg           = data.cfg;
    cfg.operation = 'subtract';
    cfg.parameter = 'avg';
    difference    = ft_math(cfg, dataVio, dataCan);
    difference.cfg= rmfield(difference.cfg,'previous');
    disp(['Saving data file ',subID,' (',num2str(sub),')...']);
    save([folders.timelock,'\\',subID,'_',folders.timelock,'_data.mat'],'dataCan','dataVio');
    clear data dataCan dataVio
    disp(['Saving difference file ',subID,' (',num2str(sub),')...']);
    save([folders.timelock,'\\',subID,'_',folders.timelock,'_diff.mat'],'difference');
    clear difference
end
waitbar(1,'Done! Now do grand averaging!');
%% Store in struct array and compare
for sub = 1:length(subs)
    subID = subs{sub};
    disp(['Loading subject ',subID,' (',num2str(sub),')...']);
    load([folders.timelock,'\\',subID,'_',folders.timelock,'_diff.mat'],'difference');
    cfg.interactive = 'yes';
    cfg.showoutline = 'yes';
    cfg.layout      = elecLayout;
    disp('Storing data in struct...');
    dataStruc.participant{sub} = subID;
%     dataStruc.data{sub} = data;
%     dataStruc.Vio{sub} = dataVio;
%     dataStruc.Can{sub}= dataCan;
    dataStruc.Diff{sub} = difference;
end

%%
cfg = difference.cfg;
cfg = rmfield(cfg,'method');
grandavg = ft_timelockgrandaverage(cfg, dataStruc.Diff{1}, dataStruc.Diff{2})
%%
% ,...
%     dataStruc.Diff{3}, dataStruc.Diff{4}, dataStruc.Diff{5}, dataStruc.Diff{6},...
%     dataStruc.Diff{7}, dataStruc.Diff{8}, dataStruc.Diff{9}, dataStruc.Diff{10},...
%     dataStruc.Diff{11}, dataStruc.Diff{12}, dataStruc.Diff{13}, dataStruc.Diff{14},...
%     dataStruc.Diff{15}, dataStruc.Diff{16}, dataStruc.Diff{17}, dataStruc.Diff{18},...
%     dataStruc.Diff{19}, dataStruc.Diff{20});




%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cfg = data.cfg;
cfg = [];
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
cfg.layout = elecLayout;
ft_multiplotER(cfg, grandavg)
%%
cfg = data.cfg;
cfg.operation = 'subtract';
cfg.parameter = 'avg';
difference = ft_math(cfg, dataVio, dataCan);
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
ft_multiplotER(cfg, difference,dataCan, dataVio);
%%
cfg.channel = 'FC4';
clf;
ft_singleplotER(cfg,dataVio,dataCan,difference);