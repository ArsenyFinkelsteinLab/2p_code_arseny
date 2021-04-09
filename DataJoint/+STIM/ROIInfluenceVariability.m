%{
# ROI responses to each photostim group.  Zscoring. Spikes.
-> IMG.PhotostimGroup
-> IMG.ROI
---
response_trials        : blob                # response amlitude at each trial
response_trace_trials  : longblob          # response trace at each trial

%}


classdef ROIInfluenceVariability < dj.Computed
    properties
        %         keySource = (EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI & IMG.PlaneCoordinates)& (STIMANAL.SessionEpochsIncluded& 'stimpower_percent=15' & 'flag_include=1')
        %                 keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI;
        keySource = EXP2.SessionEpoch & STIMANAL.ROIResponseDirectVariability;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
            min_distance_to_closest_target=50; % in microns
            
            close all;
            frame_window_short=[40,40]/4;
            frame_window_long=[50,100]/2;
            flag_baseline_trial_or_avg=0; %1 baseline per trial, 0 - baseline averaged across trials
            
            
            zoom =fetch1(IMG.FOVEpoch & key,'zoom');
            kkk.scanimage_zoom = zoom;
            pix2dist=  fetch1(IMG.Zoom2Microns & kkk,'fov_microns_size_x') / fetch1(IMG.FOV & key, 'fov_x_size');
            try
                frame_rate= fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
            catch
                frame_rate= fetch1(IMG.FOV & key, 'imaging_frame_rate');
            end
            min_distance_to_closest_target_pixels=min_distance_to_closest_target/pix2dist;
            
            rel=STIM.ROIInfluence5 & 'response_p_value1<=0.0001' & sprintf('response_distance_lateral_um >%.2f', min_distance_to_closest_target_pixels) & 'response_mean>0';
            
            if flag_baseline_trial_or_avg==0 %baseline averaged across trials
                dir_suffix= 'baseline_avg';
            elseif flag_baseline_trial_or_avg==1 % baseline per trial
                dir_suffix= 'baseline_trial';
            elseif flag_baseline_trial_or_avg==2 % global baseline
                dir_suffix= 'baseline_global';
            end
            session_date = fetch1(EXP2.Session & key,'session_date');
            
            
            
            smooth_bins=1;
            
            
            
            
            
            
            
            %Graphics
            %---------------------------------
            figure;
            set(gcf,'DefaultAxesFontName','helvetica');
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
            set(gcf,'PaperOrientation','portrait');
            set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
            set(gcf,'color',[1 1 1]);
            
            panel_width=0.2;
            panel_height=0.25;
            horizontal_distance=0.2;
            vertical_distance=0.3;
            
            position_x(1)=0.13;
            position_x(end+1)=position_x(end) + horizontal_distance;
            
            position_y(1)=0.7;
            
            
            G=fetch(IMG.PhotostimGroupROI & STIM.ROIResponseDirect & key,'*','ORDER BY photostim_group_num');
            
            group_list=[G.photostim_group_num];
            
            
            
            
            time=(-frame_window_long(1):1:frame_window_long(2)-1)/frame_rate;
            
            
            
            for i_g=1:1:numel(group_list)
                key.photostim_group_num = group_list(i_g);
                
                
                k1=key;
                signif_roi=[];
                %     signif_roi = fetchn(rel & k1 ,'roi_number','ORDER BY roi_number');
                %     response_p_value = fetchn(rel & k1 ,'response_p_value','ORDER BY roi_number');
                %     response_mean = fetchn(rel & k1 ,'response_mean','ORDER BY roi_number');
                %     response_distance_pixels = fetchn(rel & k1 ,'response_distance_pixels','ORDER BY roi_number');  % in pixels
                %     response_distance_pixels = response_distance_pixels * pix2dist; % in microns
                DATA =fetch(rel & k1 ,'*','ORDER BY roi_number');
                signif_roi = [DATA.roi_number];
                %     flag_distance_flag=5
                %         if flag_distance_flag==0 % lateral distance
                %         distance=[DATA.response_distance_pixels];
                %         distance=pix2dist*distance;
                %     elseif flag_distance_flag==1 % axial distance
                %         distance=[DATA.response_distance_axial_um];
                %     elseif flag_distance_flag==2 % 3D distance
                %         distance=[DATA.response_distance_3d_um];
                %         end
                
                
                response_trials_direct = fetchn(STIMANAL.ROIResponseDirectVariability & key,'response_trials');
                response_trials_direct=response_trials_direct{1};
                %                 idx_weak = response_trials_direct<=0.25;
                %                 idx_strong = response_trials_direct>=0.75;
                idx_weak = response_trials_direct<=prctile(response_trials_direct,25);
                idx_strong = response_trials_direct>prctile(response_trials_direct,75);
                idx_no_response = response_trials_direct<=0.12;
                
                for i_r = 1:1:numel(signif_roi)
                    k2=k1;
                    k2.roi_number = signif_roi(i_r);
                    
                    
                    
                    photostim_start_frame = fetch1(IMG.PhotostimGroup & STIM.ROIResponseDirect & k2,'photostim_start_frame');
                    
                    f_trace_direct = fetch1(IMG.ROITrace & k2,'f_trace');
                    
                    global_baseline=mean( f_trace_direct);
                    
                    timewind_response = [ 0 2];
                    timewind_baseline1 = [ -3 0];
                    timewind_baseline2  = [-3 0] ;
                    timewind_baseline3  = [ -3 0];
                    [StimStat,StimTrace] = fn_compute_photostim_response_variability (f_trace_direct , photostim_start_frame, timewind_response, timewind_baseline1,timewind_baseline2,timewind_baseline3, flag_baseline_trial_or_avg, global_baseline, time);
                    
                    
                    
                    hold on;
                    
                    %% below 25 response percentile
                    y=StimTrace.response_trace_trials(idx_weak,:);
                    y_smooth=  movmean(mean(y),[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    ystem=std(y)./sqrt(size(y,1));
                    ystem_smooth=  movmean(ystem,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    
                    max_epoch=max(y_smooth);
                    min_epoch=min(y_smooth);
                    hold on;
                    plot(time(1:end-1),y_smooth,'Color',[ 1 0 0]);
                    shadedErrorBar(time(1:end-1),y_smooth,ystem_smooth,'lineprops',{'-','Color',[0 0 1]})
                    
                    
                    %% no response
                    if sum(idx_no_response)>=2
                        y=StimTrace.response_trace_trials(idx_no_response,:);
                        y_smooth=  movmean(mean(y),[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                        ystem=std(y)./sqrt(size(y,1));
                        ystem_smooth=  movmean(ystem,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                        
                        max_epoch=max(y_smooth);
                        min_epoch=min(y_smooth);
                        hold on;
                        plot(time(1:end-1),y_smooth,'Color',[ 1 0 0]);
                        shadedErrorBar(time(1:end-1),y_smooth,ystem_smooth,'lineprops',{'-','Color',[0 0 0]})
                    end
                    
                    
                    
                    
                    %% above 75 response percentile
                    y=StimTrace.response_trace_trials(idx_strong,:);
                    y_smooth=  movmean(mean(y),[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    ystem=std(y)./sqrt(size(y,1));
                    ystem_smooth=  movmean(ystem,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    
                    max_epoch=max(y_smooth);
                    min_epoch=min(y_smooth);
                    hold on;
                    plot(time(1:end-1),y_smooth,'Color',[ 1 0 0]);
                    shadedErrorBar(time(1:end-1),y_smooth,ystem_smooth,'lineprops',{'-','Color',[1 0 0]})
                    
                    
                    
                    
                    
                    ylim ([min([-0.2,min_epoch]),max([0.5 ,max_epoch])]);
                    xlabel('Time (s)');
                    ylabel('\Delta F/F')
                    %         title(sprintf('Coupled responses \n Target # %d   ROI=%d \n Distance = %.1f (um), Amplitude %.2f, p-val=%.6f  \n',G(i_g).photostim_group_num, k2.roi_number, DATA(i_r).response_distance_pixels * pix2dist,  DATA(i_r).response_mean,  DATA(i_r).response_p_value));
                    
                    
                    %         title(sprintf('Photostim group=%d    ROI=%d    \n p=%.6f  distance = %.1f (pixels) response mean %.2f',G(i_g).photostim_group_num, k2.roi_number, response_p_value(i_r), response_distance_pixels(i_r), response_mean(i_r)));
                    set(gca,'FontSize',60);
                    %                     title(sprintf('anm %d, session %d \n Coupled responses \n Target # %d   ROI=%d \n Distance lateral = %.1f (um) \n Distance axial = %.1f (um) \n Distance 3D = %.1f (um)\n Amplitude %.2f, p-val=%.6f  \n \n \n',k2.subject_id,k2.session, G(i_g).photostim_group_num, k2.roi_number, DATA(i_r).response_distance_lateral_um, DATA(i_r).response_distance_axial_um, DATA(i_r).response_distance_3d_um, DATA(i_r).response_mean,  DATA(i_r).response_p_value1),'FontSize',10);
                    
                    set(gca,'Ytick',[-0.2, 0, 0.5]);
                    clf
                    
                    
                end
            end
            
            
            insert(self, k_response);
        end
    end
end
