%{
# Pairwise correlation as a function of distance
-> EXP2.SessionEpoch
threshold_for_event             : double          # threshold in zscore, after binning. 0 means we don't threshold. 1 means we take only positive events exceeding 1 std, 2 means 2 std etc.
num_svd_components_removed      : int     # how many of the first svd components were removed
---
corr_histogram                        :blob        # histogram of all pairwise correlations
corr_histogram_bins                   :blob        # corresponding bins
distance_corr_all                     :blob        # average pairwise pearson coeff, binned according to lateral distance between neurons
distance_corr_positive                :blob        # average positive pairwise pearson coeff, binned according to lateral distance between neurons
distance_corr_negative                :blob        # average negative pairwise pearson coeff, binned according to lateral distance between neurons
distance_bins                         :blob        # corresponding bins
corr_histogram_per_distance           :longblob    # a matrix containing, for each distance bin, the histogram of correlations in this distance bin, binned into corr_histogram_bins
variance_explained_components         :blob        # by the SVD components
%}


classdef CorrPairwiseDistanceSVDSpikes < dj.Computed
    properties
        keySource =(EXP2.SessionEpoch & IMG.ROISpikes & STIMANAL.MiceIncluded & IMG.PlaneCoordinates)- EXP2.SessionEpochSomatotopy;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_save_fig = [dir_base  '\POP\corr_distance\spikes\'];
            
            threshold_for_event_vector=[0];
            rel_temp = IMG.Mesoscope & key;
            if rel_temp.count>0 % i.e its mesoscope data
                time_bin_vector=[1.5]; % we will bin the data into these time bins before doing SVD
            else
                time_bin_vector=[1.5]; % we will bin the data into these time bins before doing SVD
            end
            
            flag_zscore=1; %0 only centering the data (i.e. mean subtraction),  1 zscoring the data
            rel_data = (IMG.ROISpikes & key)-IMG.ROIBad;
            for it=1:1:numel(time_bin_vector)
                fn_compute_CorrPairwiseDistance(key, rel_data, self, flag_zscore,time_bin_vector(it), threshold_for_event_vector, dir_save_fig)
            end
        end
    end
end

