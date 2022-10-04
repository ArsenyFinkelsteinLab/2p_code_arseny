%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
psth_regular             : blob   # averaged over all positions, during trials with typical reward
psth_regular_odd         : blob   # averaged over all positions, during odd trials with typical reward
psth_regular_even        : blob   # averaged over all positions, during odd trials with typical reward

psth_small=null          : blob   # during no rewarded trials
psth_small_odd=null      : blob   # during no rewarded trials
psth_small_even=null     : blob   # during no rewarded trials

psth_large=null          : blob   # during trials with large reward
psth_large_odd=null      : blob   # during trials with large reward
psth_large_even=null     : blob   # during trials with large reward

psth_regular_stem        : blob   # standard error of the mean
psth_small_stem=null     : blob   # 
psth_large_stem=null     : blob   # 

psth_time                : longblob   # time vector
%}


classdef ROILick2DPSTHSpikesExample < dj.Imported
    properties
        keySource = EXP2.Session & IMG.ROIExample;
    end
    methods(Access=protected)
        function makeTuples(self, key)
           k = fetch(LICK2D.ROILick2DPSTHSpikes & IMG.ROIExample & key,'*');
           insert(self,k);
        end
    end
end
