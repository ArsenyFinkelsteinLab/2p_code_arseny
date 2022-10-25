%{
# 
-> EXP2.Session
%}


classdef MultipleCells2DTuningSpikes < dj.Computed
    properties
      keySource = (EXP2.Session  &  LICK2D.ROILick2DmapSpikes  & (LICK2D.ROILick2DmapStatsSpikes & 'percent_2d_map_coverage_small>=75' & 'number_of_response_trials>=500')) -  IMG.Mesoscope ;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\Cells\Cells_Multiple\not_mesoscope\stable\'];
            
            flag_spikes = 1; % 1 spikes, 0 dff
            
            if flag_spikes==1
                rel_rois=  (IMG.ROI& IMG.ROIGood - IMG.ROIBad) & ...
                    (LICK2D.ROILick2DmapStatsSpikes & 'percent_2d_map_coverage_regular>=90' & 'number_of_response_trials>=250')  & ...
                    (LICK2D.ROILick2DmapStatsSpikes & 'psth_position_concat_regular_odd_even_corr>=0.5') & key;
                %                     (LICK2D.ROILick2DPSTHStatsSpikes & 'reward_mean_pval_regular_small<=0.05 OR reward_mean_pval_regular_large<=0.05') & key;
            end
            
            cells_in_row = 10;
            cells_in_column = 10;
            PLOTS_Multiple_Cells2DTuning (key, dir_current_fig,flag_spikes, rel_rois, cells_in_row, cells_in_column);
            
            insert(self,key);
            
        end
    end
end