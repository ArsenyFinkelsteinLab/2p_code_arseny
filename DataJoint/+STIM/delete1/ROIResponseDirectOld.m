%{
# Take the closest neuron within a small radius around the photostimulation site and assess its response, sites that are too far from cells won't appear here
-> IMG.PhotostimGroup
-> IMG.ROI
---
response_p_value1                    : float               # significance of response to photostimulation, relative to baseline
response_p_value2                   : float                # significance of response to photostimulation, relative to baseline
response_p_value3                   : float                # significance of response to photostimulation, relative to baseline
response_mean                       : float                # dff atr some time after photostimulatuon minus dff at some time before the photostimulation - averaged over all trials and over that time window
response_std                        : float                # standard deviation of that value over trials
response_coefvar                    : float                # coefficient of variation of that value over trials
response_fanofactor                 : float                # fanto factor of that value over trials
response_tstat                      : float                # ttest  statistic   xmean-ymean/sqrt(stdev^2/n ystdev^2/m)

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


classdef ROIResponseDirectOld < dj.Imported
    properties
        %         keySource = IMG.PhotostimGroup;
        keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & (IMG.FOV & STIM.ROIResponseZscore);
    end
    methods(Access=protected)
        function makeTuples(self, key)
            distance_to_closest_neuron=25; %  in microns, max distance to direct neuron
            %             response_p_value = 0.05; % threshod for direct neuron response
            response_p_value=1;
            
            num_svd_components_removed_vector = 0;
            
            group_num=  fetchn(IMG.PhotostimGroup & key,'photostim_group_num','ORDER BY photostim_group_num');
            
            temp = fetch(IMG.Plane & key);
            key.fov_num =  temp.fov_num;
            key.plane_num =  1;
            key.channel_num =  temp.channel_num;
            
            parfor i_g = 1:1:numel(group_num)
                k1=key;
                k1.photostim_group_num = group_num(i_g);
                C=fetch(STIM.ROIResponseZscore & k1 & sprintf('response_p_value1 <=%.10f', response_p_value) & sprintf('num_svd_components_removed=%d', num_svd_components_removed_vector) & sprintf('response_distance_lateral_um <%.2f', distance_to_closest_neuron),'*', 'ORDER BY response_mean_odd'); % meaning we take the neuron with the strongest response. If there are multiple neurons we should take C(end)
                C=rmfield(C,'num_svd_components_removed');
                if ~isempty(C)
                    insert(self, C(end)); % C(end) in case there are multiple neurons
                end
            end
            
        end
    end
end