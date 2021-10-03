%{
# ROI responses to each photostim group.
-> IMG.PhotostimGroup
-> IMG.ROI
---
response_mean_trials        : blob                # response amlitude (mean over response window) at each trial
response_peak_trials        : blob                # response amlitude (peak at response window) at each trial

response_trace_trials                   : longblob    # response trace at each trial

response_trace_mean_all    : blob        # mean postsynpatic response trace, for all trials
response_trace_stem_all    : blob        #

response_trace_mean_presynaptic_weak    : blob        # mean postsynpatic response trace when the presenypatic cell had weak response to photostimulation (20<= response percentile)
response_trace_stem_presynaptic_weak    : blob        #

response_trace_mean_presynaptic_strong  : blob        # mean postsynpatic response trace when the presenypatic cell had strong response to photostimulation (response percentile>=80)
response_trace_stem_presynaptic_strong  : blob        #

pre_post_synaptic_response_correlation=null  : float       # response peak correlation between pre and post synanptic response, for all trials

time_vector : blob

%}


classdef ROIInfluenceVariability < dj.Computed
    properties
        %         keySource = (EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI & IMG.PlaneCoordinates)& (STIMANAL.SessionEpochsIncluded& 'stimpower=150' & 'flag_include=1')
        %                 keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI;
        keySource = EXP2.SessionEpoch & STIMANAL.ROIResponseDirectVariability;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Photostim\photostim_traces\coupled_analysis_for_ilan\'];
            
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
            
            
            
            
            
            
            
            %Graphics
            %---------------------------------
            figure;
            set(gcf,'DefaultAxesFontName','helvetica');
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
            set(gcf,'PaperOrientation','portrait');
            set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
            set(gcf,'color',[1 1 1]);
            
            panel_width=0.3;
            panel_height=0.3;
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
                
                
                response_trials_direct = fetchn(STIMANAL.ROIResponseDirectVariability & key,'response_peak_trials');
                response_trials_direct=response_trials_direct{1};
                %                 idx_weak = response_trials_direct<=0.25;
                %                 idx_strong = response_trials_direct>=0.75;
                
                weak_response_threshold = prctile(response_trials_direct,20);
                strong_response_threshold = prctile(response_trials_direct,80);
                
                idx_weak = response_trials_direct<=weak_response_threshold;
                idx_strong = response_trials_direct>=strong_response_threshold;
                %                 idx_no_response = response_trials_direct<=0.25;
                
                
                response_trace_trials_direct = fetch1(STIMANAL.ROIResponseDirectVariability & key,'response_trace_trials');
                time_vector_direct = fetch1(STIMANAL.ROIResponseDirectVariability & key,'time_vector');
                
                
                
                
                for i_r = 1:1:numel(signif_roi)
                    kk_insert = fetch( STIM.ROIResponseDirect & key);
                    kk_insert.roi_number =DATA(i_r).roi_number;
                    kk_insert.plane_num = DATA(i_r).plane_num;

                    
                    %% response direct
                    %__________________________________________________________
                    
                    ax1=axes('position',[position_x(1), position_y(1), panel_width, panel_height]);
                    
                    %% all
                    y=response_trace_trials_direct;
                    y_smooth=  movmean(mean(y),[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    ystem=std(y)./sqrt(size(y,1));
                    ystem_smooth=  movmean(ystem,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    
                    max_epoch=max(y_smooth);
                    min_epoch=min(y_smooth);
                    hold on;
                    plot(time_vector_direct,y_smooth,'Color',[ 0 0 0],'LineWidth',3);
                    shadedErrorBar(time_vector_direct,y_smooth,ystem_smooth,'lineprops',{'-','Color',[0 0 0]})
                    
                    
                    %% below 25 response percentile
                    y=response_trace_trials_direct(idx_weak,:);
                    y_smooth=  movmean(mean(y),[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    ystem=std(y)./sqrt(size(y,1));
                    ystem_smooth=  movmean(ystem,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    
                    max_epoch=max(y_smooth);
                    min_epoch=min(y_smooth);
                    hold on;
                    plot(time_vector_direct,y_smooth,'Color',[ 0 0 1],'LineWidth',3);
                    %                     shadedErrorBar(time_vector_direct,y_smooth,ystem_smooth,'lineprops',{'-','Color',[0.5 0.5 1]})
                    
                    
                    %                     %% no response
                    %                     if sum(idx_no_response)>=2
                    %                         y=response_trace_trials_direct(idx_no_response,:);
                    %                     y_smooth=  movmean(mean(y),[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    %                     ystem=std(y)./sqrt(size(y,1));
                    %                     ystem_smooth=  movmean(ystem,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    %
                    %                     max_epoch=max(y_smooth);
                    %                     min_epoch=min(y_smooth);
                    %                     hold on;
                    %                      plot(time_vector_direct,y_smooth,'Color',[ 0 0 1]);
                    % %                     shadedErrorBar(time_vector_direct,y_smooth,ystem_smooth,'lineprops',{'-','Color',[0 0 0]})
                    %
                    %                     end
                    
                    %% above 75 response percentile
                    y=response_trace_trials_direct(idx_strong,:);
                    y_smooth=  movmean(mean(y),[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    ystem=std(y)./sqrt(size(y,1));
                    ystem_smooth=  movmean(ystem,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    
                    max_epoch=max(y_smooth+ystem);
                    min_epoch=min(y_smooth-ystem);
                    hold on;
                    plot(time_vector_direct,y_smooth,'Color',[ 1 0 0],'LineWidth',3);
                    %                     shadedErrorBar(time_vector_direct,y_smooth,ystem_smooth,'lineprops',{'-','Color',[1 0 0]})
                    
                    
                    
                    ylim ([min([-0.2,min_epoch]),max([1 ,max_epoch])]);
                    xlabel('        Time from photostimulation (s)');
                    ylabel('Response (\DeltaF/F)')
                    %         title(sprintf('Coupled responses \n Target # %d   ROI=%d \n Distance = %.1f (um), Amplitude %.2f, p-val=%.6f  \n',G(i_g).photostim_group_num, k2.roi_number, DATA(i_r).response_distance_pixels * pix2dist,  DATA(i_r).response_mean,  DATA(i_r).response_p_value));
                    
                    
                    %         title(sprintf('Photostim group=%d    ROI=%d    \n p=%.6f  distance = %.1f (pixels) response mean %.2f',G(i_g).photostim_group_num, k2.roi_number, response_p_value(i_r), response_distance_pixels(i_r), response_mean(i_r)));
                    set(gca,'FontSize',24);
                    %                     title(sprintf('anm %d, session %d \n Coupled responses \n Target # %d   ROI=%d \n Distance lateral = %.1f (um) \n Distance axial = %.1f (um) \n Distance 3D = %.1f (um)\n Amplitude %.2f, p-val=%.6f  \n \n \n',k2.subject_id,k2.session, G(i_g).photostim_group_num, k2.roi_number, DATA(i_r).response_distance_lateral_um, DATA(i_r).response_distance_axial_um, DATA(i_r).response_distance_3d_um, DATA(i_r).response_mean,  DATA(i_r).response_p_value1),'FontSize',10);
                    
                    set(gca,'Ytick',[0, 1]);
                    
                    xlim ([-5,10]);
                    
                    %                    title(sprintf('Photostim group=%d    ROI=%d    \n p=%.6f  distance = %.1f (pixels) response mean %.2f',G(i_g).photostim_group_num, k2.roi_number, response_p_value(i_r), response_distance_pixels(i_r), response_mean(i_r)));
                    
                    
                    title([sprintf('''Pre-synaptic''')]);
                    
                    
                    
                    
                    
                    
                    
                    %%
                    
                    
                    %% response coupled
                    %__________________________________________________________
                    k2=k1;
                    k2.roi_number = signif_roi(i_r);
                    
                    
                    
                    photostim_start_frame = fetch1(IMG.PhotostimGroup & STIM.ROIResponseDirect & k2,'photostim_start_frame');
                    
                    f_trace_direct = fetch1(IMG.ROITrace & k2,'f_trace');
                    
                    global_baseline=mean( f_trace_direct);
                    
                    timewind_response = [ 0 2];
                    timewind_baseline1 = [ -5 0];
                    timewind_baseline2  = [-5 0] ;
                    timewind_baseline3  = [ -5 0];
                    [StimStat,StimTrace] = fn_compute_photostim_response_variability (f_trace_direct , photostim_start_frame, timewind_response, timewind_baseline1,timewind_baseline2,timewind_baseline3, flag_baseline_trial_or_avg, global_baseline, time);
                    
                    response_trials_coupled = StimStat.response_peak_trials;
                    
                    
                    hold on;
                    
                    
                    
                    
                    %% POST_SYNAPTIC TRACE
                    
                    ax1=axes('position',[position_x(2), position_y(1), panel_width, panel_height]);
                    %% all
                    y=StimTrace.response_trace_trials;
                    y_smooth=  movmean(mean(y),[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    ystem=std(y)./sqrt(size(y,1));
                    ystem_smooth=  movmean(ystem,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    
                    max_epoch=max(y_smooth);
                    min_epoch=min(y_smooth);
                    hold on;
                    plot(time(1:end-1),y_smooth,'Color',[ 0 0 0],'LineWidth',3);
                    shadedErrorBar(time(1:end-1),y_smooth,ystem_smooth,'lineprops',{'-','Color',[0 0 0]})
                    
                    kk_insert.response_trace_mean_all = mean(y);
                    kk_insert.response_trace_stem_all = ystem;
                    
                    
                    
                    
                    %% below 25 response percentile
                    y=StimTrace.response_trace_trials(idx_weak,:);
                    y_smooth=  movmean(mean(y),[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    ystem=std(y)./sqrt(size(y,1));
                    ystem_smooth=  movmean(ystem,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    
                    max_epoch=max(y_smooth);
                    min_epoch=min(y_smooth);
                    hold on;
                    plot(time(1:end-1),y_smooth,'Color',[ 0 0 1],'LineWidth',3);
                    %                     shadedErrorBar(time(1:end-1),y_smooth,ystem_smooth,'lineprops',{'-','Color',[0.5 0.5 1]})
                    
                    kk_insert.response_trace_mean_presynaptic_weak = mean(y);
                    kk_insert.response_trace_stem_presynaptic_weak = ystem;
                    
                    
                    
                    %                     %% no response
                    %                     if sum(idx_no_response)>=2
                    %                         y=StimTrace.response_trace_trials(idx_no_response,:);
                    %                         y_smooth=  movmean(mean(y),[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    %                         ystem=std(y)./sqrt(size(y,1));
                    %                         ystem_smooth=  movmean(ystem,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    %
                    %                         max_epoch=max(y_smooth);
                    %                         min_epoch=min(y_smooth);
                    %                         hold on;
                    % %                         plot(time(1:end-1),y_smooth,'Color',[ 1 0 0]);
                    %                         shadedErrorBar(time(1:end-1),y_smooth,ystem_smooth,'lineprops',{'-','Color',[0 0 0]})
                    %                     end
                    
                    
                    %% above 75 response percentile
                    y=StimTrace.response_trace_trials(idx_strong,:);
                    y_smooth=  movmean(mean(y),[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    ystem=std(y)./sqrt(size(y,1));
                    ystem_smooth=  movmean(ystem,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
                    max_epoch=max(y_smooth+ystem);
                    min_epoch=min(y_smooth-ystem);
                    hold on;
                    plot(time(1:end-1),y_smooth,'Color',[ 1 0 0],'LineWidth',3);
                    %                     shadedErrorBar(time(1:end-1),y_smooth,ystem_smooth,'lineprops',{'-','Color',[1 0 0]})
                    ylim ([min([-0.2,min_epoch]),max([1 ,max_epoch])]);
                    %                     xlabel('Time from photostimulation(s)');
                    %                     ylabel('Response(\Delta F/F)')
                    %         title(sprintf('Coupled responses \n Target # %d   ROI=%d \n Distance = %.1f (um), Amplitude %.2f, p-val=%.6f  \n',G(i_g).photostim_group_num, k2.roi_number, DATA(i_r).response_distance_pixels * pix2dist,  DATA(i_r).response_mean,  DATA(i_r).response_p_value));
                    title([sprintf('''Post-synaptic''')]);
                    set(gca,'FontSize',24);
                    set(gca,'Ytick',[0, 1]);
                    xlim ([-5,10]);
                    text(0,1.5,sprintf('anm %d, session %d \n Coupled responses \n Target # %d   ROI=%d \n Distance lateral = %.1f (um) \n Distance axial = %.1f (um) \n Distance 3D = %.1f (um)\n Amplitude %.2f, p-val=%.6f  \n ',k2.subject_id,k2.session, G(i_g).photostim_group_num, k2.roi_number, DATA(i_r).response_distance_lateral_um, DATA(i_r).response_distance_axial_um, DATA(i_r).response_distance_3d_um, DATA(i_r).response_mean,  DATA(i_r).response_p_value1),'FontSize',10);
                    
                    kk_insert.response_trace_mean_presynaptic_strong = mean(y);
                    kk_insert.response_trace_stem_presynaptic_strong = ystem;
                    
                    
                    %% histogram
                    ax1=axes('position',[position_x(1), position_y(2), panel_width, panel_height/2]);
                    hold on
                    hist_bins=linspace(-max(response_trials_direct),max(response_trials_direct),15);
                    hhh=histogram(response_trials_direct,hist_bins,'FaceColor',[0.5 0.5 0.5]);
                    %                     xlabel([sprintf('''Pre-synaptic'' response \n peak ') ('(\Delta F/F)')]);
                    xlabel([sprintf('Response peak ') ('(\Delta F/F)')]);
                    title([sprintf('''Pre-synaptic''')]);
                    
                    ylabel('Counts (trials)');
                    set(gca,'FontSize',24);
                    plot([weak_response_threshold weak_response_threshold], [0,max(hhh.Values)*1.2],'Color',[0 0 1],'LineWidth',3)
                    plot([strong_response_threshold strong_response_threshold], [0,max(hhh.Values)*1.2],'Color',[1 0 0],'LineWidth',3)
                    
                    try
                    r=corr(response_trials_direct,response_trials_coupled);
                    catch
                        r=NaN;
                    end
                    %                     ax2=axes('position',[position_x(2), position_y(2), panel_width, panel_height/2]);
                    %                     hist_bins=linspace(-max(response_trials_coupled),max(response_trials_coupled),15);
                    %                     histogram(response_trials_coupled,hist_bins,'FaceColor',[0.5 0.5 0.5]);
                    % %                     xlabel([sprintf('''Post-synaptic'' response \n peak ') ('(\Delta F/F)')]);
                    % %                     ylabel('Counts (trials)');
                    %                     set(gca,'FontSize',24);
                    %                     title(sprintf('  <pre-synaptic,post-synaptic> \n correlation r = %.2f',r),'FontSize',16)
                    
                    
                    if isempty(dir(dir_current_fig))
                        mkdir (dir_current_fig)
                    end
                    %
                    filename=['photostim_group_' num2str(group_list(i_g)) '_roi_' num2str(signif_roi(i_r))];
                    figure_name_out=[ dir_current_fig filename];
                    eval(['print ', figure_name_out, ' -dtiff  -r100']);
                    
                    
                    clf
                    
                    
                    
                    kk_insert.response_trace_trials = StimTrace.response_trace_trials;
                    
                    kk_insert.response_mean_trials = StimStat.response_trials;
                    kk_insert.response_peak_trials = StimStat.response_peak_trials;
                    
                    kk_insert.pre_post_synaptic_response_correlation = r;
                    
                    kk_insert.time_vector = time(1:end-1);
                    insert(self, kk_insert);
                    
                    
                end
            end
            
            
        end
    end
end
