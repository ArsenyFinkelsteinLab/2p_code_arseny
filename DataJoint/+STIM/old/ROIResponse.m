%{
# ROI responses to each photostim group.response is measured on zscored dff trace
-> IMG.PhotostimGroup
-> IMG.ROI
flag_zscore                         : boolean              # 1 zscore, 0 no zscore
---
response_p_value1                   : float                # significance of response to photostimulation, relative to distant pre stimulus baseline
response_mean                       : float                # dff atr some time after photostimulatuon minus dff at some time before the photostimulation - averaged over all trials and over that time window
response_std                        : float                # standard deviation of that value over trials
response_mean_over_std               : float               # response mean divided by standard deviation of the entire zscored trace by standard deviation of the entire trace
response_coefvar                    : float                # coefficient of variation of that value over trials
response_fanofactor                 : float                # fanto factor of that value over trials
response_tstat                      : float                # ttest statistic   xmean-ymean/sqrt(stdev^2/n ystdev^2/m), for p-value1

response_distance_lateral_um        : float                # (um) lateral (X-Y) distance from target to a given ROI
response_distance_axial_um          : float                # (um) axial (Z) distance from target to a given ROI
response_distance_3d_um             : float                # (um)  3D distance from target to a given ROI

response_mean_odd                   : float                # for the  odd trials
response_mean_over_std_odd          : float       # for the  odd trials
response_p_value1_odd               : float               #

response_mean_even                  : float                # for the  even trials
response_mean_over_std_even         : float       # for the  odd trials
response_p_value1_even              : float               #

num_of_control_photostim_used        : int                # number of control photostim trials used to compute response

%}


classdef ROIResponse < dj.Computed
    properties
        keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI & IMG.PlaneCoordinates;
        %                 keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            time_bin=0.5; %s
            rel_data = IMG.ROISpikes;
            flag_zscore=[0,1]; % 0 don't zscore, 1 do zscore
            distance_to_exclude=50; %microns
            try
                frame_rate= fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
            catch
                frame_rate = fetch1(IMG.FOV & key, 'imaging_frame_rate');
            end
            group_list = fetchn((IMG.PhotostimGroup & key),'photostim_group_num','ORDER BY photostim_group_num');
            
            %             window_in_which_all_targets_are_stimulated_once = numel(group_list)/imaging_frame_rate_volume;
            photostim_protocol =  fetch(IMG.PhotostimProtocol & key,'*');
            if ~isempty(photostim_protocol)
                timewind_response=[0,0.5];
            else %default, only if protocol is missing
                timewind_response=[0,0.5];
            end
            time  = [-30: (1/frame_rate): 30];
            
            zoom =fetch1(IMG.FOVEpoch & key,'zoom');
            kkk.scanimage_zoom = zoom;
            pix2dist=  fetch1(IMG.Zoom2Microns & kkk,'fov_microns_size_x') / fetch1(IMG.FOV & key, 'fov_x_size');
            
            %  distance_to_closest_neuron = distance_to_closest_neuron/pix2dist; % in pixels
            
            roi_list=fetchn((IMG.ROI-IMG.ROIBad) & IMG.ROIGood  & key,'roi_number','ORDER BY roi_number');
            roi_plane_num=fetchn((IMG.ROI-IMG.ROIBad) & IMG.ROIGood& key,'plane_num','ORDER BY roi_number');
            
            roi_z=fetchn((IMG.ROI-IMG.ROIBad)*IMG.ROIdepth & IMG.ROIGood & key,'z_pos_relative','ORDER BY roi_number');
            
            R_x = fetchn((IMG.ROI-IMG.ROIBad)&IMG.ROIGood & key,'roi_centroid_x','ORDER BY roi_number');
            R_y = fetchn((IMG.ROI-IMG.ROIBad)&IMG.ROIGood & key,'roi_centroid_y','ORDER BY roi_number');
            
            try
                F_original = fetchn(((rel_data-IMG.ROIBad)& key) & IMG.ROIGood ,'dff_trace','ORDER BY roi_number');
            catch
                F_original = fetchn(((rel_data-IMG.ROIBad)& key) & IMG.ROIGood ,'spikes_trace','ORDER BY roi_number');
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
                    
                    photostim_start_frame = fetch1(IMG.PhotostimGroup & k1,'photostim_start_frame');
                    photostim_start_frame=ceil(photostim_start_frame./bin_size_in_frame);
                    
                    k_response = repmat(k1,numel(roi_list),1);
                    
