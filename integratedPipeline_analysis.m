%% Import settings from file
mainDir      = 'C:\\Users\\jdyea\\OneDrive\\MoDyCo\\_pilotSWOP';
cd(mainDir); addpath('swopEEGpipeline')

% Indicate origin for data-specific parameters
origin = 'sw'; % 'sw' for Humlab, 'fr' for MoDyCo
swopSettings
%% Read data into struct array
for sub = 1:length(subs)
    subID = subs{sub};
    disp(['Loading subject ',subID,' (',num2str(sub),')...']);
    load([folders.timelock,'\\',subID,'_',folders.timelock,'_data.mat'],'dataCan','dataVio');
    load([folders.timelock,'\\',subID,'_',folders.timelock,'_diff.mat'],'difference');
    cfg.interactive            = 'yes';
    cfg.showoutline            = 'yes';
    cfg.layout                 = elecLayout;
    disp('Storing data in struct...');
    dataStruc.participant{sub} = subID;
    dataStruc.Vio{sub}         = dataVio;
    dataStruc.Can{sub}         = dataCan;
    dataStruc.Diff{sub}        = difference;
end
% Calculate averages
cfg = difference.cfg;
cfg = rmfield(cfg,'method');
%%
grandavg_diff = ft_timelockgrandaverage(cfg, dataStruc.Diff{1}, dataStruc.Diff{2},...
    dataStruc.Diff{3}, dataStruc.Diff{4});
grandavg_vio = ft_timelockgrandaverage(cfg, dataStruc.Vio{1}, dataStruc.Vio{2},...
    dataStruc.Vio{3}, dataStruc.Vio{4});
grandavg_can = ft_timelockgrandaverage(cfg, dataStruc.Can{1}, dataStruc.Can{2},...
    dataStruc.Can{3}, dataStruc.Can{4});
%%
% ,, dataStruc.Diff{5}, dataStruc.Diff{6},...
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
ft_multiplotER(cfg, grandavg_diff,grandavg_can,grandavg_vio)
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