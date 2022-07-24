%{
# ROI responses to each photostim group.  Zscoring. Spikes. 
# XYZ coordinate correction of ETL abberations based on anatomical fiducial
-> IMG.PhotostimGroup
-> IMG.ROI
num_svd_components_removed      : int     # how many of the first svd components were removed
---
response_distance_lateral_um        : float                # (um) lateral (X-Y) distance from target to a given ROI
response_mean                       : float                # zscored dff during photostimulatuon minus dff during photostimulation of control sites - averaged over all trials and over that time window
response_p_value1                   : float                # significance of response to photostimulation, relative to distant pre stimulus baseline, ttest
response_mean_odd                   : float                # for the  odd trials
response_p_value1_odd               : float                #
response_mean_even                  : float                # for the  even trials
response_p_value1_even               : float               #

response_std                        : float                # standard deviation of that value over trials
response_coefvar                    : float                # coefficient of variation of that value over trials
response_fanofactor                 : float                # fanto factor of that value over trials

response_distance_axial_um          : float                # (um) axial (Z) distance from target to a given ROI
response_distance_3d_um             : float                # (um)  3D distance from target to a given ROI

num_of_target_trials_used        : int                     # number of target photostim trials used to compute response
%}


classdef ROIInfluence3 < dj.Computed
    properties
        keySource =  (EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.FOVEpoch) & IMG.Volumetric & (STIMANAL.SessionEpochsIncludedFinal & 'flag_include=1') & IMG.ROIPositionETL2 & (EXP2.Session*EXP2.SessionID);
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            distance_to_exclude_all=50; %microns
            minimal_number_of_clean_trials=20; %to include; trials that are not affected by random stimulations of nearby targets
            
            num_svd_components_removed_vector = [0];
            %              num_svd_components_removed_vector = [0];
            
            %             p_val=[0.001, 0.01, 0.05, 1]; % for saving SVD trace
            %             time_bin=0; %s
            
            
            rel_roi = (IMG.ROI-IMG.ROIBad)  & key;
            rel_roi_xy = (IMG.ROIPositionETL2-IMG.ROIBad)  & key; % % XYZ coordinate correction of ETL abberations based on anatomical fiducial

            
            rel_data = (IMG.ROISpikes -IMG.ROIBad)  & key;
            %             rel_data = IMG.ROIdeltaF;
            
            
            try
                frame_rate= fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
            catch
                frame_rate = fetch1(IMG.FOV & key, 'imaging_frame_rate');
            end
            group_list = fetchn((IMG.PhotostimGroup & key),'photostim_group_num','ORDER BY photostim_group_num');
            %             group_list = fetchn((IMG.PhotostimGroup & key & (STIMANAL.NeuronOrControl & 'neurons_or_control=1') ),'photostim_group_num','ORDER BY photostim_group_num');
            %             window_in_which_all_targets_are_stimulated_once = numel(group_list)/imaging_frame_rate_volume;
            
            photostim_protocol =  fetch(IMG.PhotostimProtocol & key,'*');
            if ~isempty(photostim_protocol)
                timewind_response=[0.05,0.5];
            else %default, only if protocol is missing
                timewind_response=[0.05,0.5];
            end
            
            time =[-3:1:3]./frame_rate;
            
            
            zoom =fetch1(IMG.FOVEpoch & key,'zoom');
            kkk.scanimage_zoom = zoom;
            pix2dist=  fetch1(IMG.Zoom2Microns & kkk,'fov_microns_size_x') / fetch1(IMG.FOV & key, 'fov_x_size');
            
            %  distance_to_closest_neuron = distance_to_closest_neuron/pix2dist; % in pixels
            
            roi_list=fetchn(rel_roi,'roi_number','ORDER BY roi_number');
            roi_plane_num=fetchn(rel_roi,'plane_num','ORDER BY roi_number');
            roi_z=fetchn(rel_roi*IMG.ROIdepth,'z_pos_relative','ORDER BY roi_number');
            
            % to correct for ETL abberations
            R_x = fetchn(rel_roi_xy ,'roi_centroid_x_corrected','ORDER BY roi_number');
            R_y = fetchn(rel_roi_xy ,'roi_centroid_y_corrected','ORDER BY roi_number');
            
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
            
            %             if time_bin>0
            %                 bin_size_in_frame=ceil(time_bin*frame_rate);
            %                 bins_vector=1:bin_size_in_frame:size(F_original,2);
            %                 bins_vector=bins_vector(2:1:end);
            %                 for  i= 1:1:numel(bins_vector)
            %                     ix1=(bins_vector(i)-bin_size_in_frame):1:(bins_vector(i)-1);
            %                     F_binned(:,i)=mean(F_original(:,ix1),2);
            %                 end
            %                 time = time(1:bin_size_in_frame:end);
            %             else
            %                 F_binned=F_original;
            bin_size_in_frame=1;
            %             end
            
            %             F_binned = gpuArray((F_binned));
            %             F_binned = F_binned-mean(F_binned,2);
            F=zscore(F_original,[],2);
            %             [U,S,V]=svd(F_binned); % S time X neurons; % U time X time;  V neurons x neurons
            
            
            
            rel_all_sites=(IMG.PhotostimGroup& key);
            rel_all_sites=rel_all_sites* IMG.PhotostimGroupROI;
            
            allsites_num =(fetchn(rel_all_sites,'photostim_group_num','ORDER BY photostim_group_num')');
            allsites_center_x =(fetchn(rel_all_sites,'photostim_center_x','ORDER BY photostim_group_num')');
            allsites_center_y =(fetchn(rel_all_sites,'photostim_center_y','ORDER BY photostim_group_num')');
            
            allsites_photostim_frames =(fetchn(rel_all_sites,'photostim_start_frame','ORDER BY photostim_group_num')');
            allsites_photostim_frames_unique = unique(floor(cell2mat(allsites_photostim_frames)./bin_size_in_frame));
            
            
            for i_c = 1:1:numel(num_svd_components_removed_vector)
                key.num_svd_components_removed=num_svd_components_removed_vector(i_c);
                %                 if num_svd_components_removed_vector(i_c)>0
                %                     num_comp = num_svd_components_removed_vector(i_c);
                %                     F = U(:,(1+num_comp):end)*S((1+num_comp):end, (1+num_comp):end)*V(:,(1+num_comp):end)';
                %                 else
                %                     F=F_binned;
                %                 end
                %                 F=gather(F);
                
                parfor i_g = 1:1:numel(group_list) %parfor
                    %                 for i_g = 1:1:numel(group_list)
                    k1=key;
                    k1.photostim_group_num = group_list(i_g);
                    g_x = fetch1(IMG.PhotostimGroupROI & k1,'photostim_center_x');
                    g_y = fetch1(IMG.PhotostimGroupROI & k1,'photostim_center_y');
                    
                    target_photostim_frames = fetch1(IMG.PhotostimGroup & k1,'photostim_start_frame');
                    target_photostim_frames=floor(target_photostim_frames./bin_size_in_frame);
                    
                    
                    k_response = repmat(k1,numel(roi_list),1);
                    
                    for i_r= 1:1:numel(roi_list)
                        k_response(i_r).roi_number = roi_list(i_r);
                        k_response(i_r).plane_num = roi_plane_num(i_r);
                        f_trace=F(i_r,:);
                        
                        
                        % Excluding all frames during stimulation of other targets in the vicinity of the potentially connected cell
                        dx = allsites_center_x - R_x(i_r);
                        dy = allsites_center_y - R_y(i_r);
                        distance2D = sqrt(dx.^2 + dy.^2)*pix2dist; %
                        idx_allsites_near = distance2D<=distance_to_exclude_all   & ~ (allsites_num== group_list(i_g));
                        allsites_photostim_frames_near = cell2mat(allsites_photostim_frames(idx_allsites_near));
                        allsites_photostim_frames_near = unique(floor(allsites_photostim_frames_near./bin_size_in_frame));
                        %                         idx_allsites_far = distance2D>distance_to_exclude_all   & ~ (allsites_num== group_list(i_g));
                        %                         allsites_photostim_frames_far = cell2mat(allsites_photostim_frames(idx_allsites_far));
                        %                         allsites_photostim_frames_far = unique(floor(allsites_photostim_frames_far./bin_size_in_frame));
                        
                        % Finding baseline frames (not during target stimulation) that are not affected by stimulation of other targets in the vicinity in the vicinity of the potentially connected cell
                        baseline_frames_clean=allsites_photostim_frames_unique(~ismember(allsites_photostim_frames_unique, [allsites_photostim_frames_near-1, allsites_photostim_frames_near, allsites_photostim_frames_near+1]));
                        baseline_frames_clean=baseline_frames_clean(~ismember(baseline_frames_clean, [target_photostim_frames-1, target_photostim_frames, target_photostim_frames+1]));
                        
                        %                         if numel(baseline_frames_clean)<100
                        %                             baseline_frames_clean=allsites_photostim_frames_far;
                        %                             k_response(i_r).num_of_baseline_trials_used =  0;
                        %                         else
                        %                             k_response(i_r).num_of_baseline_trials_used =  numel(baseline_frames_clean);
                        %                         end
                        %                         if numel(baseline_frames_clean)>3
                        %                             baseline_frames_clean(1)=[];
                        %                             baseline_frames_clean(end)=[];
                        %                         end
                        
                        % Finding frames during target stimulation that are not affected by stimulation of other targets in the vicinity of the potentially connected cells
                        target_photostim_frames_clean=target_photostim_frames(~ismember(target_photostim_frames, [allsites_photostim_frames_near-1, allsites_photostim_frames_near, allsites_photostim_frames_near+1]));
                        
                        if numel(target_photostim_frames_clean)<minimal_number_of_clean_trials % if there are too few trials, we don't analyze this pair
                            target_photostim_frames_clean=target_photostim_frames;
                            k_response(i_r).num_of_target_trials_used =  0;
                        else
                            k_response(i_r).num_of_target_trials_used =  numel(target_photostim_frames_clean);
                        end
                        
                        dx = g_x - R_x(i_r);
                        dy = g_y - R_y(i_r);
                        distance2D = sqrt(dx.^2 + dy.^2); %pixels
                        distance3D = sqrt( (dx*pix2dist).^2 + (dy*pix2dist).^2 + roi_z(i_r).^2); %um
                        
                        %                         i_r
                        %                         single(distance2D*pix2dist)
                        k_response(i_r).response_distance_lateral_um = single(distance2D*pix2dist);
                        k_response(i_r).response_distance_axial_um = single(roi_z(i_r));
                        k_response(i_r).response_distance_3d_um = single(distance3D);
                        
                        
                        %                         [StimStat, StimTrace(i_r)] = fn_compute_photostim_delta_influence (f_trace, target_photostim_frames_clean,baseline_frames_clean, timewind_response, time);
                        [StimStat] = fn_compute_photostim_delta_influence5 (f_trace, target_photostim_frames_clean,baseline_frames_clean, timewind_response, time);
                        
                        k_response(i_r).response_mean = StimStat.response_mean;
                        
%                         if isnan(StimStat.response_mean)
%                             a=1
%                         end
                        
                        k_response(i_r).response_std = StimStat.response_std;
                        k_response(i_r).response_coefvar = StimStat.response_coefvar;
                        k_response(i_r).response_fanofactor = StimStat.response_fanofactor;
                        k_response(i_r).response_p_value1 = StimStat.response_p_value1;
                        %                         k_response(i_r).response_p_value2 = StimStat.response_p_value2;
                        k_response(i_r).response_mean_odd = StimStat.response_mean_odd;
                        k_response(i_r).response_p_value1_odd = StimStat.response_p_value1_odd;
                        %                         k_response(i_r).response_p_value2_odd = StimStat.response_p_value2_odd;
                        k_response(i_r).response_mean_even = StimStat.response_mean_even;
                        k_response(i_r).response_p_value1_even = StimStat.response_p_value1_even;
                        %                         k_response(i_r).response_p_value2_even = StimStat.response_p_value2_even;
                        
                        
                        
                        
                    end
                    
                    %                     StimTrace=struct2table(StimTrace);
                    
                    %                     response_sign = {'all','excited','inhibited'};
                    %                     k_trace=k1;
                    %                     k_trace=rmfield(k_trace,{'fov_num','plane_num', 'channel_num'});
                    %                     flag_distance=[0,1,2,3];
                    %                     flag_distance_edge1=[0,25,100,200];
                    %                     flag_distance_edge2=[25,100,200,inf];
                    %                     for i_dist = 1:1:numel(flag_distance)
                    %                         for i_sign = 1:1:numel(response_sign)
                    %                             for i_p=1:1:numel(p_val)
                    %
                    %                                 idx_rois= [k_response.response_p_value1_odd]<=p_val(i_p)  & [k_response.response_distance_lateral_um]>=flag_distance_edge1(i_dist) & [k_response.response_distance_lateral_um]<flag_distance_edge2(i_dist);
                    %                                 idx_rois = idx_rois & [k_response.num_of_target_trials_used]>0 & [k_response.num_of_baseline_trials_used]>0;
                    %                                 switch response_sign{i_sign}
                    %                                     case 'excited'
                    %                                         idx_rois = idx_rois & [k_response.response_mean_odd]>0;
                    %                                     case 'inhibited'
                    %                                         idx_rois = idx_rois & [k_response.response_mean_odd]<0;
                    %                                 end
                    %                                 if sum(idx_rois)>1
                    %                                     k_trace.response_trace_mean = sum(StimTrace.response_trace_mean(idx_rois,:),1);
                    %                                     k_trace.response_trace_mean_odd = sum(StimTrace.response_trace_mean_odd(idx_rois,:),1);
                    %                                     k_trace.response_trace_mean_even = sum(StimTrace.response_trace_mean_even(idx_rois,:),1);
                    %                                     k_trace.baseline_trace_mean = sum(StimTrace.baseline_trace_mean(idx_rois,:),1);
                    %                                     k_trace.responseraw_trace_mean = sum(StimTrace.responseraw_trace_mean(idx_rois,:),1);
                    %                                 else
                    %                                     k_trace.response_trace_mean = single(time+NaN);
                    %                                     k_trace.response_trace_mean_odd = single(time+NaN);
                    %                                     k_trace.response_trace_mean_even = single(time+NaN);
                    %                                     k_trace.baseline_trace_mean = single(time+NaN);
                    %                                     k_trace.responseraw_trace_mean = single(time+NaN);
                    %
                    %                                 end
                    %                                 k_trace.response_p_val = p_val(i_p);
                    %                                 k_trace.response_sign = response_sign{i_sign};
                    %                                 k_trace.flag_distance = flag_distance(i_dist);
                    %                                 k_trace.num_pairs = sum(idx_rois);
                    %                                 insert(STIM.ROIInfluenceTrace, k_trace);
                    %                             end
                    %                         end
                    %                     end
                    insert(self, k_response);
                end
            end
        end
    end
end
