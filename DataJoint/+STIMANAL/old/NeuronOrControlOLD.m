%{
# Photostim Group
-> EXP2.SessionEpoch
photostim_group_num   : int #
---
neurons_or_control     :boolean              # 1 - neurons, 0 control
-> IMG.ROI
num_targets            : boolean             # number of neurons or control sites
%}


classdef NeuronOrControlOLD < dj.Imported
    properties
        keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI & STIM.ROIResponseDirect;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            n_flag = [0,1];
                for i_n = 1:1:numel(n_flag)
                    if n_flag(i_n) == 1 %neurons
                        rel_direct= (STIM.ROIResponseDirect & key & 'response_p_value1_odd<=0.01' & 'response_mean_odd>=0.2');
                    elseif n_flag(i_n) == 0 % control sites
                        rel_direct= (STIM.ROIResponseDirect & key & 'response_p_value1_odd>0.05' & 'response_mean_odd<0.2');
                    end
                    kkk=fetch(rel_direct);
                    for i=1:1:numel(kkk)
                        kkk(i).neurons_or_control=n_flag(i_n);
                        kkk(i).num_targets=rel_direct.count;
                    end
                    insert(self,kkk);
                end
            
        end
    end
end