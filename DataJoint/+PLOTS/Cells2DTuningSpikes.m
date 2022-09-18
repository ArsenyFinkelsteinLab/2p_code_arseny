%{
# 
-> EXP2.Session
%}


classdef Cells2DTuningSpikes < dj.Computed
    properties
        
      keySource = (EXP2.Session   &  LICK2D.ROILick2DmapSpikes & LICK2D.ROILick2DPSTHStatsSpikes & LICK2D.ROILick2DPSTHSpikesPoisson & LICK2D.ROILick2DPSTHSpikesResampledlikePoisson & (LICK2D.ROILick2DmapStatsSpikes & 'percent_2d_map_coverage_small>=75' & 'number_of_response_trials>=500')) -  IMG.Mesoscope ;
%       keySource = (EXP2.Session   &  LICK2D.ROILick2DPSTHSpikes) &  IMG.Mesoscope;

    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\Cells\2DTuning\not_mesoscope\'];
            
            flag_spikes = 1; % 1 spikes, 0 dff
            
            if flag_spikes==1
                rel_rois=  (IMG.ROI& IMG.ROIGood - IMG.ROIBad) & ...
                    (LICK2D.ROILick2DmapStatsSpikes & 'percent_2d_map_coverage_small>=90' & 'number_of_response_trials>=500')  & ...
                    (LICK2D.ROILick2DmapStatsSpikes & 'psth_position_concat_regular_odd_even_corr>=0.5') & key;
                %                     (LICK2D.ROILick2DPSTHStatsSpikes & 'reward_mean_pval_regular_small<=0.05 OR reward_mean_pval_regular_large<=0.05') & key;
            end
            
            plot_one_in_x_cell=2; % e.g. plots one in 20 signficant cell
            
            PLOTS_Cells2DTuning(key, dir_current_fig,flag_spikes, plot_one_in_x_cell, rel_rois);
            
            insert(self,key);
            
        end
    end
end