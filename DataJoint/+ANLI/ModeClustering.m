%{
#  Modes in Activity Space
-> IMG.ROI
-> EXP.TrialNameType
-> ANLI.EpochName
---
mode_unit_weight  = null  : double           # contribution (weight) of each unit to this mode
mode_time1_st             : double           # beginning of the first time interval used to compute the mode (seconds, relative to go cue).
mode_time1_end            : double           # end of the first time interval used to compute the mode (seconds, relative to go cue).
mode_time2_st  = null     : double           # beginning of the second time interval used to compute the mode (seconds, relative to go cue).
mode_time2_end  = null    : double           # end of the second time interval used to compute the mode (seconds, relative to go cue).
%}

classdef ModeClustering < dj.Computed
    properties
        %         keySource = EXP.Session & EPHYS.TrialSpikes
        keySource = (IMG.FOV) *(EXP.TrialNameType & 'task="sound"') * ANLI.EpochName;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            tic
            
            F=fetch(ANLI.FPSTHMatrix & key,'*');
            F.psth_roi_tr_fr = F.psth_roi_tr_fr (:,:,1:numel(F.typical_psth_timestamps));
            t_sample_start =F.typical_time_sample_start;
            t_sample_end =F.typical_time_sample_end;
            
            
            
            %% left delay
            trials1 = fetchn((ANLI.TrialCluster*EXP.TrialName) & key & 'trial_cluster_group=1','trial','ORDER BY trial');
            trials2 = fetchn((ANLI.TrialCluster*EXP.TrialName) & key & 'trial_cluster_group=2','trial','ORDER BY trial');

            if numel(trials1)>10 && numel(trials2>10)
                if strcmp(key.trial_epoch_name,'delay')
                    tint1 = [-1 0];
                    tint2 = tint1;
                elseif strcmp(key.trial_epoch_name,'response')
                    tint1 = [0 2];
                    tint2 = tint1;
                end
                    
                k_insert=key;
                [k_insert,weights] = fn_compute_roi_weights (F.psth_roi_tr_fr, trials1, trials2, tint1, tint2, F.typical_psth_timestamps, k_insert);
                insert(self, k_insert);
            end
            
        end
    end
end