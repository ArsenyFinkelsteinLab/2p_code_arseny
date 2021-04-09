%{
# 
-> EXP2.Session
%}


classdef Maps2DBlock < dj.Computed
    properties
        
        keySource = EXP2.Session  & IMG.Mesoscope &  LICK2D.ROILick2DBlockStats &  LICK2D.ROILick2Dangle;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\brain_maps\lick2D\block_meso\'];
            flag_spikes = 0; % 1 spikes, 0 dff
            
            flag_block = [0,1,2]; % 0 first versus begin 1 first versus end  2 begin versus end

            for i_f = 1:1:numel(flag_block)
            PLOTS_Maps2DBlock(key, dir_current_fig, flag_spikes, flag_block(i_f));
            end
            insert(self,key);
            
        end
    end
end