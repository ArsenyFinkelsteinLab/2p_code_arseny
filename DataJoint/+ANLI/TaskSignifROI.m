%{
#  Significance of a activity for different task-related epochs/features
-> IMG.ROI
-> ANLI.TaskSignifName
---
task_signif_pval  = null    : double           # pval of each roi
signif_time1_st  = null     : double           # beginning of the first time interval used to compute the signif (seconds, relative to go cue).
signif_time1_end = null     : double           # end of the first time interval used to compute the signficance (seconds, relative to go cue).
signif_time2_st  = null     : double           # beginning of the second time interval used to compute the signficance (seconds, relative to go cue).
signif_time2_end  = null    : double           # end of the second time interval used to compute the signficance (seconds, relative to go cue).
task_signif_name_uid        : int              # unique id that could be used instead of specifying the task_signif_name
%}

classdef TaskSignifROI < dj.Computed
    properties
        %         keySource = EXP2.Session & EPHYS.TrialSpikes
        keySource = (EXP2.Session  & IMG.ROI);
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            tic
            key=fetch(IMG.FOV & key);
            
%             b=fetch((EXP2.BehaviorTrial*EXP2.TrialName) & key & 'early_lick="no early"','*','ORDER BY trial');
            b=fetch((EXP2.BehaviorTrial*EXP2.TrialName) & key ,'*','ORDER BY trial');

            b=struct2table(b); 
            
            F=fetch(ANLI.FPSTHMatrix & key,'*');
            F.psth_roi_tr_fr = F.psth_roi_tr_fr (:,:,1:numel(F.typical_psth_timestamps));
            t_sample_start =F.typical_time_sample_start;
            t_sample_end =F.typical_time_sample_end;
            
            
            % Stimulus
            k_insert=key;
            k_insert.task_signif_name = 'Stimulus';
            k_insert.task_signif_name_uid = 1;
            trials1 = find(strcmp(b.outcome,'hit') & strcmp(b.trial_type_name,'r'));  tint1 = [t_sample_start t_sample_end];
            trials2 = find(strcmp(b.outcome,'hit') & strcmp(b.trial_type_name,'l'));  tint2 = [t_sample_start t_sample_end];
            k_insert = fn_compute_roi_task_significance (F.psth_roi_tr_fr, trials1, trials2, tint1, tint2, F.typical_psth_timestamps, k_insert);
            insert( ANLI.TaskSignifROI, k_insert);
            
            
            % LateDelay
            k_insert=key;
            k_insert.task_signif_name = 'LateDelay';
            k_insert.task_signif_name_uid = 2;
            trials1 = find(strcmp(b.outcome,'hit') & strcmp(b.trial_type_name,'r'));  tint1 = [-1 0];
            trials2 = find(strcmp(b.outcome,'hit') & strcmp(b.trial_type_name,'l'));  tint2 = [-1 0];
            k_insert = fn_compute_roi_task_significance (F.psth_roi_tr_fr, trials1, trials2, tint1, tint2, F.typical_psth_timestamps, k_insert);
            insert( ANLI.TaskSignifROI, k_insert);
            
            
            % Movement
            k_insert=key;
            k_insert.task_signif_name = 'Movement';
            k_insert.task_signif_name_uid = 3;
            trials1 = find(strcmp(b.outcome,'hit') & strcmp(b.trial_type_name,'r'));  tint1 = [0 2];
            trials2 = find(strcmp(b.outcome,'hit') & strcmp(b.trial_type_name,'l'));  tint2 = [0 2];
            k_insert = fn_compute_roi_task_significance (F.psth_roi_tr_fr, trials1, trials2, tint1, tint2, F.typical_psth_timestamps, k_insert);
            insert( ANLI.TaskSignifROI, k_insert);
            
            % Ramping
            k_insert=key;
            k_insert.task_signif_name = 'Ramping';
            k_insert.task_signif_name_uid = 4;
            trials1 = find(strcmp(b.outcome,'hit'));  tint1 = [t_sample_start (t_sample_start+1)];
            trials2 = find(strcmp(b.outcome,'hit'));  tint2 = [-1 0];
            k_insert = fn_compute_roi_task_significance (F.psth_roi_tr_fr, trials1, trials2, tint1, tint2, F.typical_psth_timestamps, k_insert);
            insert( ANLI.TaskSignifROI, k_insert);
            
        end
    end
end