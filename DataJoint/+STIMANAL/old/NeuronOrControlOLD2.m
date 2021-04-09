%{
# Photostim Group
-> EXP2.SessionEpoch
photostim_group_num   : int #
---
neurons_or_control     :boolean              # 1 - neurons, 0 control
-> IMG.ROI
num_targets            : boolean             # number of neurons or control sites
%}


classdef NeuronOrControl < dj.Imported
    properties
        keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI & STIM.ROIResponseDirect;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            k.flag_zscore=0;
            n_flag = [1,0];
            rel = STIM.ROIResponseDirect & key & k;
                for i_n = 1:1:numel(n_flag)
                   
                    if n_flag(i_n) == 1 %neurons
                        rel_direct= (rel & 'response_p_value1<=0.05' & 'response_mean>0');
                    elseif n_flag(i_n) == 0 % control sites
                        rel_direct= (rel & 'response_p_value1>0.1');
                    end
                    kkk=fetch(rel_direct);
                    kkk=rmfield(kkk,'flag_zscore');

%                     kkk=fetch(rel_direct,'*');
%                     plot([kkk.response_mean],-log10([kkk.response_p_value1]),'.')
%                     histogram([kkk.response_distance_lateral_um])
                    
                    
                    for i=1:1:numel(kkk)
                        kkk(i).neurons_or_control=n_flag(i_n);
                        kkk(i).num_targets=rel_direct.count;
                    end
                    insert(self,kkk);
                end
            
        end
    end
end