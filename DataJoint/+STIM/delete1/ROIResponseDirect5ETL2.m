%{
# Take the closest neuron within a small radius around the photostimulation site and assess its response, sites that are too far from cells won't appear here
-> IMG.PhotostimGroup
-> IMG.ROI
---
response_distance_lateral_um        : float                # (um) lateral (X-Y) distance from target to a given ROI
response_mean                       : float                # dff during photostimulatuon minus dff during photostimulation of control sites - averaged over all trials and over that time window
response_p_value1                   : float               # significance of response to photostimulation, relative to distant pre stimulus baseline, ttest
response_mean_odd                   : float                # for the  odd trials
response_p_value1_odd               : float                #
response_mean_even                  : float                # for the  even trials
response_p_value1_even               : float                #

response_std                        : float                # standard deviation of that value over trials
response_coefvar                    : float                # coefficient of variation of that value over trials
response_fanofactor                 : float                # fanto factor of that value over trials

response_distance_axial_um          : float                # (um) axial (Z) distance from target to a given ROI
response_distance_3d_um             : float                # (um)  3D distance from target to a given ROI

num_of_target_trials_used        : int                # number of target photostim trials used to compute response
%}


classdef ROIResponseDirect5ETL2 < dj.Imported
    properties
        %         keySource = IMG.PhotostimGroup;
        keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & (IMG.FOV & STIM.ROIInfluence5ETL);
    end
    methods(Access=protected)
        function makeTuples(self, key)
            distance_to_closest_neuron=25; %  in microns, max distance to direct neuron
            
            rel_data = STIM.ROIInfluence5ETL;
            
            group_num=  fetchn(IMG.PhotostimGroup & key,'photostim_group_num','ORDER BY photostim_group_num');
            
            temp = fetch(IMG.Plane & key);
            key.fov_num =  temp.fov_num;
            key.plane_num =  1;
            key.channel_num =  temp.channel_num;
            
            
            parfor i_g = 1:1:numel(group_num)
                    k1=key;
                    k1.photostim_group_num = group_num(i_g);
                    
                    p_value = 0.05; % threshod for direct neuron response
                    
                    C=fetch(rel_data & k1  & sprintf('response_distance_lateral_um <%.2f', distance_to_closest_neuron),'*', 'ORDER BY response_distance_lateral_um'); % meaning we take the neuron with the strongest response. If there are multiple neurons we should take C(end)
                    if ~isempty(C)
                        if C(1).response_p_value1<=p_value & C(1).response_mean>0 % checking if the neuron most close to the photostimulation coordinate has a significant and positive response
                            DIRECT=C(1);
                            if numel(C)>=2
                            end
                        else % if not, we check if the remaining neurons in the neiborhood have a significant and positive response, and if such neurons exist we take (from those remaining neurons) the neuron that is closest to the photostimulation coordinate
                            C_remaining=C;
                            C_remaining = C_remaining([C.response_p_value1]<=p_value & [C.response_mean]>0);
                            if ~isempty(C_remaining) % if no neuron has a significant and positve response, we take the closest neuron to the stimulation site as target, regardless of the signifcance or sign/magnitude of its response
                                DIRECT=C_remaining(1);
                                if numel(C_remaining)>=2
                                end
                            else
                                DIRECT=C(1);
                            end
                        end
                        DIRECT=rmfield(DIRECT,'num_svd_components_removed');
                        insert(self, DIRECT); % C(end) in case there are multiple neurons
                    end
                    
                    %                                             C=fetch(rel_data & k1  & sprintf('response_distance_lateral_um <%.2f', distance_to_closest_neuron),'*', 'ORDER BY response_distance_lateral_um'); % meaning we take the closest neuron
                    %                                             if ~isempty(C)
                    %                                                 DIRECT=C(1);
                    %                                                 insert(self, DIRECT);
                    %                                             end
                    
                    %                                             C=fetch(rel_data & k1  & sprintf('response_distance_lateral_um <%.2f', distance_to_closest_neuron),'*', 'ORDER BY response_mean'); % meaning we take the neuron with the strongest response. If there are multiple neurons we should take C(end)
                    %                                             if ~isempty(C)
                    %                                                 DIRECT=C(end);
                    %                                                 insert(self, DIRECT);
                    %                                             end
                    
            end
        end
        
    end
end

