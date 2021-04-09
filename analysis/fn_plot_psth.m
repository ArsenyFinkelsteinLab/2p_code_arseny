function fn_plot_psth (F, outcome,  time_sample_start, time_sample_end)


hold on;
idx1=find(strcmp({F.outcome},outcome) & strcmp({F.trial_type_name},'l'));
t=F(idx1).psth_timestamps;
idx_t=(t<3);
shadedErrorBar(t(idx_t) ,F(idx1).psth_avg(idx_t), F(idx1).psth_stem(idx_t),'lineprops',{'-','Color','r','markeredgecolor','r','markerfacecolor','r','linewidth',1});
idx2=find(strcmp({F.outcome},outcome) & strcmp({F.trial_type_name},'r'));
shadedErrorBar(t(idx_t) ,F(idx2).psth_avg(idx_t), F(idx2).psth_stem(idx_t),'lineprops',{'-','Color','b','markeredgecolor','b','markerfacecolor','b','linewidth',1});
plot([time_sample_start ,time_sample_start],[-1000,1000],'-k');
plot([time_sample_end,time_sample_end],[-1000,1000],'-k');
plot([0,0],[-1000,1000],'-k');
yl=( [nanmin([F(idx1).psth_avg(idx_t),F(idx2).psth_avg(idx_t),0]) , nanmax([F(idx1).psth_avg(idx_t),F(idx2).psth_avg(idx_t),0])+eps]);

xlim([-3,3]);
ylim(yl);
xlabel('Time (s)');
set(gca,'YTick',yl,'YTickLabel',{num2str(yl(1),'%.1f'), num2str(yl(2),'%.1f')});