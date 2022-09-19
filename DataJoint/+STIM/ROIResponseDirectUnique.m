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
        keySource = EXP2.SessionEpoch & STIM.ROIResponseDirect2;
    end
    methods(Access=protected)
        function makeTuples(self, key)

            rel_direct = STIM.ROIResponseDirect2 & key;
            
            C_direct=fetch(rel_direct,'*', 'ORDER BY photostim_group_num');

            roi_all = [C_direct.roi_number];
            roi_unique = unique([C_direct.roi_number]);
            for i=1:1:numel(roi_unique)
                idx_roi = find(roi_all==roi_unique(i));
                C_current = C_direct(idx_roi);
                if numel(C_current)>1
                [~,idx_pval] = sort([C_current.response_p_value1], 'ascend');
                    insert(self,C_current(idx_pval(1)));
                else
                    insert(self,C_direct(idx_roi));
                end
            end
            
        end
    end
    
end


