%{
#
-> EXP2.Session
%}


classdef Population2DReward < dj.Computed
    properties
        
        keySource = (EXP2.Session   &  LICK2D.ROILick2DRewardStatsSpikes &  LICK2D.ROILick2DangleSpikes) - IMG.Mesoscope ;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\population\reward_not_meso\'];
            flag_spikes = 1; % 1 spikes, 0 dff
            
            %             flag_reward = [0,1,2]; % 0 regular versus large 1 small versus regular  2 small versus large
            flag_reward = [0,1]; % 0 regular versus large 1 small versus regular  2 small versus large
            
            
            
            %Graphics
            %---------------------------------
            fig=gcf;
            set(gcf,'DefaultAxesFontName','helvetica');
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
            set(gcf,'PaperOrientation','portrait');
            set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
            set(gcf,'color',[1 1 1]);
            left_color=[0 0 0];
            right_color=[0 0 0];
            set(fig,'defaultAxesColorOrder',[left_color; right_color]);
            
            
            for i_f = 1:1:numel(flag_reward)
                % %                 PLOTS_Maps2DReward(key, dir_current_fig, flag_spikes, flag_reward(i_f));
                PLOTS_Population2DReward(key, dir_current_fig, flag_spikes, flag_reward(i_f));
                
            end
            insert(self,key);
            
        end
    end
end