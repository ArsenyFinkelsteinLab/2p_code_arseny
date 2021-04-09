%{
#
-> IMG.ROI
-> EXP2.EpochName
-> EXP2.TrialNameType
trial_cluster_group             : int
---
num_trials_averaged             : int         # number of trials averaged per condition, for this ROI
psth_avg                        : longblob    # trial-type averaged PSTH aligned to go cue time, expressed as deltaF/F, where F is the baseline flourescene in the beginning of each trial
psth_stem                       : longblob    # standard error of the mean of the above, expressed as deltaF/F
psth_timestamps                 : longblob    # timestamps of each frame relative to go cue
time_sample_start               : double      # time of sample start relative to go cue
time_sample_end                 : double      # time of sample end relative to go cue
%}


classdef FPSTHaverageClusterbased < dj.Computed
    properties
        keySource = (IMG.FOV  & IMG.ROI) * (EXP2.TrialNameType & 'task="sound"') * EXP2.EpochName;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            trial_cluster_group=[1,2];
            
            roi_list=fetchn(IMG.ROI & key,'roi_number');
            
            key.time_sample_start =fetch1(ANLI.FPSTHMatrix & key,'typical_time_sample_start');
            key.time_sample_end =fetch1(ANLI.FPSTHMatrix & key,'typical_time_sample_end');
            psth_timestamps =fetch1(ANLI.FPSTHMatrix & key,'typical_psth_timestamps');
            
            
            for i_g=1:1:numel(trial_cluster_group)
                key_group.trial_cluster_group = trial_cluster_group(i_g);
                rel=(ANLI.TrialCluster*EXP2.TrialName & key & key_group);
                trials_group = fetchn(rel,'trial','ORDER BY trial');
                numberTrials = numel(trials_group);
                frames_per_trial=fetchn(IMG.ROITrial & key & 'roi_number=1' & rel,'frames_per_trial','ORDER BY trial');
                
                for iROI = 1:numel(roi_list)
                    key_FPSTHaverage=[];
                    F=zeros(numberTrials,max([frames_per_trial;numel(psth_timestamps)])) + NaN;
                    key_roi.roi_number=roi_list(iROI);
                    
                    FPSTHtrial=fetchn((ANLI.FPSTHtrial & rel) & key_roi,'psth_trial','ORDER BY trial');
                    
                    for iTr=1:1:numberTrials
                        F(iTr,1:frames_per_trial(iTr))=FPSTHtrial{iTr};
                    end
                    
                    F=F(:,1:numel(psth_timestamps));
                    psth_avg = nanmean(F,1);
                    psth_stem = nanstd(F,1)/sqrt(numberTrials);
                    
                    key_FPSTHaverage=key;
                    key_FPSTHaverage.roi_number = roi_list(iROI);
                    key_FPSTHaverage.trial_cluster_group =  trial_cluster_group(i_g);
                    key_FPSTHaverage.psth_timestamps=psth_timestamps;
                    key_FPSTHaverage.num_trials_averaged=numberTrials;
                    key_FPSTHaverage.psth_avg=psth_avg;
                    key_FPSTHaverage.psth_stem=psth_stem;
                    
                    insert(self, key_FPSTHaverage)
                    
                end
            end
        end
    end
end