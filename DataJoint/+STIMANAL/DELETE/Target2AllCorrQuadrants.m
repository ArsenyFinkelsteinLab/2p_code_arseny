%{
# Pairwise correlation between the activity of a target neuron and each of the rest of the neurons
-> EXP2.SessionEpoch
-> IMG.PhotostimGroup
---
rois_corr                        :blob    # correlation between the activity of the target neuron an each of the ROI, including self
%}


classdef Target2AllCorrQuadrants < dj.Computed
    properties
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            rel_roi = (IMG.ROI - IMG.ROIBad) & key;
            
            
            keytemp = rmfield(key,'session_epoch_number');
            keytemp.session_epoch_type='behav_only';
            key_behav = fetch(EXP2.SessionEpoch & keytemp,'LIMIT 1');
            
            rel_data = LICK2D.ROILick2DQuadrantsSpikes & rel_roi;

            
            %% Loading Data
            rel_photostim =IMG.PhotostimGroup*(STIM.ROIResponseDirect2) & key;
            group_list = fetchn(rel_photostim,'photostim_group_num','ORDER BY photostim_group_num');
            target_roi_list = fetchn(rel_photostim,'roi_number','ORDER BY photostim_group_num');
            
            roi_list=fetchn(rel_data &key_behav,'roi_number','ORDER BY roi_number');
            PSTH=cell2mat(fetchn(rel_data,'psth_quadrants','ORDER BY roi_number'));
            
       
            rho=corr(PSTH','rows','pairwise');
            
            k_insert = repmat(key,numel(group_list),1);
            
            parfor i_g = 1:1:numel(group_list)
                target_roi_idx = (roi_list == target_roi_list(i_g));
                k_insert(i_g).photostim_group_num = group_list(i_g);
                corr_with_target= rho(target_roi_idx,:);
                corr_with_target(target_roi_idx)=NaN; %setting self correlation to NaN
                k_insert(i_g).rois_corr =corr_with_target;
            end
            insert(self,k_insert);
        end
    end
end

