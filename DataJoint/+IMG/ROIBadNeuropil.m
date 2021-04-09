%{
# include good ROI that were considered cell by suite2p
-> IMG.ROI
%}


classdef ROIBadNeuropil < dj.Imported
    properties
        keySource = EXP2.Session & IMG.Mesoscope;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            threshold_max=15;
            threshold_min=-1;
            
            key_roi = fetch(IMG.ROI & key,'ORDER BY roi_number');
            rel=(IMG.ROIdeltaFStatsNeuropil & IMG.Mesoscope)-EXP2.SessionEpochSomatotopy;
            
            %% based on spontaneous session
            key.session_epoch_type='spont_only';
            m=fetchn(rel & key,'max_dff','ORDER BY roi_number');
            % histogram(m,[0:1:max(m)])
            idx_bad_max_spont=(m>threshold_max);
            
            m=fetchn(rel & key,'min_dff','ORDER BY roi_number');
            % histogram(m)
            idx_bad_min_spont=(m<threshold_min);
            
            %% based on behav session
            key.session_epoch_type='behav_only';
            m=fetchn(rel & key,'max_dff','ORDER BY roi_number');
            % histogram(m,[0:1:max(m)])
            idx_bad_max_behav=(m>threshold_max);
            
            m=fetchn(rel & key,'min_dff','ORDER BY roi_number');
            % histogram(m)
            idx_bad_min_behav=(m<threshold_min);
            
            if isempty(idx_bad_max_spont)
                idx_bad_combined = idx_bad_max_behav | idx_bad_min_behav;
            elseif isempty(idx_bad_max_behav)
                idx_bad_combined = idx_bad_max_spont | idx_bad_min_spont;
            else
                idx_bad_combined = idx_bad_max_spont | idx_bad_min_spont | idx_bad_max_behav | idx_bad_min_behav;
            end
            key_roi = key_roi(idx_bad_combined);

            insert(self,key_roi);
            
        end
    end
end