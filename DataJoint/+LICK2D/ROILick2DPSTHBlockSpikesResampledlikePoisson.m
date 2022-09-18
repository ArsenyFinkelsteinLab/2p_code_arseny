%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
psth_first=null          : blob   # PSTH averaged across block  first trials
psth_first_odd=null      : blob   # odd first trials
psth_first_even=null     : blob   # even firs trials

psth_begin=null          : blob   # PSTH averaged across block beginning trials
psth_begin_odd=null      : blob   # 
psth_begin_even=null     : blob   #

psth_mid=null          : blob     # PSTH averaged across block mid trials
psth_mid_odd=null      : blob     # 
psth_mid_even=null     : blob     #

psth_end=null          : blob     # PSTH averaged across block end trials
psth_end_odd=null      : blob     # 
psth_end_even=null     : blob     #

psth_first_stem=null   : blob     # PSTH standard error of the mean
psth_begin_stem=null   : blob     # 
psth_mid_stem=null     : blob     # 
psth_end_stem=null     : blob     # 

%}


classdef ROILick2DPSTHBlockSpikesResampledlikePoisson < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)
            
            
        end
    end
end
