function fn_plot_imaging_psth_across_days (k, first_date, dir_save_figure_base,rel_inclusion)


k.session_date=first_date;
key=fetch(EXP2.Session & k);
roi_list=fetchn(IMG.ROI & rel_inclusion & key,'roi_number', 'ORDER BY roi_number');

kk.multiple_sessions_uid = fetchn(IMG.FOVmultiSessions & key,'multiple_sessions_uid');

multiple_session_list = fetchn(IMG.FOVmultiSessions & kk,'session');


panel_width1=0.6/numel(multiple_session_list);
panel_height1=0.11;
horizontal_distance1=0.8/numel(multiple_session_list);
vertical_distance1=0.17;


position_x1(1)=0.06;

position_y1(1)=0.8;
position_y1(2)=position_y1(1)-vertical_distance1;
position_y1(3)=position_y1(2)-vertical_distance1;
position_y1(4)=position_y1(3)-vertical_distance1;





fov_name = fetchn(IMG.FOV & key, 'fov_name');

for iROI = 1:numel(roi_list) %15,49,34,25
    
    for i_s = 1:1:numel(multiple_session_list)
        
        position_x1(end+1)=position_x1(end)+horizontal_distance1;
        
        key.session = multiple_session_list(i_s);
        key.roi_number=roi_list(iROI);
        
        baseline_median(i_s)  = fetchn(IMG.ROI & key,'baseline_fl_median');
        baseline_trials  = cell2mat(fetchn(IMG.ROI & key,'baseline_fl_trials'));
        
        F=fetch(ANLI.FPSTHaverage & key,'*');
        
      
       
        time_sample_start = F(1).time_sample_start;
        time_sample_end = F(1).time_sample_end;
        
        Signif=fetch(ANLI.TaskSignifROI & key,'*', 'ORDER BY task_signif_name_uid');
        
        % Hit
        axes('position',[position_x1(i_s) position_y1(1) panel_width1 panel_height1]);
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
        title(sprintf('Session %d\nCorrect\n p S=%.7f \nD=%.7f\n M=%.7f \nR=%.7f',multiple_session_list(i_s), Signif(1).task_signif_pval, Signif(2).task_signif_pval, Signif(3).task_signif_pval, Signif(4).task_signif_pval));
        if i_s==1
            ylabel('\DeltaF/F');
                    title(sprintf('ROI %d\nSession %d\nCorrect\n p S=%.5f \nD=%.5f\n M=%.5f \nR=%.5f',roi_list(iROI),multiple_session_list(i_s), Signif(1).task_signif_pval, Signif(2).task_signif_pval, Signif(3).task_signif_pval, Signif(4).task_signif_pval));
        end
        xlim([-4,3]);
        ylim(yl);
        xlabel('Time (s)');
        set(gca,'YTick',yl,'YTickLabel',{num2str(yl(1),'%.1f'), num2str(yl(2),'%.1f')});
        
        % Miss     %a(i_s)=
        axes('position',[position_x1(i_s) position_y1(2) panel_width1 panel_height1]);
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
        yl=( [nanmin([F(idx1).psth_avg(idx_t), F(idx2).psth_avg(idx_t),0]) , nanmax([F(idx1).psth_avg(idx_t), F(idx2).psth_avg(idx_t),0])+eps]);
        title(sprintf('Error'));
        if i_s==1
            ylabel('\DeltaF/F');
        end
        xlim([-4,3]);
        ylim(yl);
        xlabel('Time (s)');
        set(gca,'YTick',yl,'YTickLabel',{num2str(yl(1),'%.1f'), num2str(yl(2),'%.1f')});
        
        
        % Baseline change over time (trials)
        axes('position',[position_x1(i_s) position_y1(3) panel_width1 panel_height1]);
        hold on;
                smooth_b=smooth(baseline_trials,10,'rlowess',1);
        plot(baseline_trials);
        plot(smooth_b,'-k');
        
        xlabel('Trials')
        if i_s==1
            ylabel('Baseline Fluorescence');
        end
         
    
    end
    
    
    
    axes('position',[position_x1(1) position_y1(4) panel_width1 panel_height1]);
    hold on;
    plot(multiple_session_list,baseline_median,'.-');
    xlabel('Session #');
    ylabel(sprintf('Median \nBaseline Fluorescence'));
    xlimits=[multiple_session_list(1) multiple_session_list(end)];
    set(gca,'xlim', xlimits,'Xtick',multiple_session_list);
    ylim([0 nanmax([baseline_median,eps])]);
    
    dir_save_figure = [dir_save_figure_base fov_name{1} 'from' first_date '\'];
    if isempty(dir(dir_save_figure))
        mkdir (dir_save_figure)
    end
    
    filename=['ROI_' num2str(roi_list(iROI))];
    figure_name_out=[ dir_save_figure filename];
    eval(['print ', figure_name_out, ' -dtiff -cmyk -r200']);
    clf;
    
end
