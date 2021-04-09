function fn_populate_imaging_psth(key, session_date)

dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\PSTH\AF09_anm437545\' session_date '\'];


b=fetch(EXP.BehaviorTrial&(EXP.Session & key),'*','ORDER BY trial');
b=struct2table(b);
left_hit = find(contains(b.trial_instruction,'left') & contains(b.outcome,'hit'));
right_hit = find(contains(b.trial_instruction,'right') & contains(b.outcome,'hit'));
left_miss = find(contains(b.trial_instruction,'left') & contains(b.outcome,'miss'));
right_miss = find(contains(b.trial_instruction,'right') & contains(b.outcome,'miss'));

bEvent=fetch(EXP.BehaviorTrialEvent  & (EXP.Session & key),'*','ORDER BY trial');

aEvent=fetch(EXP.ActionEvent  & (EXP.Session & key),'*','ORDER BY trial');
histogram([aEvent.action_event_time])

trial_event_time = [bEvent.trial_event_time];
time_go = mode(trial_event_time (contains({bEvent.trial_event_type},'go')));
time_sample_start = mode(trial_event_time (contains({bEvent.trial_event_type},'sound sample start'))) - time_go;
time_sample_end = mode(trial_event_time (contains({bEvent.trial_event_type},'sound sample end'))) - time_go;



roi_list=fetch(IMAGING.ROI & key);

k=key;
k.fov_number = roi_list(1).fov_number(1);

k.roi_number=1;
frames_per_trial=fetchn(IMAGING.FTraceROITrial & k,'frames_per_trial');
f_trace_timestamps=fetchn(IMAGING.FTraceROITrial & k,'f_trace_timestamps');

[~,longest_trial_idx] = max(frames_per_trial);
t=f_trace_timestamps{longest_trial_idx};
t=t-time_go;


F=zeros(numel(frames_per_trial),max(frames_per_trial)) + NaN;

for iROI = 1:numel(roi_list) %15,49,34,25
    
    k.roi_number=iROI;
    FXTr=fetchn(IMAGING.FTraceROITrial & k,'f_trace');
    
    for iTr=1:1:numel(FXTr)
        F(iTr,1:numel(FXTr{iTr}))=FXTr{iTr};
    end
    
    BehavTrial=fetch(EXP.BehaviorTrial & key,'*');
    
    % Hit
    subplot(2,3,1)
    hold on;
    plot([time_sample_start,time_sample_start],[-1000,1000],'-k');
    plot([time_sample_end,time_sample_end],[-1000,1000],'-k');
    plot([0,0],[-1000,1000],'-k');
    x1.all=F(left_hit,:);
    x1.m=mean(x1.all);
    x1.stem =std(x1.all)/sqrt(numel(left_hit));
    shadedErrorBar(t,x1.m, x1.stem,'lineprops',{'-','Color','r','markeredgecolor','r','markerfacecolor','r','linewidth',1});
    x2.all=F(right_hit,:);
    x2.m=mean(x2.all);
    x2.stem =std(x2.all)/sqrt(numel(right_hit));
    shadedErrorBar(t,x2.m, x2.stem,'lineprops',{'-','Color','b','markeredgecolor','b','markerfacecolor','b','linewidth',1});
    ylim( [nanmin([x1.m,x2.m]) , nanmax([x1.m,x2.m])+eps]);
    title(sprintf('ROI %d\nHit',iROI));
    ylabel('F');
    xlim([-4,4]);

    % Miss
    subplot(2,3,2)
    hold on;
    plot([time_sample_start,time_sample_start],[-1000,1000],'-k');
    plot([time_sample_end,time_sample_end],[-1000,1000],'-k');
    plot([0,0],[-1000,1000],'-k');
    x1.all=F(left_miss,:);
    x1.m=mean(x1.all);
    x1.stem =std(x1.all)/sqrt(numel(left_miss));
    shadedErrorBar(t,x1.m, x1.stem,'lineprops',{'-','Color','r','markeredgecolor','r','markerfacecolor','r','linewidth',1});
    x2.all=F(right_miss,:);
    x2.m=mean(x2.all);
    x2.stem =std(x2.all)/sqrt(numel(right_miss));
    shadedErrorBar(t,x2.m, x2.stem,'lineprops',{'-','Color','b','markeredgecolor','b','markerfacecolor','b','linewidth',1});
    ylim( [nanmin([x1.m,x2.m]) , nanmax([x1.m,x2.m])+eps]);
    title(sprintf('Miss',iROI));
    ylabel('F');
    xlim([-4,4]);
    
    % Selectivity
    subplot(2,3,3)
    hold on;
    plot([time_sample_start,time_sample_start],[-1000,1000],'-k');
    plot([time_sample_end,time_sample_end],[-1000,1000],'-k');
    plot([0,0],[-1000,1000],'-k');
    x=mean(F(right_hit,:))  -mean(F(left_hit,:));
    plot(t,x,'-k');
    ylim( [nanmin(x) , nanmax(x)+eps]);
    title('Selectivity, Hit');
    xlim([-4,4]);

    subplot(2,3,6)
    hold on;
    plot([time_sample_start,time_sample_start],[-1000,1000],'-k');
    plot([time_sample_end,time_sample_end],[-1000,1000],'-k');
    plot([0,0],[-1000,1000],'-k');
    x=mean(F(right_miss,:))  -mean(F(left_miss,:));
    plot(t,x,'-k');
    ylim( [nanmin(x) , nanmax(x)+eps]);
    title('Selectivity, Miss');
    xlim([-4,4]);

    
    % Hit-Miss
    subplot(2,3,4)
    hold on;
    plot([time_sample_start,time_sample_start],[-1000,1000],'-k');
    plot([time_sample_end,time_sample_end],[-1000,1000],'-k');
    plot([0,0],[-1000,1000],'-k');
    x=mean(F(left_hit,:))  -mean(F(left_miss,:));
    plot(t,x,'-r');
    ylim( [nanmin(x) , nanmax(x)+eps]);
    title('Left, Hit-Miss');
    xlabel('Time (s)');
    ylabel('F');
    xlim([-4,4]);

    subplot(2,3,5)
    hold on;
    plot([time_sample_start,time_sample_start],[-1000,1000],'-k');
    plot([time_sample_end,time_sample_end],[-1000,1000],'-k');
    plot([0,0],[-1000,1000],'-k');
    x=mean(F(right_hit,:))  -mean(F(right_miss,:));
    plot(t,x,'-b');
    ylim( [nanmin(x) , nanmax(x)+eps]);
    title('Right, Hit-Miss');
    xlim([-4,4]);
    
    %     subplot(2,3,6)
    %     hold on;
    %     plot([time_sample_start,time_sample_start],[-1000,1000],'-k');
    %     plot([time_sample_end,time_sample_end],[-1000,1000],'-k');
    %     plot([0,0],[-1000,1000],'-k');
    %     selectivity_hit=mean(F(right_hit,:))  -mean(F(left_hit,:));
    %     selectivity_miss=mean(F(right_miss,:))  -mean(F(left_miss,:));
    %     x=selectivity_hit-selectivity_miss;
    %     plot(t,x);
    %     ylim( [nanmin(x) , nanmax(x)]);
    %     title('Selectivity, Hit-Miss');
    
    
    
    
    
    
    
    if isempty(dir(dir_save_figure))
        mkdir (dir_save_figure)
    end
    
    filename=['ROI' num2str(iROI) '_' session_date ];
    figure_name_out=[ dir_save_figure filename];
    eval(['print ', figure_name_out, ' -dtiff -cmyk -r200']);
    clf;
    
end
