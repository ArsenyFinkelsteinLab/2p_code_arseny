%{
# 
-> EXP2.Session
%}


classdef CellsRewardTuningSpikes < dj.Computed
    properties
        
      keySource = (EXP2.Session   &  LICK2D.ROILick2DPSTHSpikes & LICK2D.ROILick2DRewardStatsSpikes) -  IMG.Mesoscope ;
%       keySource = (EXP2.Session   &  LICK2D.ROILick2DPSTHSpikes) &  IMG.Mesoscope;

    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\Cells\RewardTuning_spikes\not_mesoscope\'];
            
            flag_spikes = 1; % 1 spikes, 0 dff
            
            plot_one_in_x_cell=10; % e.g. plots one in 20 signficant cell
            
            PLOTS_CellsReward(key, dir_current_fig,flag_spikes, plot_one_in_x_cell);
            
            insert(self,key);
            
        end
    end
end