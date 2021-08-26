%{
# Photostim Group
-> EXP2.SessionEpoch
photostim_group_num   : int #
---
neurons_or_control     :boolean              # 1 - neurons, 0 control
-> IMG.ROI
num_targets            : int             # number of neurons or control sites
%}


classdef NeuronOrControl5 < dj.Imported
    properties
        keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI & STIM.ROIResponseDirect5;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            neurons_or_control = [1,0];
            rel = STIM.ROIResponseDirect5 & key;
            
            pval_theshold_neurons=0.05;
            pval_theshold_control=0.05;
            z_score_threshold_neurons =0;
            z_score_threshold_controls =100;

            
            
            for i_n = 1:1:numel(neurons_or_control)
                
                if neurons_or_control(i_n) == 1 %neurons
                    %                                                 rel_direct= (rel & ['response_p_value1_odd<=' num2str(pval_theshold_neurons)] & ['response_mean_odd>=' num2str(z_score_threshold_neurons)] &  ['num_of_target_trials_used>=' num2str(minimal_num_of_target_trials_used)] & ['num_of_baseline_trials_used>1000']);
                    rel_direct= (rel & ['response_p_value1_odd<=' num2str(pval_theshold_neurons)] & ['response_mean_odd>' num2str(z_score_threshold_neurons)]);
                elseif neurons_or_control(i_n) == 0 % control sites
                    %                                                 rel_direct= (rel & ['response_p_value1_odd>=' num2str(pval_theshold_control)] & ['response_mean_odd<' num2str(z_score_threshold_controls)]  &  ['num_of_target_trials_used>=' num2str(minimal_num_of_target_trials_used)] & ['num_of_baseline_trials_used>1000']);
                    rel_direct= (rel & ['response_p_value1_odd>' num2str(pval_theshold_control)] & ['response_mean_odd<' num2str(z_score_threshold_controls)]) ;
                end
                kkk=fetch(rel_direct);
                
                
                for i=1:1:numel(kkk)
                    kkk(i).neurons_or_control=neurons_or_control(i_n);
                    kkk(i).num_targets=rel_direct.count;
                end
                insert(self,kkk);
            end
            
        end
    end
end