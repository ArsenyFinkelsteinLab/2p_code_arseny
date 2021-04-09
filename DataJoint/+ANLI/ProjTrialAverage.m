%{
# Projection of the neural acitivity on a mode (neuron weights vector)
-> EXP2.Session
-> ANLI.ModeTypeName
-> EXP2.Outcome
-> EXP2.TrialNameType
---
num_trials_projected        : int            # number of projected trials in this trial-type/outcome
proj_average                : longblob       # projection of the neural acitivity on the mode (weights vector) for this trial-type/outcome, given in arbitrary units. 
psth_timestamps                 : longblob    # timestamps of each frame relative to go cue
time_sample_start               : double      # time of sample start relative to go cue
time_sample_end                 : double      # time of sample end relative to go cue
%}


classdef ProjTrialAverage < dj.Computed
    properties
        keySource = (EXP2.Session  & IMG.ROI)  * EXP2.Outcome  * (ANLI.ModeTypeName& ANLI.Mode) * (EXP2.TrialNameType & 'task="sound"');
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            Favg = cell2mat(fetchn((ANLI.FPSTHaverage & ANLI.IncludeROImultiSession2intersect)  & key,'psth_avg', 'ORDER BY roi_number'));
            
            if size(Favg,2)<2
                return
            end
            
            weights = fetchn((ANLI.Mode & ANLI.IncludeROImultiSession2intersect) & key,'mode_unit_weight', 'ORDER BY roi_number');
            
            w_mat = repmat(weights,1,size(Favg,2));
            proj_avg = nansum( Favg.*w_mat);
            
            key.proj_average =proj_avg;
            key.num_trials_projected =size(Favg,2); %% SHOULD BE CORRECTED

            key.time_sample_start =fetch1(ANLI.FPSTHMatrix & key,'typical_time_sample_start');
            key.time_sample_end =fetch1(ANLI.FPSTHMatrix & key,'typical_time_sample_end');
            key.psth_timestamps =fetch1(ANLI.FPSTHMatrix & key,'typical_psth_timestamps');

                  insert(self,key);      
                        
%                         roi_list = fetchn(ANLI.FPSTHaverage & key, 'roi_number', 'ORDER BY roi_number');
%             for i_roi=1:1:numel(roi_list)
%                 key.roi_number = roi_list (i_roi);
%                 F = (ANLI.FPSTHaverage & key, 'ORDER BY trial')
%             end
            
            
          
        end
    end
end