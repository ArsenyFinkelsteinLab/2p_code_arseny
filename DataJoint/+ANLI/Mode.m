%{
#  Modes in Activity Space
-> IMG.ROI
-> ANLI.ModeTypeName
mode_time1_st             : double           # beginning of the first time interval used to compute the mode (seconds, relative to go cue).
---
mode_unit_weight  = null  : double           # contribution (weight) of each unit to this mode
mode_time1_end            : double           # end of the first time interval used to compute the mode (seconds, relative to go cue).
mode_time2_st  = null     : double           # beginning of the second time interval used to compute the mode (seconds, relative to go cue).
mode_time2_end  = null    : double           # end of the second time interval used to compute the mode (seconds, relative to go cue).
mode_uid                  : int              # unique id that could be used instead of specifying the mode_name
%}

classdef Mode < dj.Computed
    properties
        %         keySource = EXP2.Session & EPHYS.TrialSpikes
        keySource = (EXP2.Session  & IMG.ROI);
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            tic
            
            
            key=fetch(IMG.FOV & key);
            
%             b=fetch((EXP2.BehaviorTrial*EXP2.TrialName) & key & 'early_lick="no early"','*','ORDER BY trial');
            b=fetch((EXP2.BehaviorTrial*EXP2.TrialName) & key,'*','ORDER BY trial');

            b=struct2table(b);
            
            F=fetch(ANLI.FPSTHMatrix & key,'*');
            F.psth_roi_tr_fr = F.psth_roi_tr_fr (:,:,1:numel(F.typical_psth_timestamps));
            t_sample_start =F.typical_time_sample_start;
            t_sample_end =F.typical_time_sample_end;
            
            % Stimulus
            k_insert=key;
            k_insert.mode_type_name = 'Stimulus';
            k_insert.mode_uid = 1;
            trials1 = find(strcmp(b.outcome,'hit') & strcmp(b.trial_type_name,'r'));  tint1 = [t_sample_start t_sample_end];
            trials2 = find(strcmp(b.outcome,'hit') & strcmp(b.trial_type_name,'l'));  tint2 = [t_sample_start t_sample_end];
            [k_insert,weights{1}] = fn_compute_roi_weights (F.psth_roi_tr_fr, trials1, trials2, tint1, tint2, F.typical_psth_timestamps, k_insert);
            insert( ANLI.Mode, k_insert);
            
            % LateDelay
            k_insert=key;
            k_insert.mode_type_name = 'LateDelay';
            k_insert.mode_uid = 2;
            trials1 = find(strcmp(b.outcome,'hit') & strcmp(b.trial_type_name,'r'));  tint1 = [-0.5 0];
            trials2 = find(strcmp(b.outcome,'hit') & strcmp(b.trial_type_name,'l'));  tint2 = [-0.5 0];
            [k_insert,weights{2}] = fn_compute_roi_weights (F.psth_roi_tr_fr, trials1, trials2, tint1, tint2, F.typical_psth_timestamps, k_insert);
            insert( ANLI.Mode, k_insert);
            
            % Movement
            k_insert=key;
            k_insert.mode_type_name = 'Movement';
            k_insert.mode_uid = 3;
            trials1 = find(strcmp(b.outcome,'hit') & strcmp(b.trial_type_name,'r'));  tint1 = [0 2];
            trials2 = find(strcmp(b.outcome,'hit') & strcmp(b.trial_type_name,'l'));  tint2 = [0 2];
            [k_insert,weights{3}] = fn_compute_roi_weights (F.psth_roi_tr_fr, trials1, trials2, tint1, tint2, F.typical_psth_timestamps, k_insert);
            insert( ANLI.Mode, k_insert);
            
            % Ramping
            k_insert=key;
            k_insert.mode_type_name = 'Ramping';
            k_insert.mode_uid = 4;
            trials1 = find(strcmp(b.outcome,'hit'));  tint1 = [-1 0] ;
            trials2 = find(strcmp(b.outcome,'hit'));  tint2 = [t_sample_start (t_sample_start+1)];
            [k_insert,weights{4}] = fn_compute_roi_weights (F.psth_roi_tr_fr, trials1, trials2, tint1, tint2, F.typical_psth_timestamps, k_insert);
            insert( ANLI.Mode, k_insert);
        end
    end
end