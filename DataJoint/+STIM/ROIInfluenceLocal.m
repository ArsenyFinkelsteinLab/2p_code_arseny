%{
# ROI responses to each photostim group.response is measured on zscored dff trace
-> IMG.PhotostimGroup
-> IMG.ROI
flag_zscore                         : boolean              # 1 zscore, 0 no zscore
---
response_distance_lateral_um        : float                # (um) lateral (X-Y) distance from target to a given ROI
response_mean                       : float                # dff during photostimulatuon minus dff during photostimulation of control sites - averaged over all trials and over that time window
response_p_value1                   : float               # significance of response to photostimulation, relative to distant pre stimulus baseline, ttest
response_p_value2                   : float               # significance of response to photostimulation, relative to distant pre stimulus baseline, wilcoxon-ranksum
response_mean_odd                   : float                # for the  odd trials
response_p_value1_odd               : float                #
response_p_value2_odd               : float                #
response_mean_even                  : float                # for the  even trials
response_p_value1_even               : float                #
response_p_value2_even               : float                #

response_std                        : float                # standard deviation of that value over trials
response_coefvar                    : float                # coefficient of variation of that value over trials
response_fanofactor                 : float                # fanto factor of that value over trials

response_distance_axial_um          : float                # (um) axial (Z) distance from target to a given ROI
response_distance_3d_um             : float                # (um)  3D distance from target to a given ROI

num_of_baseline_trials_used        : int                # number of control photostim trials used to compute response
num_of_target_trials_used        : int                # number of target photostim trials used to compute response
%}


