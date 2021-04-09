function fn_plot_psth_cluster (F, trial_epoch_name, trial_type_name, time_sample_start, time_sample_end)

if strcmp(trial_type_name,'l')==1
    clr{2}=[0.7 0 0];
    clr{1}=[1 0.5 0.5];

elseif  strcmp(trial_type_name,'r')==1
    clr{2}=[0 0 0.7];
    clr{1}=[0.5 0.5 1];
end

hold on;
idx1=find(strcmp({F.trial_epoch_name},trial_epoch_name) & strcmp({F.trial_type_name},trial_type_name) & [F.trial_cluster_group]==2 );
t=F(idx1).psth_timestamps;
idx_t=(t<3);
shadedErrorBar(t(idx_t) ,F(idx1).psth_avg(idx_t), F(idx1).psth_stem(idx_t),'lineprops',{'-','Color',clr{1},'markeredgecolor',clr{1}/3,'markerfacecolor',clr{1}/3,'linewidth',1});
idx2=find(strcmp({F.trial_epoch_name},trial_epoch_name) & strcmp({F.trial_type_name},trial_type_name) & [F.trial_cluster_group]==1 );
shadedErrorBar(t(idx_t) ,F(idx2).psth_avg(idx_t), F(idx2).psth_stem(idx_t),'lineprops',{'-','Color',clr{2},'markeredgecolor',clr{2}/3,'markerfacecolor',clr{2}/3,'linewidth',1});
plot([time_sample_start ,time_sample_start],[-1000,1000],'-k');
plot([time_sample_end,time_sample_end],[-1000,1000],'-k');
plot([0,0],[-1000,1000],'-k');
yl=( [nanmin([F(idx1).psth_avg(idx_t),F(idx2).psth_avg(idx_t),0]) , nanmax([F(idx1).psth_avg(idx_t),F(idx2).psth_avg(idx_t),0])+eps]);

xlim([-3,3]);
ylim(yl);
xlabel('Time (s)');
set(gca,'YTick',yl,'YTickLabel',{num2str(yl(1),'%.1f'), num2str(yl(2),'%.1f')});