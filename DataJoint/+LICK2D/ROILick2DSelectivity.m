%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
number_of_bins            : int   #
---
psth_preferred            : blob   # psth averaged over the preferred map position/positions
psth_preferred_odd        : blob   #
psth_preferred_even       : blob   #
psth_non_preferred        : blob   # psth averaged over all non preferred map positions

selectivity               : blob   # psth preferred - non-preferred
selectivity_odd           : blob   #
selectivity_even          : blob   #

selectivity_first=null         : blob   # first trial in block
selectivity_begin=null          : blob   #  trials in the beginning of the block
selectivity_mid=null            : blob   # trials in the middle of the block
selectivity_end=null            : blob   # trials in the end of the block
selectivity_small=null          : blob   # during no rewarded trials
selectivity_regular=null        : blob   # during trials with typical reward
selectivity_large=null          : blob   # during trials with large reward

selectivity_time          : blob   # time vector

%}


classdef ROILick2DSelectivity < dj.Imported
    properties
        keySource = EXP2.SessionEpoch & IMG.ROI & EXP2.TrialLickPort & 'session_epoch_type="behav_only"' & EXP2.TrialLickBlock;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            %             for i_numbin=[4]
            %                 key.number_of_bins = i_numbin;
            %
            % %                 key.fr_interval_start = -2000;
            % %                 key.fr_interval_end = 0;
            % %                 fn_computer_Lick2Dmap(key,self);
            % %
            % %                 key.fr_interval_start = -1000;
            % %                 key.fr_interval_end = 0;
            % %                 fn_computer_Lick2Dmap(key,self);
            % %
            % %                 key.fr_interval_start = -1000;
            % %                 key.fr_interval_end = 1000;
            % %                 fn_computer_Lick2Dmap(key,self);
            % %
            % %                 key.fr_interval_start = 0;
            % %                 key.fr_interval_end = 1000;
            % %                 fn_computer_Lick2Dmap(key,self);
            %
            %                 key.fr_interval_start = -1000;
            %                 key.fr_interval_end = 2000;
            %                 fn_computer_Lick2Dselectivity(key,self);
            %end
        end
    end
end
