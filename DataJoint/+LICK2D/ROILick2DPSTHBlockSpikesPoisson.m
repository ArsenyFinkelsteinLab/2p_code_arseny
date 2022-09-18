%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
---
psth_first_poisson=null          : blob   # PSTH averaged across block  first trials
psth_begin_poisson=null          : blob   # PSTH averaged across block beginning trials
psth_mid_poisson=null          : blob     # PSTH averaged across block mid trials
psth_end_poisson=null          : blob     # PSTH averaged across block end trials

psth_first_stem_poisson=null   : blob     # PSTH standard error of the mean
psth_begin_stem_poisson=null   : blob     # 
psth_mid_stem_poisson=null     : blob     # 
psth_end_stem_poisson=null     : blob     # 

%}


classdef ROILick2DPSTHBlockSpikesPoisson < dj.Computed
    methods(Access=protected)
        function makeTuples(self, key)
            
            
        end
    end
end
