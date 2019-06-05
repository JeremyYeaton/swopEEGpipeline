%% Load settings and relevant files
swopSettings
load(['ft_results\struc_',L1,'.mat'],'strucFr')
load(['ft_results\struc_',L1,'.mat'],'strucSw')
load('grandavg_sw.mat','grandavgsw');
load('grandavg_fr.mat','grandavgfr');
load('time.mat','time');
%% Plot individuals
frontal = {'F4','F3','F7','F8'};
figure;
nrow = 2;%4;
ncol = 2;%5;
cfg = [];
cfg.preproc.refchannel = 'M';
cfg.preproc.reref = 'yes';
cfg.refchannel = 'M';
cfg.reref = 'yes';
for sub = 1:length(subs)
    subplot(nrow,ncol,sub)
    cfg.channel = frontal;
    ft_singleplotER(cfg,dataStruc.Can{sub},dataStruc.Vio{sub},dataStruc.Diff{sub})
end

%% Topos SW vs FR by time
figure;
cfg = [];
nrow = 2;
ncol = 4;
% cfg.channel = swedChans;
cfg.layout = elecLayout;
for lat = 1:length(lats)
    tmask = time >= lats{lat}(1) & time <= lats{lat}(2);
    cfg.xlim = lats{lat};
    subplot(nrow,ncol,lat)
    ft_topoplotER(cfg,grandavgsw.Diff)
    subplot(nrow,ncol,lat+ncol)
    ft_topoplotER(cfg,grandavgfr.Diff)
end
%% Topos fr participants x time
figure;
cfg = [];
nrow = 2;
ncol = 4;
% cfg.channel = swedChans;
cfg.layout = elecLayout;
for lat = 1:length(lats)
    tmask = time >= lats{lat}(1) & time <= lats{lat}(2);
    cfg.xlim = lats{lat};
    subplot(nrow,ncol,lat)
    ft_topoplotER(cfg,grandavgsw.Diff)
    subplot(nrow,ncol,lat+ncol)
    ft_topoplotER(cfg,grandavgfr.Diff)
end
%% By electrode
figure;
cfg = [];
for i = 3:length(swedChans)
subplot(5,6,i-2);
cfg.channel = swedChans(i);
ft_singleplotER(cfg,grandavg_diff_sw,grandavg_can_sw,grandavg_vio_sw);
end

figure;
cfg = [];
for i = 3:length(swedChans)
subplot(5,6,i-2);
cfg.channel = swedChans(i);
ft_singleplotER(cfg,grandavg_diff_fr,grandavg_can_fr,grandavg_vio_fr);
end

%%
cfg = [];
cfg.interactive = 'no';
cfg.showoutline = 'yes';
cfg.layout = elecLayout;
cfg.channel = swedChans;
cfg.baselinetype = 'zscore';
nrow = 2;
ncol = 2;
figure;
subplot(nrow,ncol,1)
ft_multiplotER(cfg, grandavgsw.Diff)
subplot(nrow,ncol,2)
ft_multiplotER(cfg, grandavgfr.Diff)
subplot(nrow,ncol,3)
ft_multiplotER(cfg, grandavgfr.Diff,grandavgsw.Diff)
% ft_multiplotER(cfg, grandavg_diff_fr,grandavg_can_fr,grandavg_vio_fr)
% ft_multiplotER(cfg, grandavg_diff_sw,grandavg_can_sw,grandavg_vio_sw)
%%
cfg = data.cfg;
cfg.operation = 'subtract';
cfg.parameter = 'avg';
difference = ft_math(cfg, dataVio, dataCan);
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
ft_multiplotER(cfg, difference,dataCan, dataVio);
