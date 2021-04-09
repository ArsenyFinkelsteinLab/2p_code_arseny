function fn_plot_imaging_psthWC ()
close all


dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\WaterCue\PSTH\'];

% key.subject_id = 445980;
% key.session =2;

key.subject_id = 447990;
key.session =7;

% 
% key.subject_id = 447991;
% key.session =8;


session_date = fetch1(EXP2.Session & key,'session_date');
dir_current_fig = [dir_current_fig '\anm' num2str(key.subject_id) '\' session_date '\'];

roi_list=fetchn(IMG.ROI & IMG.ROIGood & key,'roi_number', 'ORDER BY roi_number');


panel_width1=0.2;
panel_height1=0.2;
horizontal_distance1=0.8;
vertical_distance1=0.35;


position_x1(1)=0.06;

position_y1(1)=0.6;
position_y1(2)=position_y1(1)-vertical_distance1;
position_y1(3)=position_y1(2)-vertical_distance1;
position_y1(4)=position_y1(3)-vertical_distance1;



for iROI = 1:numel(roi_list) %15,49,34,25
    
    
    position_x1(end+1)=position_x1(end)+horizontal_distance1;
    
    key.roi_number=roi_list(iROI);
    
    F=fetch(WC.FPSTHaverage & key,'*');
    
    
    
    time_sample_start = F(1).time_sample_start;
    time_sample_end = F(1).time_sample_end;
    
    %         Signif=fetch(ANLI.TaskSignifROI & key,'*', 'ORDER BY task_signif_name_uid');
    
    % Hit
    axes('position',[position_x1(1) position_y1(1) panel_width1 panel_height1]);
    hold on;
    idx1=find(strcmp({F.outcome},'hit') & strcmp({F.trial_type_name},'l'));
    t=F(idx1).psth_timestamps;
    idx_t=(t<3);
    shadedErrorBar(t(idx_t) ,F(idx1).psth_avg(idx_t), F(idx1).psth_stem(idx_t),'lineprops',{'-','Color','r','markeredgecolor','r','markerfacecolor','r','linewidth',1});
    idx2=find(strcmp({F.outcome},'hit') & strcmp({F.trial_type_name},'r'));
    shadedErrorBar(t(idx_t) ,F(idx2).psth_avg(idx_t), F(idx2).psth_stem(idx_t),'lineprops',{'-','Color','b','markeredgecolor','b','markerfacecolor','b','linewidth',1});
    plot([time_sample_start ,time_sample_start],[-1000,1000],'-k');
    plot([time_sample_end,time_sample_end],[-1000,1000],'-k');
    plot([0,0],[-1000,1000],'-k');
    yl=( [nanmin([F(idx1).psth_avg(idx_t),F(idx2).psth_avg(idx_t),0]) , nanmax([F(idx1).psth_avg(idx_t),F(idx2).psth_avg(idx_t),0])+eps]);
    %         title(sprintf('Session %d\nCorrect\n p S=%.7f \nD=%.7f\n M=%.7f \nR=%.7f',multiple_session_list(i_s), Signif(1).task_signif_pval, Signif(2).task_signif_pval, Signif(3).task_signif_pval, Signif(4).task_signif_pval));
    ylabel('Spikes/s');
    title(sprintf('ROI %d\nSession %d\nCorrect',roi_list(iROI),key.session));
    xlim([-3,3]);
    ylim(yl);
    xlabel('Time (s)');
    set(gca,'YTick',yl,'YTickLabel',{num2str(yl(1),'%.1f'), num2str(yl(2),'%.1f')});
    
    % Miss
    axes('position',[position_x1(1) position_y1(2) panel_width1 panel_height1]);
    hold on;
    idx1=find(strcmp({F.outcome},'miss') & strcmp({F.trial_type_name},'l'));
    t=F(idx1).psth_timestamps;
    idx_t=(t<3);
    shadedErrorBar(t(idx_t) ,F(idx1).psth_avg(idx_t), F(idx1).psth_stem(idx_t),'lineprops',{'-','Color','r','markeredgecolor','r','markerfacecolor','r','linewidth',1});
    idx2=find(strcmp({F.outcome},'miss') & strcmp({F.trial_type_name},'r'));
    shadedErrorBar(t(idx_t) ,F(idx2).psth_avg(idx_t), F(idx2).psth_stem(idx_t),'lineprops',{'-','Color','b','markeredgecolor','b','markerfacecolor','b','linewidth',1});
    plot([time_sample_start ,time_sample_start],[-1000,1000],'-k');
    plot([time_sample_end,time_sample_end],[-1000,1000],'-k');
    plot([0,0],[-1000,1000],'-k');
    yl=( [nanmin([F(idx1).psth_avg(idx_t),F(idx2).psth_avg(idx_t),0]) , nanmax([F(idx1).psth_avg(idx_t),F(idx2).psth_avg(idx_t),0])+eps]);
    %         title(sprintf('Session %d\nCorrect\n p S=%.7f \nD=%.7f\n M=%.7f \nR=%.7f',multiple_session_list(i_s), Signif(1).task_signif_pval, Signif(2).task_signif_pval, Signif(3).task_signif_pval, Signif(4).task_signif_pval));
    ylabel('Spikes/s');
    title(sprintf('Error',roi_list(iROI),key.session));
    xlim([-3,3]);
    ylim(yl);
    xlabel('Time (s)');
    set(gca,'YTick',yl,'YTickLabel',{num2str(yl(1),'%.1f'), num2str(yl(2),'%.1f')});
    
    
    
    
    dir_save_figure = [dir_current_fig];
    if isempty(dir(dir_save_figure))
        mkdir (dir_save_figure)
    end

    filename=['ROI_' num2str(roi_list(iROI))];
    figure_name_out=[ dir_save_figure filename];
    eval(['print ', figure_name_out, ' -dtiff -cmyk -r200']);
    clf;
    
end
