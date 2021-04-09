function fn_proj_across_days_cluster (k, first_date, dir_save_figure_base)


k.session_date=first_date;
key=fetch(EXP.Session & k);
roi_list=fetchn(IMG.ROI & key,'roi_number', 'ORDER BY roi_number');

kk.multiple_sessions_uid = fetchn(IMG.FOVmultiSessions & key,'multiple_sessions_uid');

multiple_session_list = fetchn(IMG.FOVmultiSessions & kk,'session');


panel_width1=0.12;
panel_height1=0.1;

horizontal_distance1=0.2;

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



fov_name = fetchn(IMG.FOV & key, 'fov_name');

mode_names= {'Stimulus','LateDelay','Movement','Ramping'};


for i_s = 1:1:numel(multiple_session_list)
    
    
    key.session = multiple_session_list(i_s);
    %         F=fetch(ANLI.ProjTrialAverage & key,'*');
    FCluster=fetch(ANLI.ProjClusterTrialAverage  & key,'*');
    time_sample_start = FCluster(1).time_sample_start;
    time_sample_end = FCluster(1).time_sample_end;
    
    
    trial_name_list ={'l','r'};
    epoch_list=fetchn(ANLI.EpochName,'trial_epoch_name');
    counter=1;
    for i_tname =1:1:numel(trial_name_list)
        for i_e =1:1:numel(epoch_list)
            axes('position',[position_x1(counter) position_y1(i_s) panel_width1 panel_height1]);
            trial_epoch_name=epoch_list{i_e};
            trial_type_name=trial_name_list{i_tname};
            fn_plot_proj_cluster  (FCluster, trial_epoch_name, trial_type_name  ,time_sample_start, time_sample_end);
            if i_s==1
                title(sprintf('Clustering based\n on %s',trial_epoch_name));
            end
             if counter==1
            ylabel(sprintf('Session %d\n Proj. (a.u.)' ,multiple_session_list(i_s)));
           end
            counter=counter+1;
        end
    end
    
    
    
end


dir_save_figure = [dir_save_figure_base '\'];
if isempty(dir(dir_save_figure))
    mkdir (dir_save_figure)
end

filename=['from' first_date ];
figure_name_out=[ dir_save_figure filename];
eval(['print ', figure_name_out, ' -dtiff -cmyk -r200']);
clf;


