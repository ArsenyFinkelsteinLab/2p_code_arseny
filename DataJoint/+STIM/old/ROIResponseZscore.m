%{
# ROI responses to each photostim group.response is measured on zscored dff trace
-> IMG.PhotostimGroup
-> IMG.ROI
num_svd_components_removed      : int     # how many of the first svd components were removed
---
response_p_value1                   : float               # significance of response to photostimulation, relative to distant pre stimulus baseline
response_p_value2                   : float                # significance  of response to photostimulation, relative to  pre stimulus baseline that immediately preceds the stimulus
response_p_value3                   : float                # significance of response to photostimulation, relative to distant post stimulus baseline
response_mean                       : float                # dff atr some time after photostimulatuon minus dff at some time before the photostimulation - averaged over all trials and over that time window
response_std                        : float                # standard deviation of that value over trials
response_coefvar                    : float                # coefficient of variation of that value over trials
response_fanofactor                 : float                # fanto factor of that value over trials
response_tstat                      : float                # ttest statistic   xmean-ymean/sqrt(stdev^2/n ystdev^2/m), for p-value1

response_distance_lateral_um        : float                # (um) lateral (X-Y) distance from target to a given ROI
response_distance_axial_um          : float                # (um) axial (Z) distance from target to a given ROI
response_distance_3d_um             : float                # (um)  3D distance from target to a given ROI

response_mean_1half                 : float                # for the  1st half of the trials
response_p_value1_1half              : float                #
response_p_value2_1half              : float                #
response_p_value3_1half              : float                #

response_mean_2half                 : float                # for the  2nd half of the trials
response_p_value1_2half              : float                #
response_p_value2_2half              : float                #
response_p_value3_2half              : float                #

response_mean_odd                   : float                # for the  odd trials
response_p_value1_odd                : float                #
response_p_value2_odd                : float                #
response_p_value3_odd                : float                #

response_mean_even                  : float                # for the  even trials
response_p_value1_even               : float                #
response_p_value2_even               : float                #
response_p_value3_even               : float                #

%}


