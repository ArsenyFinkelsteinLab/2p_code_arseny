%{
#
-> EXP2.SessionEpoch
component_id             : int
threshold_for_event             : double     # threshold in deltaf_overf
time_bin                   : double             #time window used for binning the data. 0 means no binning
---
temporal_component       : longblob            # temporal component after SVD (fetching this table for all components should give the Vtransopose matrix from SVD) of size (components x frames). Includes the top num_comp components
%}

classdef SVDTemporalComponents < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)

        end
    end
end
