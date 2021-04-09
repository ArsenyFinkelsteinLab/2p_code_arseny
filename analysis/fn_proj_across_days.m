function fn_proj_across_days (k, first_date, dir_save_figure_base)


k.session_date=first_date;
key=fetch(EXP.Session & k);
roi_list=fetchn(IMG.ROI & key,'roi_number', 'ORDER BY roi_number');

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

mode_names= {'Stimulus','LateDelay','Movement','Ramping'};

for i_m= 1:numel(mode_names) 
    key.mode_type_name = mode_names{i_m};
    for i_s = 1:1:numel(multiple_session_list)
        
        position_x1(end+1)=position_x1(end)+horizontal_distance1;
        
        key.session = multiple_session_list(i_s);
        F=fetch(ANLI.ProjTrialAverage & key,'*');
        
      
       
        time_sample_start = F(1).time_sample_start;
        time_sample_end = F(1).time_sample_end;
        
%         Signif=fetch(ANLI.TaskSignifROI & key,'*', 'ORDER BY task_signif_name_uid');
        
        % Hit
        axes('position',[position_x1(i_s) position_y1(1) panel_width1 panel_height1]);
        hold on;
        idx1=find(strcmp({F.outcome},'hit') & strcmp({F.trial_type_name},'l'));
        t=F(idx1).psth_timestamps;
        idx_t=(t<3);
        plot(t(idx_t) ,F(idx1).proj_average(idx_t),'-r');
        idx2=find(strcmp({F.outcome},'hit') & strcmp({F.trial_type_name},'r'));
        plot(t(idx_t) ,F(idx2).proj_average(idx_t),'-b');
        plot([time_sample_start ,time_sample_start],[-1000,1000],'-k');
        plot([time_sample_end,time_sample_end],[-1000,1000],'-k');
        plot([0,0],[-1000,1000],'-k');
        yl=( [nanmin([F(idx1).proj_average(idx_t),F(idx2).proj_average(idx_t),0]) , nanmax([F(idx1).proj_average(idx_t), F(idx2).proj_average(idx_t),0])+eps]);
        title(sprintf('Session %d\nCorrect\n',multiple_session_list(i_s)));
        if i_s==1
            ylabel('Proj. (a.u.)');
                    title(sprintf('%s mode\nSession %d\nCorrect\n', mode_names{i_m} ,multiple_session_list(i_s)));
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
        plot(t(idx_t) ,F(idx1).proj_average(idx_t),'-r');
        idx2=find(strcmp({F.outcome},'miss') & strcmp({F.trial_type_name},'r'));
        plot(t(idx_t) ,F(idx2).proj_average(idx_t),'-b');
        plot([time_sample_start ,time_sample_start],[-1000,1000],'-k');
        plot([time_sample_end,time_sample_end],[-1000,1000],'-k');
        plot([0,0],[-1000,1000],'-k');
        yl=( [nanmin([F(idx1).proj_average(idx_t),F(idx2).proj_average(idx_t),0]) , nanmax([F(idx1).proj_average(idx_t), F(idx2).proj_average(idx_t),0])+eps]);
        title(sprintf('Error'));
        if i_s==1
            ylabel('Proj. (a.u.)');
        end
        xlim([-4,3]);
        ylim(yl);
        xlabel('Time (s)');
        set(gca,'YTick',yl,'YTickLabel',{num2str(yl(1),'%.1f'), num2str(yl(2),'%.1f')});
        
    end
    
    
    dir_save_figure = [dir_save_figure_base fov_name{1} 'from' first_date '\'];
    if isempty(dir(dir_save_figure))
        mkdir (dir_save_figure)
    end
    
    filename=['Mode_' mode_names{i_m}];
    figure_name_out=[ dir_save_figure filename];
    eval(['print ', figure_name_out, ' -dtiff -cmyk -r200']);
    clf;
    
end
