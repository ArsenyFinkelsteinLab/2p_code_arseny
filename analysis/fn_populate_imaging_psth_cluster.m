function fn_populate_imaging_psth_cluster (k, first_date, dir_save_figure_base, rel_inclusion)


k.session_date=first_date;
key=fetch(EXP.Session & k);
roi_list=fetchn(IMG.ROI & rel_inclusion & key,'roi_number', 'ORDER BY roi_number');

kk.multiple_sessions_uid = fetchn(IMG.FOVmultiSessions & key,'multiple_sessions_uid');

multiple_session_list = fetchn(IMG.FOVmultiSessions & kk,'session');


panel_width1=0.07;
panel_height1=0.1;

horizontal_distance1=0.13;

vertical_distance1=0.13;


position_x1(1)=0.07;
position_x1(2)=position_x1(1)+horizontal_distance1;
position_x1(3)=position_x1(2)+horizontal_distance1;
position_x1(4)=position_x1(3)+horizontal_distance1;
position_x1(5)=position_x1(4)+horizontal_distance1;
position_x1(6)=position_x1(5)+horizontal_distance1;
position_x1(7)=position_x1(6)+horizontal_distance1;

position_y1(1)=0.85;
position_y1(2)=position_y1(1)-vertical_distance1;
position_y1(3)=position_y1(2)-vertical_distance1;
position_y1(4)=position_y1(3)-vertical_distance1;
position_y1(5)=position_y1(4)-vertical_distance1;
position_y1(6)=position_y1(5)-vertical_distance1;
position_y1(7)=position_y1(6)-vertical_distance1;

panel_width3=0.075;
panel_height2=0.03;
vertical_distance2=0.03;
position_y2(1)=0;
position_y2(2)=position_y2(1)+vertical_distance2;
position_y2(3)=position_y2(2)+vertical_distance2;
position_y2(4)=position_y2(3)+vertical_distance2;
position_y2(5)=position_y2(4)+vertical_distance2;


fov_name = fetchn(IMG.FOV & key, 'fov_name');
trial_type_name_list={'l','r'};
trial_color{1}=[1 0 0];
trial_color{2}=[0 0 1];

for iROI = 1:numel(roi_list)
    for i_s = 1:1:numel(multiple_session_list)
        
        key.session = multiple_session_list(i_s);
        key.roi_number=roi_list(iROI);
        
        F=fetch(ANLI.FPSTHaverage & key,'*');
        time_sample_start = F(1).time_sample_start;
        time_sample_end = F(1).time_sample_end;
        
        FCluster=fetch(ANLI.FPSTHaverageClusterbased  & key,'*');
        
        
        
        % Hit
        axes('position',[position_x1(1) position_y1(i_s) panel_width1 panel_height1]);
        outcome='hit';
        fn_plot_psth  (F,outcome, time_sample_start, time_sample_end);
        if i_s==1
            title(sprintf('ROI %d\nCorrect',roi_list(iROI)));
        end
        ylabel([sprintf('Session %d\n',multiple_session_list(i_s)), '\DeltaF/F' ]);
        
        
        
        trial_name_list ={'l','r'};
        epoch_list=fetchn(ANLI.EpochName,'trial_epoch_name');
        counter=1;
        for i_tname =1:1:numel(trial_name_list)
            for i_e =1:1:numel(epoch_list)
                axes('position',[position_x1(counter+1) position_y1(i_s) panel_width1 panel_height1]);
                trial_epoch_name=epoch_list{i_e};
                trial_type_name=trial_name_list{i_tname};
                fn_plot_psth_cluster  (FCluster, trial_epoch_name, trial_type_name  ,time_sample_start, time_sample_end);
                if i_s==1
                    title(sprintf('Clustering based\n on %s',trial_epoch_name));
                end
                counter=counter+1;
            end
        end
        
        
        
    end
    
    
    dir_save_figure = [dir_save_figure_base fov_name{1} 'from' first_date '\'];
    if isempty(dir(dir_save_figure))
        mkdir (dir_save_figure)
    end
    
    filename=['ROI_' num2str(roi_list(iROI))];
    figure_name_out=[ dir_save_figure filename];
    eval(['print ', figure_name_out, ' -dtiff -cmyk -r200']);
    clf;
end
end
