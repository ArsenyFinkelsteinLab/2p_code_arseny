%{
#
-> EXP2.Session
%}


classdef Maps2DReward < dj.Computed
    properties
        
        keySource = EXP2.Session  & IMG.Mesoscope &  LICK2D.ROILick2DRewardStats &  LICK2D.ROILick2Dangle;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\brain_maps\lick2D\reward_meso\'];
            flag_spikes = 0; % 1 spikes, 0 dff
            
            flag_reward = [0,1]; % 0 regular versus; large 1  regular versus small;  2 small versus large
            
            for i_f = 1:1:numel(flag_reward)
                PLOTS_Maps2DReward(key, dir_current_fig, flag_spikes, flag_reward(i_f));
            end
            insert(self,key);
            
        end
    end
end