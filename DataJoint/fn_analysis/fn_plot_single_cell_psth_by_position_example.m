function [psth_time] = fn_plot_single_cell_psth_by_position_example (rel_example, roi_number_uid, xlabel_flag, ylabel_flag, position_x1_grid, position_y1_grid)
key_roi.roi_number_uid =roi_number_uid;
P =fetch(rel_example & key_roi,'*');
psth_time = P.psth_time;
number_of_bins =P.number_of_bins;
pos_x_bins_centers =P.pos_x_bins_centers;
pos_z_bins_centers =P.pos_z_bins_centers';


P.psth_per_position_regular = fn_map_2D_legalize_by_neighboring_psth(P.psth_per_position_regular);


panel_width_map=0.025;
panel_height_map=0.025;


horizontal_dist1=(1/(number_of_bins+2))*0.1;
vertical_dist1=(1/(number_of_bins+2))*0.1;
panel_width1=(1/(number_of_bins+6))*0.15;
panel_height1=(1/(number_of_bins+6))*0.125;
for i=1:1:number_of_bins-1
    position_x1_grid(end+1)=position_x1_grid(end)+horizontal_dist1;
    position_y1_grid(end+1)=position_y1_grid(end)+vertical_dist1;
end


xl = [floor(psth_time(1)) ceil(psth_time(end))];

%% 1 PSTH per position, for regular reward
psth_max_regular= cell2mat(reshape(P.psth_per_position_regular,[number_of_bins^2,1])) + cell2mat(reshape(P.psth_per_position_regular_stem,[number_of_bins^2,1]));
try
    odd=cell2mat(reshape(P.psth_per_position_regular_odd,[number_of_bins^2,1]));
    even=cell2mat(reshape(P.psth_per_position_regular_even,[number_of_bins^2,1]));
    psth_max_all=max([psth_max_regular(:);odd(:);even(:)]);
catch
    psth_max_all=max([psth_max_regular(:)]);
end

current_plot=0;
for  i_x=1:1:number_of_bins
    for  i_z=1:1:number_of_bins
        current_plot=current_plot+1;
        axes('position',[position_x1_grid(i_x), position_y1_grid(i_z), panel_width1, panel_height1]);
        hold on;
        plot([0,0],[0,1],'-k','linewidth',0.25)
        temp_mean=P.psth_per_position_regular{i_z,i_x}./psth_max_all;
        temp_stem=P.psth_per_position_regular_stem{i_z,i_x}./psth_max_all;
%         try
%             plot(psth_time,P.psth_per_position_regular_odd{i_z,i_x}./psth_max_all,'-','Color',[0.4 0.4 0.4],'linewidth',0.5);
%             plot(psth_time,P.psth_per_position_regular_even{i_z,i_x}./psth_max_all,'-','Color',[0.1 0.1 0.1],'linewidth',0.5);
%         end
        shadedErrorBar(psth_time,temp_mean, temp_stem,'lineprops',{'-','Color',[ 0 0 0.8],'linewidth',0.75});
        ylims=[0,1+eps];
        ylim(ylims);
        xlim(xl);
        if current_plot ==1
            text(-2,-1,'Time to lick (s)','HorizontalAlignment','left', 'FontSize',6);
            text(-8,0,'Acitivity (norm.)','HorizontalAlignment','left','Rotation',90, 'FontSize',6);
            set(gca,'XTick',[0,xl(2)],'Ytick',ylims, 'FontSize',6,'TickLength',[0.1,0],'TickDir','out');
        else
            set(gca,'XTick',[0,xl(2)],'XtickLabel',[],'Ytick',ylims,'YtickLabel',[], 'FontSize',6,'TickLength',[0.1,0],'TickDir','out');
            axis off
        end
    end
end


%% Map regular reward stability

ax6=axes('position',[position_x1_grid(1)+0.08,position_y1_grid(1)+0.03, panel_width_map, panel_height_map]);
mmm=P.lickmap_fr_regular_odd;
mmm=mmm./nanmax(mmm(:));
imagescnan(mmm);
max_map=max(mmm(:));
caxis([0 max_map]); % Scale the lowest value (deep blue) to 0
colormap(ax6,inferno)
%     title(sprintf('Stability r = %.2f \n Odd trials\n', P.lickmap_regular_odd_vs_even_corr), 'FontSize',6);
title(sprintf('Stability: \n Odd trials'), 'FontSize',6);
axis equal;
axis tight
set(gca,'YDir','normal');
%     colorbar
axis off

ax6=axes('position',[position_x1_grid(1)+0.08,position_y1_grid(1), panel_width_map, panel_height_map]);
mmm=P.lickmap_fr_regular_even;
mmm=mmm./nanmax(mmm(:));
imagescnan(mmm);
max_map=max(mmm(:));
caxis([0 max_map]); % Scale the lowest value (deep blue) to 0
colormap(ax6,inferno)
title(sprintf('\nEven trials'), 'FontSize',6);
axis equal;
axis tight;
set(gca,'YDir','normal');
%     colorbar
axis off
