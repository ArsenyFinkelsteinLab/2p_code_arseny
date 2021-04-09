%{
#  Significance of a activity for different task-related epochs/features
-> IMG.ROI
---
threshold_for_event   : double                           #      threshold in deltaf_overf
number_of_events       : int           #

%}

classdef IncludeROI4 < dj.Computed
    properties
        %         keySource = EXP.Session & EPHYS.TrialSpikes
        keySource = (EXP2.Session  & IMG.ROI & IMG.PlaneDirectory);
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
            
            key=fetch(EXP2.Session & key);
            key.threshold_for_event = 0.5;
            minimal_number_of_suprahtreshold_events = 10; %will affect in which directory the plot will be saved
            running_window=60; %seconds
            MinPeakDistance = 5; %seconds
            
            dir_base =fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\ROI\'];
            
            
            
            close all;
            
            %Graphics
            %---------------------------------
            figure;
            set(gcf,'DefaultAxesFontName','helvetica');
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
            set(gcf,'PaperOrientation','portrait');
            set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
            set(gcf,'color',[1 1 1]);
            
            panel_width=0.8;
            panel_height=0.25;
            horizontal_distance=0.3;
            vertical_distance=0.3;
            
            position_x(1)=0.1;
            position_x(end+1)=position_x(end) + horizontal_distance;
            
            position_y(1)=0.65;
            position_y(end+1)=position_y(end) - vertical_distance;
            position_y(end+1)=position_y(end) - vertical_distance;
            
            
            
            
            
            
            session_date = fetch1(EXP2.Session & key,'session_date');
            dir_current_fig = [dir_current_fig 'anm' num2str(key.subject_id) '\' session_date '\'];
            dir_current_fig_active = [dir_current_fig 'active\'];
            dir_current_fig_silent = [dir_current_fig 'silent\'];
            
            if isempty(dir(dir_current_fig_active))
                mkdir (dir_current_fig_active)
            end
            if isempty(dir(dir_current_fig_silent))
                mkdir (dir_current_fig_silent)
            end
            
            roi_list = fetchn(IMG.ROI & key, 'roi_number','ORDER BY roi_number');
            
            key2=fetch(IMG.ROI&key,'ORDER BY roi_number');
            
            
            warning('off','all')
            roi_list_subsampled =roi_list(1:100:end);
            
            for iROI = 1:numel(roi_list)
                key.roi_number = roi_list (iROI);
                kkk.plane = key2(iROI).plane_num;
                frame_rate= (fetchn(IMG.FOVEpoch & key & kkk, 'imaging_frame_rate'));
                frame_rate=frame_rate(1); %assuming same frame rate for all session epochs
                F=fetchn(IMG.ROITrace & key,'f_trace','ORDER BY session_epoch_number');
                F=cell2mat(F');
                time = [1:1:numel(F)]/frame_rate;
                %                 Spk=fetchn(IMG.ROISpikes & key,'spikes_trace','ORDER BY session_epoch_number');
                %                 Spk=cell2mat(Spk');
                
                %                 running_min=movmin(Ftrial,[0 running_window*frame_rate]);
                %                 baseline=movmax(running_min,[0  running_window*frame_rate]); %running max of the running min
                %                 baseline=running_min;
                
                Fs=smoothdata(F,'gaussian',(running_window*frame_rate)/5);
                %                 Fs=F;
                
                running_min=movmin(Fs,[running_window*frame_rate running_window*frame_rate],'Endpoints','fill');
                %                 running_min =[running_min  zeros(1,running_window*frame_rate)+running_min(end)];
                baseline=movmax(running_min,[running_window*frame_rate running_window*frame_rate],'Endpoints','fill'); %running max of the running min
                %                 baseline =[baseline  zeros(1,running_window*frame_rate)+baseline(end)];
                baseline2=smoothdata(baseline,'gaussian',running_window*frame_rate);
                
                
                %                                            running_min=movmin(Fs,[0 running_window*frame_rate],'Endpoints','discard');
                %                running_min =[running_min  zeros(1,running_window*frame_rate)+running_min(end)];
                %                                 baseline=movmax(running_min,[0 running_window*frame_rate],'Endpoints','discard'); %running max of the running min
                %                                baseline =[baseline  zeros(1,running_window*frame_rate)+baseline(end)];
                %                 baseline2=smoothdata(baseline,'gaussian',running_window*frame_rate);
                
                
                
                %                 baseline2=movmedian(baseline,[0 running_window*frame_rate]);
                dFF = (F-baseline2)./baseline2; %deltaF over F
                
                [~,idx_peaks]=findpeaks(dFF,'MinPeakDistance',MinPeakDistance*frame_rate,'MinPeakHeight',key.threshold_for_event);
                
                
                key2(iROI).number_of_events = numel(idx_peaks);
                key2(iROI).threshold_for_event = key.threshold_for_event;
                
                if ismember(iROI, roi_list_subsampled)
                    
                    %% Plotting
                    ax(1)=axes('position',[position_x(1), position_y(1), panel_width, panel_height]);
                    hold on;
                    plot(time, F,'-b')
                    plot(time, baseline2,'-r')
                    plot(time, baseline,'-g')
                    ylabel('F');
                    xlabel ('Time (s)');
                    title(sprintf('ROI = %d',roi_list(iROI)));
                    
                    ax(2)=  axes('position',[position_x(1), position_y(2), panel_width, panel_height]);
                    hold on;
                    plot(time, dFF,'-b')
                    plot(time(idx_peaks), dFF(idx_peaks),'.r')
                    ylabel('deltaF/F');
                    xlabel ('Time (s)');
                    title(sprintf('# Peaks = %d',numel(idx_peaks)));
                    
                    
                    %                                 ax(3)=  axes('position',[position_x(1), position_y(3), panel_width, panel_height]);
                    %                                 [~,idx_peaks3]=findpeaks(Spk,'MinPeakDistance',frame_rate,'MinPeakHeight',2);
                    %                                 plot(Spk);
                    %                                 ylabel('Spikes');
                    %                                 title(sprintf('# Peaks = %d',numel(idx_peaks3)));
                    %
                    linkaxes(ax,'x');
                    
                    
                    filename=['ROI_' num2str(roi_list(iROI))];
                    
                    if numel(idx_peaks)>=minimal_number_of_suprahtreshold_events
                        figure_name_out=[ dir_current_fig_active filename];
                        eval(['print ', figure_name_out, ' -dtiff  -r50']);
                    else
                        figure_name_out=[ dir_current_fig_silent filename];
                        eval(['print ', figure_name_out, ' -dtiff  -r50']);
                    end
                    clf
                end
                warning('on','all')
            end
            
            
            insert(self,key2);
            
        end
    end
end