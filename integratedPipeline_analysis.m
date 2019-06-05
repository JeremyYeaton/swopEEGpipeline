%% Import settings from file
mainDir      = 'C:\\Users\\jdyea\\OneDrive\\MoDyCo\\_pilotSWOP';
cd(mainDir); addpath('swopEEGpipeline')

% Indicate origin for data-specific parameters
origin = 'fr'; % 'sw' for Humlab, 'fr' for MoDyCo
load('swedChans.mat','swedChans')
swopSettings
L1 = 'fr';
if strcmp(L1,'fr')
    subs = frSubs;
elseif strcmp(L1,'sw')
    subs = swedSubs;
    load('time.mat','time');
end
%% Read data into struct array
for sub = 1:length(subs)
    subID = subs{sub};
    disp(['Loading subject ',subID,' (',num2str(sub),')...']);
    load([folders.timelock,'\\',subID,'_',folders.timelock,'_data.mat'],'dataCan','dataVio');
    load([folders.timelock,'\\',subID,'_',folders.timelock,'_diff.mat'],'difference');
    if strcmp(L1,'sw')
        difference.time = time;
        dataCan.time = time;
        dataVio.time = time;
    end
%     cfg.interactive            = 'yes';
%     cfg.channel                = swedChans;
%     cfg.layout                 = elecLayout;
    disp('Storing data in struct...');
    dataStruc.participant{sub} = subID;
    dataStruc.Vio{sub}         = dataVio;
    dataStruc.Can{sub}         = dataCan;
    dataStruc.Diff{sub}        = difference;
end
if strcmp(L1,'fr')
    strucFr = dataStruc;
    save(['ft_results\struc_',L1,'.mat'],'strucFr')
elseif strcmp(L1,'sw')
    strucSw = dataStruc;
    save(['ft_results\struc_',L1,'.mat'],'strucSw')
end
%% Calculate averages
cfg = [];
cfg.channel = swedChans;
if strcmp(L1,'fr') 
    grandavgfr.Diff = ft_timelockgrandaverage(cfg, dataStruc.Diff{1}, dataStruc.Diff{2},...
        dataStruc.Diff{3}, dataStruc.Diff{4});
    grandavgfr.Vio = ft_timelockgrandaverage(cfg, dataStruc.Vio{1}, dataStruc.Vio{2},...
        dataStruc.Vio{3}, dataStruc.Vio{4});
    grandavgfr.Can = ft_timelockgrandaverage(cfg, dataStruc.Can{1}, dataStruc.Can{2},...
        dataStruc.Can{3}, dataStruc.Can{4});
    grandavgfr.Diff.cfg = rmfield(grandavgfr.Diff.cfg,'previous');
    grandavgfr.Vio.cfg = rmfield(grandavgfr.Vio.cfg,'previous');
    grandavgfr.Can.cfg = rmfield(grandavgfr.Can.cfg,'previous');
    disp('Saving French averages...');
    save('grandavg_fr.mat','grandavgfr');
elseif strcmp(L1,'sw')
    grandavgsw.Diff = ft_timelockgrandaverage(cfg, dataStruc.Diff{1}, dataStruc.Diff{2},...
        dataStruc.Diff{3}, dataStruc.Diff{4},dataStruc.Diff{5}, dataStruc.Diff{6},...
        dataStruc.Diff{7}, dataStruc.Diff{8}, dataStruc.Diff{9}, dataStruc.Diff{10},...
        dataStruc.Diff{11}, dataStruc.Diff{12}, dataStruc.Diff{13}, dataStruc.Diff{14},...
        dataStruc.Diff{15}, dataStruc.Diff{16}, dataStruc.Diff{17}, dataStruc.Diff{18},...
        dataStruc.Diff{19}, dataStruc.Diff{20});%,dataStruc.Diff{21},dataStruc.Diff{22});
    grandavgsw.Vio = ft_timelockgrandaverage(cfg, dataStruc.Vio{1}, dataStruc.Vio{2},...
        dataStruc.Vio{3}, dataStruc.Vio{4},dataStruc.Vio{5}, dataStruc.Vio{6},...
        dataStruc.Vio{7}, dataStruc.Vio{8}, dataStruc.Vio{9}, dataStruc.Vio{10},...
        dataStruc.Vio{11}, dataStruc.Vio{12}, dataStruc.Vio{13}, dataStruc.Vio{14},...
        dataStruc.Vio{15}, dataStruc.Vio{16}, dataStruc.Vio{17}, dataStruc.Vio{18},...
        dataStruc.Vio{19}, dataStruc.Vio{20});%,dataStruc.Vio{21},dataStruc.Vio{22});
    grandavgsw.Can = ft_timelockgrandaverage(cfg, dataStruc.Can{1}, dataStruc.Can{2},...
        dataStruc.Can{3}, dataStruc.Can{4},dataStruc.Can{5}, dataStruc.Can{6},...
        dataStruc.Can{7}, dataStruc.Can{8}, dataStruc.Can{9}, dataStruc.Can{10},...
        dataStruc.Can{11}, dataStruc.Can{12}, dataStruc.Can{13}, dataStruc.Can{14},...
        dataStruc.Can{15}, dataStruc.Can{16}, dataStruc.Can{17}, dataStruc.Can{18},...
        dataStruc.Can{19}, dataStruc.Can{20});%,dataStruc.Can{21},dataStruc.Can{22});
    grandavgsw.Diff.cfg = rmfield(grandavgsw.Diff.cfg,'previous');
    grandavgsw.Vio.cfg = rmfield(grandavgsw.Vio.cfg,'previous');
    grandavgsw.Can.cfg = rmfield(grandavgsw.Can.cfg,'previous');
    disp('Saving Swedish averages...');
    save('grandavg_sw.mat','grandavgsw');
end
%%
means = [];
elecMask = ismember(swedChans,frontal);
for t = 1:length(mint)
    mask = time >= mint(t) & time <= maxt(t);
    means.fr(:,t) = squeeze(mean(grandavgfr.Diff.avg(:,mask),2));
    means.sw(:,t) = squeeze(mean(grandavgsw.Diff.avg(:,mask),2));
end
means.sw(elecMask,:)