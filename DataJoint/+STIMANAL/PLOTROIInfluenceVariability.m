%{
# ROI responses to each photostim group.
-> IMG.PhotostimGroup
-> IMG.ROI
---
%}


classdef PLOTROIInfluenceVariability < dj.Computed
    properties
        %         keySource = (EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI & IMG.PlaneCoordinates)& (STIMANAL.SessionEpochsIncluded& 'stimpower=150' & 'flag_include=1')
        %                 keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI;
        keySource = EXP2.SessionEpoch & STIMANAL.ROIResponseDirectVariability;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Photostim\photostim_traces\coupled_variability\'];
            
            session_date = fetch1(EXP2.Session & key,'session_date');
            dir_current_fig = [dir_current_fig '\anm' num2str(key.subject_id) '\session_' num2str(key.session) '_' session_date  '\epoch' num2str(key.session_epoch_number) '\'];
            
            
            min_distance_to_closest_target=30; % in microns
            
            close all;
            frame_window_short=[40,40]/4;
            frame_window_long=[56,110]/2;
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
            
            rel=STIM.ROIInfluence5 & 'response_p_value1<=0.001' & sprintf('response_distance_lateral_um >%.2f', min_distance_to_closest_target_pixels) & 'response_mean>0';
            
            if flag_baseline_trial_or_avg==0 %baseline averaged across trials
                dir_suffix= 'baseline_avg';
            elseif flag_baseline_trial_or_avg==1 % baseline per trial
                dir_suffix= 'baseline_trial';
            elseif flag_baseline_trial_or_avg==2 % global baseline
                dir_suffix= 'baseline_global';
            end
            session_date = fetch1(EXP2.Session & key,'session_date');
            
            
            
            smooth_bins=2;
            
            smooth_bins_single_trials=5;
            
            
            
            
            
            %Graphics
            %---------------------------------
            figure;
            set(gcf,'DefaultAxesFontName','helvetica');
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
            set(gcf,'PaperOrientation','portrait');
            set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
            set(gcf,'color',[1 1 1]);
            
            panel_width=0.25;
            panel_height=0.25;
            horizontal_distance=0.4;
            vertical_distance=0.35;
            
            position_x(1)=0.13;
            position_x(end+1)=position_x(end) + horizontal_distance;
            
            position_y(1)=0.5;
            position_y(end+1)=position_y(end) - vertical_distance;
            
            
            G=fetch(IMG.PhotostimGroupROI & (STIM.ROIResponseDirect & 'response_p_value1<=0.0001') & key ,'*','ORDER BY photostim_group_num');
            
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
                
                
                
                response_trace_trials_direct = fetch1(STIMANAL.ROIResponseDirectVariability & key,'response_trace_trials');
                time_vector_direct = fetch1(STIMANAL.ROIResponseDirectVariability & key,'time_vector');
                
                
                
                
                for i_r = 1:1:numel(signif_roi)
                    kk_insert = fetch( STIM.ROIResponseDirect & key);
                    kk_insert.roi_number =DATA(i_r).roi_number;
                    kk_insert.plane_num = DATA(i_r).plane_num;
                    
                    k_coupled.roi_number =DATA(i_r).roi_number;
                    k_coupled.plane_num = DATA(i_r).plane_num;

                   response_trace_trials_coupled = fetch1(STIMANAL.ROIInfluenceVariability & key & k_coupled,'response_trace_trials');
                    
                    
                    %% response pre-synaptic
                    %__________________________________________________________
                    
                    ax1=axes('position',[position_x(1), position_y(1), panel_width, panel_height]);
                    y=response_trace_trials_direct;
                    y_smooth=  movmean(mean(y),[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    ystem=std(y)./sqrt(size(y,1));
                    ystem_smooth=  movmean(ystem,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    max_epoch=max(y_smooth);
                    min_epoch=min(y_smooth);
                    hold on;
                    plot(time_vector_direct,y_smooth,'Color',[ 0 0 0],'LineWidth',3);
                    shadedErrorBar(time_vector_direct,y_smooth,ystem_smooth,'lineprops',{'-','Color',[0 0 0]})
                    ylim ([min([-0.2,min_epoch]),max([1 ,max_epoch])]);
                    ylabel('Response (\DeltaF/F)')
                    set(gca,'FontSize',24);
                    set(gca,'Ytick',[0, 1]);
                    xlim ([-5,10]);
                    title([sprintf('''Pre-synaptic''')]);
                    
                    
                    
                    %% response pre-synaptic - single trials
                    %__________________________________________________________
                    ax1=axes('position',[position_x(1), position_y(2), panel_width, panel_height]);
                    hold on
                    y=response_trace_trials_direct;
                    y_smooth=  movmean(mean(y),[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    max_epoch=max(y_smooth);
                    min_epoch=min(y_smooth);
                    hold on;
                    for i=1:1:size(response_trace_trials_direct,1)
                        xxx= movmean(response_trace_trials_direct(i,:),[smooth_bins_single_trials 0], 2, 'omitnan','Endpoints','shrink');
                        plot(time_vector_direct,xxx,'LineWidth',1);
                    end
                                        plot(time_vector_direct,y_smooth,'Color',[ 0 0 0],'LineWidth',3);
                    xlabel('        Time from photostimulation (s)');
                    ylabel('Response (\DeltaF/F)')
                    set(gca,'FontSize',24);
                    xlim ([-5,10]);
                    
                   
                    
                    %% response post-synaptic
                    %__________________________________________________________
                    
                    ax1=axes('position',[position_x(2), position_y(1), panel_width, panel_height]);
                    y=response_trace_trials_coupled;
                    y_smooth=  movmean(mean(y),[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    ystem=std(y)./sqrt(size(y,1));
                    ystem_smooth=  movmean(ystem,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    max_epoch=max(y_smooth);
                    min_epoch=min(y_smooth);
                    hold on;
                    plot(time(1:end-1),y_smooth,'Color',[ 0 0 0],'LineWidth',3);
                    shadedErrorBar(time(1:end-1),y_smooth,ystem_smooth,'lineprops',{'-','Color',[0 0 0]})
                    ylim ([min([-0.2,min_epoch]),max([1 ,max_epoch])]);
%                     ylabel('Response (\DeltaF/F)')
                    set(gca,'FontSize',24);
                    set(gca,'Ytick',[0, 1]);
                    xlim ([-5,10]);
                    title([sprintf('''Post-synaptic''')]);
                    
                    text(0,1.5,sprintf('anm %d, session %d \n Epoch %d \n Target # %d   ROI=%d \n Distance lateral = %.1f (um) \n Distance axial = %.1f (um) \n Distance 3D = %.1f (um)\n Amplitude %.2f, p-val=%.6f  \n \n',key.subject_id,key.session,key.session_epoch_number, G(i_g).photostim_group_num, k_coupled.roi_number, DATA(i_r).response_distance_lateral_um, DATA(i_r).response_distance_axial_um, DATA(i_r).response_distance_3d_um, DATA(i_r).response_mean,  DATA(i_r).response_p_value1),'FontSize',10);

                    
                    %% response post-synaptic - single trials
                    %__________________________________________________________
                    ax1=axes('position',[position_x(2), position_y(2), panel_width, panel_height]);
                    hold on
                    y=response_trace_trials_coupled;
                    y_smooth=  movmean(mean(y),[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    max_epoch=max(y_smooth);
                    min_epoch=min(y_smooth);
                    hold on;
                    for i=1:1:size(response_trace_trials_coupled,1)
                        xxx= movmean(response_trace_trials_coupled(i,:),[smooth_bins_single_trials 0], 2, 'omitnan','Endpoints','shrink');
                        plot(time(1:end-1),xxx,'LineWidth',1);
                    end
                                        plot(time(1:end-1),y_smooth,'Color',[ 0 0 0],'LineWidth',3);
%                     xlabel('        Time from photostimulation (s)');
%                     ylabel('Response (\DeltaF/F)')
                    set(gca,'FontSize',24);
                    xlim ([-5,10]);
                    

                    
                    
                    
                    
                    
                    if isempty(dir(dir_current_fig))
                        mkdir (dir_current_fig)
                    end
                    %
                    filename=['photostim_group_' num2str(group_list(i_g)) '_roi_' num2str(signif_roi(i_r))];
                    figure_name_out=[ dir_current_fig filename];
                    eval(['print ', figure_name_out, ' -dtiff  -r100']);
                    
                    
                    clf
                    
                    
                  
                    insert(self, kk_insert);
                    
                    
                end
            end
            
            
        end
    end
end
