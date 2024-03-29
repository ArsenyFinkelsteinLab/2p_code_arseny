%{
# Finds neurons that were directly photostimulated, by taking the closest neuron within a small radius around the photostimulation
# site and assess its response. This table can include both neurons that responded to direct photostimulation, but also non-responding neurons in case some photostimulation sites did not elicit responses. Photostimulation sites that happen to be too
# far from actual neurons won't be saved here.  In this table we define a
# unique correspondence between PhotostimGroup and ROI, so if several PhotostimGroup targets the same cell, we save only one target here (the one that had the most number of influenced cells by it)

-> IMG.PhotostimGroup
-> IMG.ROI
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

num_of_target_trials_used        : int                # number of target photostim trials used to compute response
%}


classdef ROIResponseDirectUnique < dj.Imported
    properties
        %         keySource = IMG.PhotostimGroup;
        keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & STIMANAL.OutDegree & (IMG.FOV & STIM.ROIInfluence2) & (STIMANAL.SessionEpochsIncludedFinal & 'flag_include=1');
    end
    methods(Access=protected)
        function makeTuples(self, key)
            distance_to_closest_neuron=25; %  in microns, max distance to direct neuron
            p_value = 0.05; % threshod for direct neuron response

            rel_data = STIM.ROIInfluence2;
            
            group_num=  fetchn(IMG.PhotostimGroup & key,'photostim_group_num','ORDER BY photostim_group_num');
            
            temp = fetch(IMG.Plane & key);
            key.fov_num =  temp.fov_num;
            key.plane_num =  1;
            key.channel_num =  temp.channel_num;
            
            
            parfor i_g = 1:1:numel(group_num) %parfor
                    k1=key;
                    k1.photostim_group_num = group_num(i_g);
                    
                    
                    C=fetch(rel_data & k1  & sprintf('response_distance_lateral_um <%.2f', distance_to_closest_neuron),'*', 'ORDER BY response_distance_lateral_um'); % We sort neurons according to the distance from the photostimulation coordinate
                    if ~isempty(C) % if there are no neurons in the vicinity of the photostimulation coordinate, we don't populate the entry for this PhotostimGroup
                        if C(1).response_p_value1<=p_value & C(1).response_mean>0 % checking if the neuron most close C(1) to the photostimulation coordinate has a significant and positive response
                            DIRECT=C(1); % if yes, we take it as our directly targeted neuron
                        else % if not, we check if other neurons in the neiborhood have a significant and positive response
                            C_remaining=C;
                            C_remaining = C_remaining([C.response_p_value1]<=p_value & [C.response_mean]>0);
                            if ~isempty(C_remaining) % if such neurons exist we take (from those remaining neurons)  the neuron that is closest to the photostimulation coordinate. Neurons are sortex by proximity, hence the index 1 in  C_remaining(1)
                                DIRECT=C_remaining(1);
                            else
                                DIRECT=C(1); % if no neuron has a significant and positve response, we take the closest neuron to the stimulation site as target, regardless of the signifcance or sign/magnitude of its response
                            end
                        end
                        DIRECT=rmfield(DIRECT,'num_svd_components_removed'); %this field is not needed, hence removed
                        insert(self, DIRECT); 
                    end
            end
        end
        
    end
end

