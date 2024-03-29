%{
# Pairwise correlation between the activity of a target neuron and each of the rest of the neurons
-> EXP2.SessionEpoch
-> IMG.PhotostimGroup
---
rois_corr                        :blob    # correlation between the activity of the target neuron an each of the ROI, including self
%}

classdef Target2AllCorrAngle < dj.Computed
    properties
        keySource = (EXP2.SessionEpoch& 'session_epoch_type="spont_photo"') & (EXP2.Session & (EXP2.SessionEpoch & 'session_epoch_type="behav_only"')  & (EXP2.SessionEpoch & LICK2D.ROILick2DangleStatsSpikes3bins)) & STIM.ROIResponseDirectUnique;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
            rel_roi = (IMG.ROI - IMG.ROIBad) & key;
            
            
            keytemp = rmfield(key,'session_epoch_number');
            keytemp.session_epoch_type='behav_only';
            key_behav = fetch(EXP2.SessionEpoch & keytemp,'LIMIT 1');
            
            
            
            %% Loading Data
            rel_data = LICK2D.ROILick2DangleStatsSpikes3bins & rel_roi;
            rel_photostim =(IMG.PhotostimGroup*STIM.ROIResponseDirectUnique) & key & rel_roi;
            group_list = fetchn(rel_photostim,'photostim_group_num','ORDER BY photostim_group_num');
            target_roi_list = fetchn(rel_photostim,'roi_number','ORDER BY photostim_group_num');
            
            roi_list=fetchn(rel_data &key_behav,'roi_number','ORDER BY roi_number');
            theta=fetchn(rel_data,'preferred_theta_regular','ORDER BY roi_number')';
            
            k_insert = repmat(key,numel(group_list),1);
            
            parfor i_g = 1:1:numel(group_list)
                target_roi_idx = (roi_list == target_roi_list(i_g));
                k_insert(i_g).photostim_group_num = group_list(i_g);
                target_theta = theta(target_roi_idx);
                delta_theta = circ_dist(deg2rad(theta),deg2rad(target_theta));
                delta_theta = abs(rad2deg(delta_theta));
                delta_theta(target_roi_idx)=NaN; %setting self correlation to NaN
                k_insert(i_g).rois_corr =delta_theta;
            end
            insert(self,k_insert);
        end
    end
end


