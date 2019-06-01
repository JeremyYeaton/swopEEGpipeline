%% Import settings from file
mainDir      = 'C:\\Users\\jdyea\\OneDrive\\MoDyCo\\_pilotSWOP';
cd(mainDir); addpath('swopEEGpipeline')

% Indicate origin for data-specific parameters
origin = 'fr'; % 'sw' for Humlab, 'fr' for MoDyCo
load('swedChans.mat','swedChans')
swopSettings
%% Read data into struct array
for sub = 1:length(subs)
    subID = subs{sub};
    disp(['Loading subject ',subID,' (',num2str(sub),')...']);
    load([folders.timelock,'\\',subID,'_',folders.timelock,'_data.mat'],'dataCan','dataVio');
    load([folders.timelock,'\\',subID,'_',folders.timelock,'_diff.mat'],'difference');
%     cfg.interactive            = 'yes';
    cfg.showoutline            = 'yes';
    cfg.channel                = swedChans;
    cfg.layout                 = elecLayout;
    disp('Storing data in struct...');
    dataStruc.participant{sub} = subID;
    dataStruc.Vio{sub}         = dataVio;
    dataStruc.Can{sub}         = dataCan;
    dataStruc.Diff{sub}        = difference;
end
%% Calculate averages -- FR
cfg = [];
if strcmp(origin,'fr') 
    grandavg_diff_fr = ft_timelockgrandaverage(cfg, dataStruc.Diff{1}, dataStruc.Diff{2},...
        dataStruc.Diff{3}, dataStruc.Diff{4});
    grandavg_vio_fr = ft_timelockgrandaverage(cfg, dataStruc.Vio{1}, dataStruc.Vio{2},...
        dataStruc.Vio{3}, dataStruc.Vio{4});
    grandavg_can_fr = ft_timelockgrandaverage(cfg, dataStruc.Can{1}, dataStruc.Can{2},...
        dataStruc.Can{3}, dataStruc.Can{4});
    grandavg_diff_fr.cfg = rmfield(grandavg_diff_fr.cfg,'previous');
    grandavg_vio_fr.cfg = rmfield(grandavg_vio_fr.cfg,'previous');
    grandavg_can_fr.cfg = rmfield(grandavg_can_fr.cfg,'previous');
    save('grandavg_fr.mat','grandavg_diff_fr','grandavg_vio_fr','grandavg_can_fr');
elsif
%% Calculate averages -- SW
cfg = [];
grandavg_diff_sw = ft_timelockgrandaverage(cfg, dataStruc.Diff{1}, dataStruc.Diff{2},...
    dataStruc.Diff{3}, dataStruc.Diff{4},dataStruc.Diff{5}, dataStruc.Diff{6},...
    dataStruc.Diff{7}, dataStruc.Diff{8}, dataStruc.Diff{9}, dataStruc.Diff{10},...
    dataStruc.Diff{11}, dataStruc.Diff{12}, dataStruc.Diff{13}, dataStruc.Diff{14},...
    dataStruc.Diff{15}, dataStruc.Diff{16}, dataStruc.Diff{17}, dataStruc.Diff{18},...
    dataStruc.Diff{19}, dataStruc.Diff{20});
grandavg_vio_sw = ft_timelockgrandaverage(cfg, dataStruc.Vio{1}, dataStruc.Vio{2},...
    dataStruc.Vio{3}, dataStruc.Vio{4},dataStruc.Vio{5}, dataStruc.Vio{6},...
    dataStruc.Vio{7}, dataStruc.Vio{8}, dataStruc.Vio{9}, dataStruc.Vio{10},...
    dataStruc.Vio{11}, dataStruc.Vio{12}, dataStruc.Vio{13}, dataStruc.Vio{14},...
    dataStruc.Vio{15}, dataStruc.Vio{16}, dataStruc.Vio{17}, dataStruc.Vio{18},...
    dataStruc.Vio{19}, dataStruc.Vio{20});
grandavg_can_sw = ft_timelockgrandaverage(cfg, dataStruc.Can{1}, dataStruc.Can{2},...
    dataStruc.Can{3}, dataStruc.Can{4},dataStruc.Can{5}, dataStruc.Can{6},...
    dataStruc.Can{7}, dataStruc.Can{8}, dataStruc.Can{9}, dataStruc.Can{10},...
    dataStruc.Can{11}, dataStruc.Can{12}, dataStruc.Can{13}, dataStruc.Can{14},...
    dataStruc.Can{15}, dataStruc.Can{16}, dataStruc.Can{17}, dataStruc.Can{18},...
    dataStruc.Can{19}, dataStruc.Can{20});
grandavg_diff_sw.cfg = rmfield(grandavg_diff_sw.cfg,'previous');
grandavg_vio_sw.cfg = rmfield(grandavg_vio_sw.cfg,'previous');
grandavg_can_sw.cfg = rmfield(grandavg_can_sw.cfg,'previous');
save('grandavg_sw.mat','grandavg_diff_sw','grandavg_vio_sw','grandavg_can_sw');
%%

cfg = [];
cfg.interactive = 'no';
cfg.showoutline = 'yes';
cfg.layout = elecLayout;
cfg.channel = swedChans;
ft_multiplotER(cfg, grandavg_diff_fr,grandavg_can_fr,grandavg_vio_fr)
%% Figures
figure;
cfg = [];
for i = 3:length(swedChans)
subplot(5,6,i-2);
cfg.channel = swedChans(i);
ft_singleplotER(cfg,grandavg_diff,grandavg_can,grandavg_vio);
end

figure;
cfg = [];
for i = 3:length(swedChans)
subplot(5,6,i-2);
cfg.channel = swedChans(i);
ft_singleplotER(cfg,grandavg_diff_fr,grandavg_can_fr,grandavg_vio_fr);
end

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