%{
# Projection of the neural acitivity on a mode (neuron weights vector)
-> EXP.Session
-> EXP.TrialNameType
-> ANLI.EpochName
trial_cluster_group             : int
---
num_trials_projected            : int            # number of projected trials in this trial-type/outcome
proj_average                    : longblob       # projection of the neural acitivity on the mode (weights vector) for this trial-type/outcome, given in arbitrary units.
psth_timestamps                 : longblob    # timestamps of each frame relative to go cue
time_sample_start               : double      # time of sample start relative to go cue
time_sample_end                 : double      # time of sample end relative to go cue
%}


classdef ProjClusterTrialAverage < dj.Computed
    properties
        keySource = (EXP.Session  & IMG.ROI) * (EXP.TrialNameType & 'task="sound"')  * ANLI.EpochName ;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            trial_cluster_group=[1,2];
            
            for i_g=1:1:numel(trial_cluster_group)
                
                key.trial_cluster_group=trial_cluster_group(i_g);
                
                Favg = cell2mat(fetchn((ANLI.FPSTHaverageClusterbased & ANLI.IncludeROImultiSession2intersect)  & key,'psth_avg', 'ORDER BY roi_number'));
                
                if size(Favg,2)<2
                    return
                end
                
                weights = fetchn((ANLI.ModeClustering & ANLI.IncludeROImultiSession2intersect) & key,'mode_unit_weight', 'ORDER BY roi_number');
                
                w_mat = repmat(weights,1,size(Favg,2));
                proj_avg = nansum( Favg.*w_mat);
                
                
                key_insert=key;
                key_insert.proj_average =proj_avg;
                key_insert.num_trials_projected =size(Favg,2); %% SHOULD BE CORRECTED
                
                key_insert.time_sample_start =fetch1(ANLI.FPSTHMatrix & key,'typical_time_sample_start');
                key_insert.time_sample_end =fetch1(ANLI.FPSTHMatrix & key,'typical_time_sample_end');
                key_insert.psth_timestamps =fetch1(ANLI.FPSTHMatrix & key,'typical_psth_timestamps');
                
                insert(self,key_insert);
                
                %                         roi_list = fetchn(ANLI.FPSTHaverage & key, 'roi_number', 'ORDER BY roi_number');
                %             for i_roi=1:1:numel(roi_list)
                %                 key.roi_number = roi_list (i_roi);
                %                 F = (ANLI.FPSTHaverage & key, 'ORDER BY trial')
                %             end
                
                
            end
        end
    end
end