%                     rel_control=(IMG.PhotostimGroup & key)   -k1;
                    rel_control=(IMG.PhotostimGroup & key);
                    rel_control=rel_control* IMG.PhotostimGroupROI;
                    %                     & [k_response.response_distance_lateral_um]>20
                    control_start_frame =(fetchn(rel_control,'photostim_start_frame','ORDER BY photostim_group_num')');
                    control_group_photostim_center_x =(fetchn(rel_control,'photostim_center_x','ORDER BY photostim_group_num')');
                    control_group_photostim_center_y =(fetchn(rel_control,'photostim_center_y','ORDER BY photostim_group_num')');
                    
                    
                    
                    
                    for i_r= 1:1:numel(roi_list)
                        k_response(i_r).roi_number = roi_list(i_r);
                        k_response(i_r).plane_num = roi_plane_num(i_r);
                        
                        f_trace=F(i_r,:);
                        
                        dx = control_group_photostim_center_x - R_x(i_r);
                        dy = control_group_photostim_center_y - R_y(i_r);
                        distance_to_control = sqrt(dx.^2 + dy.^2)*pix2dist; %
                        idx_control_sites_far = distance_to_control>distance_to_exclude;
                        idx_control_sites_near = distance_to_control<=distance_to_exclude;

                        control_start_frame_far = cell2mat(control_start_frame(idx_control_sites_far));
                        control_start_frame_far = unique(ceil(control_start_frame_far./bin_size_in_frame));
                        
                        control_start_frame_near = cell2mat(control_start_frame(idx_control_sites_near));
                        control_start_frame_near = unique(ceil(control_start_frame_near./bin_size_in_frame));
                        
                       control_start_frame_clean=control_start_frame_far(~ismember(control_start_frame_far,[control_start_frame_near-2,control_start_frame_near-1,control_start_frame_near,control_start_frame_near+1,control_start_frame_near+2]));

                       k_response(i_r).num_of_control_photostim_used =  numel(control_start_frame_clean);

                        [StimStat, ] = fn_compute_photostim_delta_influence (f_trace, photostim_start_frame,control_start_frame_clean, timewind_response, time);
                        
                        k_response(i_r).response_mean = StimStat.response_mean;
                        k_response(i_r).response_mean_over_std = StimStat.response_mean_over_std;
                        k_response(i_r).response_std = StimStat.response_std;
                        k_response(i_r).response_coefvar = StimStat.response_coefvar;
                        k_response(i_r).response_fanofactor = StimStat.response_fanofactor;
                        
                        k_response(i_r).response_p_value1 = StimStat.response_p_value1;
                        k_response(i_r).response_tstat = StimStat.response_tstat;
                        
                        k_response(i_r).response_mean_odd = StimStat.response_mean_odd;
                        k_response(i_r).response_mean_over_std_odd = StimStat.response_mean_over_std_odd;
                        k_response(i_r).response_p_value1_odd = StimStat.response_p_value1_odd;
                        
                        k_response(i_r).response_mean_even = StimStat.response_mean_even;
                        k_response(i_r).response_mean_over_std_even = StimStat.response_mean_over_std_even;
                        k_response(i_r).response_p_value1_even = StimStat.response_p_value1_even;
                        
                        dx = g_x - R_x(i_r);
                        dy = g_y - R_y(i_r);
                        distance = sqrt(dx.^2 + dy.^2); %pixels
                        distance3D = sqrt( (dx*pix2dist).^2 + (dy*pix2dist).^2 + roi_z(i_r).^2); %um
                        
                        k_response(i_r).response_distance_lateral_um = single(distance*pix2dist);
                        k_response(i_r).response_distance_axial_um = single(roi_z(i_r));
                        k_response(i_r).response_distance_3d_um = single(distance3D);
                        
                    end
                    insert(self, k_response);
                end
            end
        end
    end
end
