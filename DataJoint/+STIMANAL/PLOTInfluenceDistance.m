%{
# Photostim Group
-> EXP2.SessionEpoch
num_svd_components_removed                  : int     # how many of the first svd components were removed
%}


classdef PLOTInfluenceDistance < dj.Imported
    properties
        keySource = EXP2.SessionEpoch & STIMANAL.InfluenceDistance ;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
            
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Photostim\photostim_distance\'];
            clf;
            
            % figure
            set(gcf,'DefaultAxesFontName','helvetica');
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 15 10]);
            set(gcf,'PaperOrientation','portrait');
            set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
            set(gcf,'color',[1 1 1]);
            
            horizontal_dist=0.35;
            vertical_dist=0.35;
            
            panel_width1=0.2;
            panel_height1=0.25;
            position_x1(1)=0.2;
            position_x1(end+1)=position_x1(end)+horizontal_dist;
            
            position_y1(1)=0.5;
            position_y1(end+1)=position_y1(end)-vertical_dist;
            
            rel_data = (STIMANAL.InfluenceDistance & 'flag_divide_by_std=0' & 'flag_withold_trials=1' & 'flag_normalize_by_total=1') ...
                &  (STIMANAL.SessionEpochsIncluded& IMG.PlaneCoordinates & 'stimpower=150' & 'flag_include=1' ...
                & (STIMANAL.NeuronOrControl & 'neurons_or_control=1' & 'num_targets>0') ...
                & (STIMANAL.NeuronOrControl & 'neurons_or_control=0' & 'num_targets>0')) & key;
            
            key.is_volumetric =1; % 1 volumetric, 1 single plane
            distance_axial_bins=[0,60,90,120];
            distance_axial_bins_plot=[0,30,60,90,120];
            % key.session_epoch_number=2;
            flag_response=0; %0 all, 1 excitation, 2 inhibition, 3 absolute
            key.num_svd_components_removed=0;
            response_p_val=1;
            
            
            key.neurons_or_control =1; % 1 neurons, 0 control sites
            rel_neurons = rel_data & key & sprintf('response_p_val=%.3f',response_p_val);
            rel_sessions_neurons= EXP2.SessionEpoch & rel_neurons; % only includes sessions with responsive neurons
            
            
            
            %% 2D plots - Neurons
            ax1=axes('position',[position_x1(1), position_y1(1), panel_width1, panel_height1]);
            D1=fetch(rel_neurons,'*');  % response p-value for inclusion. 1 means we take all pairs
            OUT1=fn_PLOT_CoupledResponseDistance_averaging(D1,distance_axial_bins,flag_response);
            
            xl=[OUT1.distance_lateral_bins_centers(1),OUT1.distance_lateral_bins_centers(end)];
            imagesc(OUT1.distance_lateral_bins_centers, distance_axial_bins_plot,  OUT1.map)
            axis tight
            axis equal
            cmp = bluewhitered(2048); %
            colormap(ax1, cmp)
            % set(gca,'XTick',OUT1.distance_lateral_bins_centers)
            xlabel([sprintf('Lateral Distance ') '(\mum)']);
            % ylabel([sprintf('Axial Distance ') '(\mum)']);
            % colorbar
            % set(gca,'YTick',[],'XTick',[20,100:100:500]);
            set(gca,'YTick',[],'XTick',[25,100:100:500]);
            
            %% 2D plots - Control sites
            key.neurons_or_control =0; % 1 neurons, 0 control sites
            rel_control = rel_data & rel_sessions_neurons & key & sprintf('response_p_val=%.3f',response_p_val);
            
            ax2=axes('position',[position_x1(1), position_y1(2), panel_width1, panel_height1]);
            D2=fetch(rel_control ,'*');  % response p-value for inclusion. 1 means we take all pairs
            OUT2=fn_PLOT_CoupledResponseDistance_averaging(D2,distance_axial_bins,flag_response);
            imagesc(OUT2.distance_lateral_bins_centers,  distance_axial_bins_plot, OUT2.map)
            axis tight
            axis equal
            colormap(ax2,cmp)
            % colorbar
            caxis([OUT1.minv OUT1.maxv]);
            xlabel([sprintf('Lateral Distance ') '(\mum)']);
            ylabel([sprintf('Axial Distance ') '(\mum)']);
            set(gca,'YTick',[],'XTick',[25,100:100:500]);
            
            %% Marginal distribution - lateral
            axes('position',[position_x1(1), position_y1(1)+0.17, panel_width1, panel_height1*0.5]);
            hold on
            plot(xl, [0 0],'-k')
            plot(OUT1.distance_lateral_bins_centers,OUT1.marginal_lateral_mean,'-','Color',[1 0 0]);
            plot(OUT2.distance_lateral_bins_centers,OUT2.marginal_lateral_mean,'-','Color',[0.5 0.5 0.5]);
            yl(1)=-2*abs(min([OUT1.marginal_lateral_mean,OUT2.marginal_lateral_mean]));
            yl(2)=abs(max([OUT1.marginal_lateral_mean,OUT2.marginal_lateral_mean]));
            ylim(yl)
            set(gca,'XTick',[],'XLim',xl);
            box off
            ylabel([sprintf('Response\n') '(z-score)']);
            set(gca,'YTick',[0,0.1]);
            
            % Marginal distribution - lateral (zoom)
            axes('position',[position_x1(1)+0.06, position_y1(1)+0.22, panel_width1*0.7, panel_height1*0.4]);
            hold on
            plot(xl, [0 0],'-k')
            plot(OUT1.distance_lateral_bins_centers,OUT1.marginal_lateral_mean,'-','Color',[1 0 0]);
            plot(OUT2.distance_lateral_bins_centers,OUT2.marginal_lateral_mean,'-','Color',[0.5 0.5 0.5]);
            yl(1)=1.5*min([OUT1.marginal_lateral_mean,OUT2.marginal_lateral_mean]);
            yl(2)=2*abs(min([OUT1.marginal_lateral_mean,OUT2.marginal_lateral_mean]));
            ylim(yl)
            set(gca,'XLim',xl);
            box off
            set(gca,'YTick',[-0.002 0 0.002]);
            
            %% Marginal distribution - axial
            axm=axes('position',[position_x1(1)-0.1, position_y1(1)+0.09, panel_width1*0.4, panel_height1*0.27]);
            hold on
            plot([distance_axial_bins(1),distance_axial_bins(end)],[0 0],'-k')
            plot(distance_axial_bins,OUT1.marginal_axial_in_column_mean,'-','Color',[1 0 0]);
            plot(distance_axial_bins,OUT2.marginal_axial_in_column_mean,'-','Color',[0.5 0.5 0.5]);
            axm.View = [90 90]
            xlabel([sprintf('Axial Distance ') '(\mum)']);
            ylabel([sprintf('Response\n') '(z-score)']);
            set(gca,'XTick',[distance_axial_bins]);
            
            %% Marginal distribution - axial
            axm=axes('position',[position_x1(1)+0.5, position_y1(1)+0.09, panel_width1*0.4, panel_height1*0.27]);
            hold on
            plot([distance_axial_bins(1),distance_axial_bins(end)],[0 0],'-k')
            plot(distance_axial_bins,OUT1.marginal_axial_out_column_mean,'-','Color',[1 0 0]);
            plot(distance_axial_bins,OUT2.marginal_axial_out_column_mean,'-','Color',[0.5 0.5 0.5]);
            axm.View = [90 90]
            xlabel([sprintf('Axial Distance ') '(\mum)']);
            ylabel([sprintf('Response\n') '(z-score)']);
            set(gca,'XTick',[distance_axial_bins]);
            
        end
    end
end