classdef ROIResponseZscore < dj.Computed
    properties
        keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI & IMG.PlaneCoordinates;
        %                 keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            num_svd_components_removed_vector = [0, 1, 10];
            p_val=[0.0001, 0.001, 0.01, 0.05, 1]; % for saving SVD trace
            time_bin=0.5; %s
            
            try
                frame_rate= fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
            catch
                frame_rate = fetch1(IMG.FOV & key, 'imaging_frame_rate');
            end
            group_list = fetchn((IMG.PhotostimGroup & key),'photostim_group_num','ORDER BY photostim_group_num');
            
            %             window_in_which_all_targets_are_stimulated_once = numel(group_list)/imaging_frame_rate_volume;
            photostim_protocol =  fetch(IMG.PhotostimProtocol & key,'*');
            if ~isempty(photostim_protocol)
                timewind_stim=[0.5,2.5];
                timewind_baseline1 = [-25, -20];% %[-2, -0.5]
                timewind_baseline2=[-2,0];
                timewind_baseline3 = [20, 25];% %[-2, -0.5]
                %                 if photostim_protocol.same_photostim_duration_in_frames>=2
                %                     timewind_stim=[0.5,2.5];
                %                 end
            else %default, only if protocol is missing
                timewind_stim=[0.5,2.5];
                timewind_baseline1 = [-25, -20];% %[-2, -0.5]
                timewind_baseline2=[-2,0];
                timewind_baseline3 = [20, 25];% %[-2, -0.5]
            end
            time  = [-30: (1/frame_rate): 30];
            
            flag_baseline_trial_or_avg=3; %0 - baseline averaged across trials, 1 baseline per trial, 2 global baseline - mean of roi across the entire session epoch, 3 no baseline subtraction
            
            zoom =fetch1(IMG.FOVEpoch & key,'zoom');
            kkk.scanimage_zoom = zoom;
            pix2dist=  fetch1(IMG.Zoom2Microns & kkk,'fov_microns_size_x') / fetch1(IMG.FOV & key, 'fov_x_size');
            
            %  distance_to_closest_neuron = distance_to_closest_neuron/pix2dist; % in pixels
            
            roi_list=fetchn((IMG.ROI-IMG.ROIBad) & IMG.ROIGood  & key,'roi_number','ORDER BY roi_number');
            roi_plane_num=fetchn((IMG.ROI-IMG.ROIBad) & IMG.ROIGood& key,'plane_num','ORDER BY roi_number');
            
            roi_z=fetchn((IMG.ROI-IMG.ROIBad)*IMG.ROIdepth & IMG.ROIGood & key,'z_pos_relative','ORDER BY roi_number');
            
            
            R_x = fetchn((IMG.ROI-IMG.ROIBad)&IMG.ROIGood & key,'roi_centroid_x','ORDER BY roi_number');
            R_y = fetchn((IMG.ROI-IMG.ROIBad)&IMG.ROIGood & key,'roi_centroid_y','ORDER BY roi_number');
            
            
            F_original = fetchn(((IMG.ROIdeltaF-IMG.ROIBad)& key) & IMG.ROIGood ,'dff_trace','ORDER BY roi_number');
            F_original=cell2mat(F_original);
            
            
            
            temp = fetch(IMG.Plane & key);
            key.fov_num =  temp.fov_num;
            key.plane_num =  1; % we will put the actual plane_num later
            key.channel_num =  temp.channel_num;
            
            if time_bin>0
                bin_size_in_frame=ceil(time_bin*frame_rate);
                bins_vector=1:bin_size_in_frame:size(F_original,2);
                bins_vector=bins_vector(2:1:end);
                for  i= 1:1:numel(bins_vector)
                    ix1=(bins_vector(i)-bin_size_in_frame):1:(bins_vector(i)-1);
                    F_binned(:,i)=mean(F_original(:,ix1),2);
                end
                time = time(1:bin_size_in_frame:end);
            else
                F_binned=F_original;
            end
            
            F_binned = gpuArray((F_binned));
            F_binned = F_binned-mean(F_binned,2);
            % F_binned=zscore(F_binned,[],2);
            [U,S,V]=svd(F_binned); % S time X neurons; % U time X time;  V neurons x neurons
            
            for i_c = 1:1:numel(num_svd_components_removed_vector)
                
                key.num_svd_components_removed=num_svd_components_removed_vector(i_c);
                if num_svd_components_removed_vector(i_c)>0
                    num_comp = num_svd_components_removed_vector(i_c);
                    F = U(:,(1+num_comp):end)*S((1+num_comp):end, (1+num_comp):end)*V(:,(1+num_comp):end)';
                else
                    F=F_binned;
                end
                F = zscore(F,[],2); % note that we zscore after perofrming SVD
                F=gather(F);
                
                parfor i_g = 1:1:numel(group_list)
                    k1=key;
                    k1.photostim_group_num = group_list(i_g);
                    g_x = fetch1(IMG.PhotostimGroupROI & k1,'photostim_center_x');
                    g_y = fetch1(IMG.PhotostimGroupROI & k1,'photostim_center_y');
                    
                    photostim_start_frame = fetch1(IMG.PhotostimGroup & k1,'photostim_start_frame');
                    
                    photostim_start_frame=ceil(photostim_start_frame./bin_size_in_frame);
                    
                    k_response = repmat(k1,numel(roi_list),1);
                    %                     k_trace = repmat(k1,numel(roi_list),1);
                    %                     k_pairs = repmat(k1,numel(roi_list),1);
                    %                     k_pairs=rmfield(k_pairs,'num_svd_components_removed');
                    % k_response_vec = repmat(k1,numel(roi_list),1);
                    
                    for i_r= 1:1:numel(roi_list)
                        k_response(i_r).roi_number = roi_list(i_r);
                        k_response(i_r).plane_num = roi_plane_num(i_r);
                        
                        f_trace=F(i_r,:);
                        global_baseline=mean( f_trace);
                        
                        [StimStat, StimTrace(i_r)] = fn_compute_photostim_response (f_trace, photostim_start_frame, timewind_stim, timewind_baseline1,timewind_baseline2,timewind_baseline3, flag_baseline_trial_or_avg,global_baseline, time);
                        
                        k_response(i_r).response_mean = StimStat.response_mean;
                        k_response(i_r).response_std = StimStat.response_std;
                        k_response(i_r).response_coefvar = StimStat.response_coefvar;
                        k_response(i_r).response_fanofactor = StimStat.response_fanofactor;
                        
                        k_response(i_r).response_p_value1 = StimStat.response_p_value1;
                        k_response(i_r).response_p_value2 = StimStat.response_p_value2;
                        k_response(i_r).response_p_value3 = StimStat.response_p_value3;
                        
                        k_response(i_r).response_tstat = StimStat.response_tstat;
                        
                        
                        k_response(i_r).response_mean_1half = StimStat.response_mean_1half;
                        k_response(i_r).response_p_value1_1half = StimStat.response_p_value1_1half;
                        k_response(i_r).response_p_value2_1half = StimStat.response_p_value2_1half;
                        k_response(i_r).response_p_value3_1half = StimStat.response_p_value3_1half;
                        
                        k_response(i_r).response_mean_2half = StimStat.response_mean_2half;
                        k_response(i_r).response_p_value1_2half = StimStat.response_p_value1_2half;
                        k_response(i_r).response_p_value2_2half = StimStat.response_p_value2_2half;
                        k_response(i_r).response_p_value3_2half = StimStat.response_p_value3_2half;
                        
                        k_response(i_r).response_mean_odd = StimStat.response_mean_odd;
                        k_response(i_r).response_p_value1_odd = StimStat.response_p_value1_odd;
                        k_response(i_r).response_p_value2_odd = StimStat.response_p_value2_odd;
                        k_response(i_r).response_p_value3_odd = StimStat.response_p_value3_odd;
                        
                        k_response(i_r).response_mean_even = StimStat.response_mean_even;
                        k_response(i_r).response_p_value1_even = StimStat.response_p_value1_even;
                        k_response(i_r).response_p_value2_even = StimStat.response_p_value2_even;
                        k_response(i_r).response_p_value3_even = StimStat.response_p_value3_even;
                        
                        
                        dx = g_x - R_x(i_r);
                        dy = g_y - R_y(i_r);
                        distance = sqrt(dx.^2 + dy.^2); %pixels
                        distance3D = sqrt( (dx*pix2dist).^2 + (dy*pix2dist).^2 + roi_z(i_r).^2); %um
                        
                        k_response(i_r).response_distance_lateral_um = single(distance*pix2dist);
                        k_response(i_r).response_distance_axial_um = single(roi_z(i_r));
                        k_response(i_r).response_distance_3d_um = single(distance3D);
                        
                    end
                    StimTrace=struct2table(StimTrace);
                    
                    response_sign = {'all','excited','inhibited'};
                    k_trace=k1;
                    k_trace=rmfield(k_trace,{'fov_num','plane_num', 'channel_num'});
                    flag_within_column=[0,1];
                    for i_column = 1:1:numel(flag_within_column)
                        for i_sign = 1:1:numel(response_sign)
                            for i_p=1:1:numel(p_val)
                                if flag_within_column(i_column) ==1 % within column
                                idx_rois= [k_response.response_p_value1_odd]<=p_val(i_p)  & [k_response.response_distance_lateral_um]>20 & [k_response.response_distance_lateral_um]<=100; % we exclude durectly stimulated neurons, and take every pairs within a "column"
                                else
                                    idx_rois= [k_response.response_p_value1_odd]<=p_val(i_p) & [k_response.response_distance_lateral_um]>100; % we take only pairs outside of the column
                                end
                                switch response_sign{i_sign}
                                    case 'excited'
                                        idx_rois = idx_rois & [k_response.response_mean_odd]>0;
                                    case 'inhibited'
                                        idx_rois = idx_rois & [k_response.response_mean_odd]<0;
                                end
                                if sum(idx_rois)>1
                                    k_trace.response_trace_mean = mean(StimTrace.response_trace_mean(idx_rois,:),1);
                                    k_trace.response_trace_mean_1half = mean(StimTrace.response_trace_mean_1half(idx_rois,:),1);
                                    k_trace.response_trace_mean_2half = mean(StimTrace.response_trace_mean_2half(idx_rois,:),1);
                                    k_trace.response_trace_mean_odd = mean(StimTrace.response_trace_mean_odd(idx_rois,:),1);
                                    k_trace.response_trace_mean_even = mean(StimTrace.response_trace_mean_even(idx_rois,:),1);
                                else
                                    k_trace.response_trace_mean = single(time+NaN);
                                    k_trace.response_trace_mean_1half = single(time+NaN);
                                    k_trace.response_trace_mean_2half = single(time+NaN);
                                    k_trace.response_trace_mean_odd = single(time+NaN);
                                    k_trace.response_trace_mean_even = single(time+NaN);
                                end
                                k_trace.response_p_val = p_val(i_p);
                                k_trace.response_sign = response_sign{i_sign};
                                k_trace.flag_within_column = flag_within_column(i_column);
                                k_trace.num_pairs = sum(idx_rois);
                                insert(STIM.ROIResponseTraceZscore, k_trace);
                            end
                        end
                    end
                    insert(self, k_response);
                end
            end
        end
    end
end
