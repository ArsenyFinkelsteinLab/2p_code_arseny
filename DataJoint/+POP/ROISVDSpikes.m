%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
threshold_for_event        : double        # threshold in zscore, after binning. 0 means we don't threshold. 1 means we take only positive events exceeding 1 std, 2 means 2 std etc.
time_bin                   : double        # time window used for binning the data. 0 means no binning
---
roi_components             : longblob      # contribution of the temporal components to the activity of each neurons; fetching this table for all neurons should give U in SVD of size (neurons x components) for the top num_comp components
%}

classdef ROISVDSpikes < dj.Computed
    properties
        
        keySource =(EXP2.SessionEpoch & IMG.ROISpikes & STIMANAL.MiceIncluded) - EXP2.SessionEpochSomatotopy;

    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            threshold_for_event_vector=[0];
            
            rel_temp = IMG.Mesoscope & key;
            if rel_temp.count>0 % i.e its mesoscope data
                time_bin_vector=[1.5]; % we will bin the data into these time bins before doing SVD
            else
                time_bin_vector=[0.5, 1.5]; % we will bin the data into these time bins before doing SVD
            end
            
            flag_zscore=1; %0 only centering the data (i.e. mean subtraction),  1 zscoring the data
            threshold_variance_explained = 0.9; % We will save the weights of neurons (U) only for number of components needed to reach that level of cumulative variance explained
            num_components_save = 100; % We will save only this number of components

            rel_data1 = (IMG.ROISpikes & key)-IMG.ROIBad;
            self2 = POP.SVDSingularValuesSpikes;
            self3 = POP.SVDTemporalComponentsSpikes;
            for it=1:1:numel(time_bin_vector)
                fn_compute_SVD(key,rel_data1, self, self2, self3, flag_zscore, time_bin_vector(it), threshold_for_event_vector, threshold_variance_explained, num_components_save)
            end
            
        end
    end
end
