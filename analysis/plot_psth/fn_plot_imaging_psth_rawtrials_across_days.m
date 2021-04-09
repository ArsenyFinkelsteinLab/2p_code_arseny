function fn_populate_imaging_psth_rawtrials_across_days (k, first_date, dir_save_figure_base)


k.session_date=first_date;
key=fetch(EXP2.Session & k);
roi_list=fetchn(IMG.ROI & key,'roi_number', 'ORDER BY roi_number');

kk.multiple_sessions_uid = fetchn(IMG.FOVmultiSessions & key,'multiple_sessions_uid');

multiple_session_list = fetchn(IMG.FOVmultiSessions & kk,'session');


panel_width1=0.07;
panel_width2=0.3;

panel_height1=0.1;
vertical_distance1=0.13;


position_x1(1)=0.05;
position_x1(end+1)=0.19;
position_x1(end+1)=0.29;
position_x1(end+1)=0.65;
position_x1(end+1)=0.74;
position_x1(end+1)=0.83;
position_x1(end+1)=0.91;

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
    for i_type = 1:1:numel(trial_type_name_list)
        key_trialtype.trial_type_name = trial_type_name_list {i_type};
        for i_s = 1:1:numel(multiple_session_list)
            
            
            key.session = multiple_session_list(i_s);
            key.roi_number=roi_list(iROI);
            
            baseline_median(i_s)  = fetchn(IMG.ROI & key,'baseline_fl_median');
            baseline_trials  = cell2mat(fetchn(IMG.ROI & key,'baseline_fl_trials'));
            
            
            
            F=fetch(ANLI.FPSTHaverage & key,'*');
            
            
            
            time_sample_start = F(1).time_sample_start;
            time_sample_end = F(1).time_sample_end;
            
            
            % Hit
            axes('position',[position_x1(2) position_y1(i_s) panel_width1 panel_height1]);
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
            if i_s==1
                title(sprintf('ROI %d\nCorrect',iROI));
            end
            ylabel([sprintf('Session %d\n',multiple_session_list(i_s)), '\DeltaF/F' ]);
            xlim([-3,3]);
            ylim(yl);
            xlabel('Time (s)');
            set(gca,'YTick',yl,'YTickLabel',{num2str(yl(1),'%.1f'), num2str(yl(2),'%.1f')});
            
            %         % Miss     %a(i_s)=
            %         axes('position',[position_x1(i_s) position_y1(2) panel_width1 panel_height1]);
            %         hold on;
            %         idx1=find(strcmp({F.outcome},'miss') & strcmp({F.trial_type_name},'l'));
            %         t=F(idx1).psth_timestamps;
            %         idx_t=(t<3);
            %         shadedErrorBar(t(idx_t) ,F(idx1).psth_avg(idx_t), F(idx1).psth_stem(idx_t),'lineprops',{'-','Color','r','markeredgecolor','r','markerfacecolor','r','linewidth',1});
            %         idx2=find(strcmp({F.outcome},'miss') & strcmp({F.trial_type_name},'r'));
            %         shadedErrorBar(t(idx_t) ,F(idx2).psth_avg(idx_t), F(idx2).psth_stem(idx_t),'lineprops',{'-','Color','b','markeredgecolor','b','markerfacecolor','b','linewidth',1});
            %         plot([time_sample_start ,time_sample_start],[-1000,1000],'-k');
            %         plot([time_sample_end,time_sample_end],[-1000,1000],'-k');
            %         plot([0,0],[-1000,1000],'-k');
            %         yl=( [nanmin([F(idx1).psth_avg(idx_t), F(idx2).psth_avg(idx_t),0]) , nanmax([F(idx1).psth_avg(idx_t), F(idx2).psth_avg(idx_t),0])+eps]);
            %         title(sprintf('Error'));
            %         if i_s==1
            %             ylabel('\DeltaF/F');
            %         end
            %         xlim([-4,3]);
            %         ylim(yl);
            %         xlabel('Time (s)');
            %         set(gca,'YTick',yl,'YTickLabel',{num2str(yl(1),'%.1f'), num2str(yl(2),'%.1f')});
            
            
            
            
            
            
            % Baseline change over time (trials)
            axes('position',[position_x1(1) position_y1(i_s) panel_width1 panel_height1]);
            hold on;
                smooth_b=smooth(baseline_trials,10,'rlowess',1);
            plot(baseline_trials);
            plot(smooth_b,'-k');
            ylabel('Baseline F');
            xlabel('Trials')
            
            
            Ftrial=fetch(ANLI.FPSTHtrial & key & key_trialtype & 'outcome="hit"' ,'*','ORDER BY trial');
            %             time_abs=cellfun(@abs,{Ftrial.psth_timestamps},'UniformOutput',false);
            %             [~,idx]=cellfun(@min,time_abs);
            
            
            axes('position',[position_x1(3) position_y1(i_s) panel_width2 panel_height1]);
            hold on;
            Ftrial_concat=[Ftrial.psth_trial];
            yl=([nanmin([Ftrial_concat,0]),nanmax([Ftrial_concat,eps])]);
            
            
            tot_frames=0;
            for i_tr=1:1:numel(Ftrial)
                time_abs = abs(Ftrial(i_tr).psth_timestamps);
                [~,idx]=min(time_abs);
                idx_go (i_tr) = idx +tot_frames;
                tot_frames= tot_frames + numel(time_abs);
                plot([idx_go(i_tr)  idx_go(i_tr)],yl,'-k');
            end
            
            plot(Ftrial_concat,'Color',trial_color {i_type});
            ylim(yl);
            xlim([0 tot_frames]);
            ylabel('\DeltaF/F');
            xlabel('Frames');
            
            box off;
            
            
            
            
            
            trial2plot=floor(linspace(5,numel(Ftrial)-5,12));
            counter=1;
            for ii= 1:1:numel(trial2plot)/3
                for jj= 1:1:numel(trial2plot)/4
                    axes('position',[position_x1(3+ii) position_y1(i_s)+position_y2(jj) panel_width3 panel_height2]);
                    hold on;
                    tr=trial2plot(counter);
                    plot([0,0],yl,'-k');
                    plot(Ftrial(tr).psth_timestamps ,Ftrial(tr).psth_trial,'Color',trial_color {i_type})
                    ylim(yl);
                    xlim([-3,3]);
                    if counter==1
                        xlabel('Time (s)');
                        ylabel('\DeltaF/F');
                        set(gca,'Ytick',[0 yl(2)],'Yticklabels',[{0},{sprintf('%.1f',yl(2))}]);
                    else
                        set(gca,'Ytick',[0 yl(2)],'Yticklabels',[]);
                        set(gca,'Xticklabels',[]);
                        axis off;
                    end
                    box off;
                    
                    counter=counter+1;
                end
            end
        end
        
        
        
        dir_save_figure = [dir_save_figure_base fov_name{1} 'from' first_date '\'];
        if isempty(dir(dir_save_figure))
            mkdir (dir_save_figure)
        end
        
        filename=['ROI_' num2str(iROI) '_' trial_type_name_list{i_type}];
        figure_name_out=[ dir_save_figure filename];
        eval(['print ', figure_name_out, ' -dtiff -cmyk -r200']);
        clf;
    end
end
