%{
#
-> EXP2.SessionEpoch
threshold_for_event             : double     # threshold in deltaf_overf
time_bin                   : double             #time window used for binning the data. 0 means no binning
---
singular_values   : longblob         #  singular values of each SVD temporal component, ordered from larges to smallest value 
%}

classdef SVDSingularValuesPython < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)
            
        end
    end
end