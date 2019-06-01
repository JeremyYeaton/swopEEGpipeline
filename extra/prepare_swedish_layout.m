lay.label(find(~ismember(lay.label,swElecs.label)))

swElecs.label(find(~ismember(swElecs.label,lay.label)))

cfg = [];
cfg.layout = 'biosemi64.lay';
laybs = ft_prepare_layout(cfg);
a = find(ismember(laybs.label,data.label));
b = a;
a(end + 1:end + 2) = 65:66;

lays = laybs;
lays.pos = lays.pos(a,:);
lays.width = lays.width(a,:);
lays.height = lays.height(a,:);
lays.label = lays.label(a,:);
lays.cfg.channel = lays.cfg.channel(b,:);

lay = lays;
save('swedishLayout.mat','lay')
%%
load('swedishLayout.mat','lay')
find(~ismember(data.label,lay.label))