classdef ROIInfluenceLocal < dj.Computed
    properties
        keySource =(EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.FOVEpoch)& (STIMANAL.SessionEpochsIncluded& 'stimpower=150' & 'flag_include=1')
        %                 keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            time_bin=1; %s
            
            rel_roi = (IMG.ROI-IMG.ROIBad)  & key;
            rel_data = (IMG.ROISpikes -IMG.ROIBad)  & key;

            
            
            flag_zscore=[1]; % 0 don't zscore, 1 do zscore
            distance_to_exclude_all=50; %microns
            try
                frame_rate= fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
            catch
                frame_rate = fetch1(IMG.FOV & key, 'imaging_frame_rate');
            end
            group_list = fetchn((IMG.PhotostimGroup & key),'photostim_group_num','ORDER BY photostim_group_num');
            
            %             window_in_which_all_targets_are_stimulated_once = numel(group_list)/imaging_frame_rate_volume;
            photostim_protocol =  fetch(IMG.PhotostimProtocol & key,'*');
            if ~isempty(photostim_protocol)
                timewind_response=[0,1];
            else %default, only if protocol is missing
                timewind_response=[0,1];
            end
            time  = [-10: (1/frame_rate): 10];
            
            zoom =fetch1(IMG.FOVEpoch & key,'zoom');
            kkk.scanimage_zoom = zoom;
            pix2dist=  fetch1(IMG.Zoom2Microns & kkk,'fov_microns_size_x') / fetch1(IMG.FOV & key, 'fov_x_size');
            
            %  distance_to_closest_neuron = distance_to_closest_neuron/pix2dist; % in pixels
            
            roi_list=fetchn(rel_roi  & key,'roi_number','ORDER BY roi_number');
            roi_plane_num=fetchn(rel_roi & key,'plane_num','ORDER BY roi_number');
            
            roi_z=fetchn(rel_roi*IMG.ROIdepth & key,'z_pos_relative','ORDER BY roi_number');
            
            R_x = fetchn(rel_roi & key,'roi_centroid_x','ORDER BY roi_number');
            R_y = fetchn(rel_roi & key,'roi_centroid_y','ORDER BY roi_number');
            
            try
                F_original = fetchn(rel_data ,'dff_trace','ORDER BY roi_number');
            catch
                F_original = fetchn(rel_data ,'spikes_trace','ORDER BY roi_number');
            end
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
            
            for i_z=1:1:numel(flag_zscore)
                key.flag_zscore=flag_zscore(i_z);
                
                if flag_zscore(i_z)==1
                    F=zscore(F_binned,[],2);
                    
                elseif flag_zscore(i_z)==0
                    F=F_binned;
                end
                
                parfor i_g = 1:1:numel(group_list)
                    k1=key;
                    k1.photostim_group_num = group_list(i_g);
                    g_x = fetch1(IMG.PhotostimGroupROI & k1,'photostim_center_x');
                    g_y = fetch1(IMG.PhotostimGroupROI & k1,'photostim_center_y');
                    
                    target_photostim_frames = fetch1(IMG.PhotostimGroup & k1,'photostim_start_frame');
                    target_photostim_frames=floor(target_photostim_frames./bin_size_in_frame);
                    
                    
                    rel_all=(IMG.PhotostimGroup & key);
                    rel_all=rel_all* IMG.PhotostimGroupROI;
                    allsites_photostim_frames =(fetchn(rel_all,'photostim_start_frame','ORDER BY photostim_group_num')');
                    allsites_num =(fetchn(rel_all,'photostim_group_num','ORDER BY photostim_group_num')');
                    allsites_center_x =(fetchn(rel_all,'photostim_center_x','ORDER BY photostim_group_num')');
                    allsites_center_y =(fetchn(rel_all,'photostim_center_y','ORDER BY photostim_group_num')');
                    
                    
                    dx = g_x - R_x;
                    dy = g_y - R_y;
                    distance = sqrt(dx.^2 + dy.^2)*pix2dist; %pixels
                    
                    current_roi_idx = distance<30 & roi_z==0; % we only take neurons in the vicinity of the photostimulation site
                    current_roi_list = roi_list(current_roi_idx);
                    current_roi_plane_num = roi_plane_num(current_roi_idx);
                    current_roi_R_x = R_x(current_roi_idx);
                    current_roi_R_y = R_y(current_roi_idx);
                    current_roi_z = roi_z(current_roi_idx);
                    current_F= F(current_roi_idx,:);
                    k_response = repmat(k1,numel(current_roi_list),1);
                    for i_r= 1:1:numel(current_roi_list)
                        k_response(i_r).roi_number = current_roi_list(i_r);
                        k_response(i_r).plane_num = current_roi_plane_num(i_r);
                        
                        f_trace=current_F(i_r,:);
                        
                        dx = allsites_center_x - current_roi_R_x(i_r);
                        dy = allsites_center_y - current_roi_R_y(i_r);
                        distance2D = sqrt(dx.^2 + dy.^2)*pix2dist; %
                        idx_allsites_near = distance2D<=distance_to_exclude_all   & ~ (allsites_num== group_list(i_g));
                        allsites_photostim_frames_near = cell2mat(allsites_photostim_frames(idx_allsites_near));
                        allsites_photostim_frames_near = unique(floor(allsites_photostim_frames_near./bin_size_in_frame));
                        idx_allsites_far = distance2D>distance_to_exclude_all   & ~ (allsites_num== group_list(i_g));
                        allsites_photostim_frames_far = cell2mat(allsites_photostim_frames(idx_allsites_far));
                        allsites_photostim_frames_far = unique(floor(allsites_photostim_frames_far./bin_size_in_frame));
                        
                        
                        baseline_frames_clean=allsites_photostim_frames_far(~ismember(allsites_photostim_frames_far, [allsites_photostim_frames_near-1, allsites_photostim_frames_near]));
                        baseline_frames_clean=baseline_frames_clean(~ismember(baseline_frames_clean, [target_photostim_frames-1, target_photostim_frames]));
                        if numel(baseline_frames_clean)>3
                            baseline_frames_clean(1)=[];
                            baseline_frames_clean(end)=[];
                        end
                        
                        
                        if numel(baseline_frames_clean)<100
                            baseline_frames_clean=allsites_photostim_frames_far;
                            k_response(i_r).num_of_baseline_trials_used =  0;
                        else
                            k_response(i_r).num_of_baseline_trials_used =  numel(baseline_frames_clean);
                        end
                        
                        target_photostim_frames_clean=target_photostim_frames(~ismember(target_photostim_frames, [allsites_photostim_frames_near-1, allsites_photostim_frames_near]));
                        if numel(target_photostim_frames_clean)<20
                            target_photostim_frames_clean=target_photostim_frames;
                            k_response(i_r).num_of_target_trials_used =  0;
                        else
                            k_response(i_r).num_of_target_trials_used =  numel(target_photostim_frames_clean);
                        end
                        
                        
                        
                        [StimStat, ] = fn_compute_photostim_delta_influence (f_trace, target_photostim_frames_clean,baseline_frames_clean, timewind_response, time);
                        
                        k_response(i_r).response_mean = StimStat.response_mean;
                        %                         k_response(i_r).response_mean_over_std = StimStat.response_mean_over_std;
                        k_response(i_r).response_std = StimStat.response_std;
                        k_response(i_r).response_coefvar = StimStat.response_coefvar;
                        k_response(i_r).response_fanofactor = StimStat.response_fanofactor;
                        
                        k_response(i_r).response_p_value1 = StimStat.response_p_value1;
                        k_response(i_r).response_p_value2 = StimStat.response_p_value2;
                        
                        k_response(i_r).response_mean_odd = StimStat.response_mean_odd;
                        %                         k_response(i_r).response_mean_over_std_odd = StimStat.response_mean_over_std_odd;
                        k_response(i_r).response_p_value1_odd = StimStat.response_p_value1_odd;
                        k_response(i_r).response_p_value2_odd = StimStat.response_p_value2_odd;
                        
                        k_response(i_r).response_mean_even = StimStat.response_mean_even;
                        %                         k_response(i_r).response_mean_over_std_even = StimStat.response_mean_over_std_even;
                        k_response(i_r).response_p_value1_even = StimStat.response_p_value1_even;
                        k_response(i_r).response_p_value2_even = StimStat.response_p_value2_even;
                        
                        dx = g_x - current_roi_R_x(i_r);
                        dy = g_y - current_roi_R_y(i_r);
                        distance = sqrt(dx.^2 + dy.^2); %pixels
                        distance3D = sqrt( (dx*pix2dist).^2 + (dy*pix2dist).^2 + current_roi_z(i_r).^2); %um
                        
                        k_response(i_r).response_distance_lateral_um = single(distance*pix2dist);
                        k_response(i_r).response_distance_axial_um = single(current_roi_z(i_r));
                        k_response(i_r).response_distance_3d_um = single(distance3D);
                        
                    end
                    insert(self, k_response);
                end
            end
        end
    end
end
