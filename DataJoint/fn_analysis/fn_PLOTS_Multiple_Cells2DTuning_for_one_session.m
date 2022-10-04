function fn_PLOTS_Multiple_Cells2DTuning_for_one_session (key, rel_map_single_session, rel_roi, cells_in_row, cells_in_column,  position_x_grid, position_y_grid)

rel_map_single_session =rel_map_single_session & key;
rel_roi =rel_roi  & key;

max_num_bins_to_legalize =1; % max number of missing bins to legalize (complete) by averaging the surrounding bins
roi_number=fetchn(rel_roi,'roi_number','ORDER BY roi_number');

if isempty(roi_number)
    return
end

%% Cells maps on grid
horizontal_dist1=(1/(cells_in_column))*0.2;
vertical_dist1=(1/(cells_in_row))*0.15;
panel_width1=(1/(cells_in_row))*0.15;
panel_height1=(1/(cells_in_column))*0.15;

for i=1:1:cells_in_column
    position_x_grid(end+1)=position_x_grid(end)+horizontal_dist1;
end

for i=1:1:cells_in_row
    position_y_grid(end+1)=position_y_grid(end)-vertical_dist1;
end


M.roi_number=[fetchn(rel_map_single_session*rel_roi,'roi_number','ORDER BY roi_number')];
M.lickmap_fr_regular=[fetchn(rel_map_single_session*rel_roi,'lickmap_fr_regular','ORDER BY roi_number')];
M.lickmap_regular_odd_vs_even_corr=[fetchn(rel_map_single_session*rel_roi,'lickmap_regular_odd_vs_even_corr','ORDER BY roi_number')];
M.information_per_spike_regular=fetchn(rel_map_single_session*rel_roi,'information_per_spike_regular','ORDER BY roi_number');
M.roi_number_uid=fetchn(rel_map_single_session*rel_roi,'roi_number_uid','ORDER BY roi_number');

M = struct2table(M);
[~, idx_sort] = sort(M.information_per_spike_regular,'descend');
M = M(idx_sort,:);



total_roi = size(M,1);

i_roi=0;

for i_y=1:1:cells_in_column
    for  i_x=1:1:cells_in_row
        i_roi = i_roi +1;
        if i_roi>total_roi
            return
        end
        
        % Map
        ax6=axes('position',[position_x_grid(i_x), position_y_grid(i_y), panel_width1, panel_height1]);
        mmm=M.lickmap_fr_regular{i_roi};
        mmm=mmm./nanmax(mmm(:));
        mmm = fn_map_2D_legalize_by_neighboring(mmm, max_num_bins_to_legalize);
        imagescnan(mmm);
        max_map=max(mmm(:));
        caxis([0 max_map]); % Scale the lowest value (deep blue) to 0
        colormap(ax6,inferno)
        axis equal
        axis tight
        set(gca,'YDir','normal');
        set(gca, 'FontSize',6);
        axis off
        if i_roi==7
            title(sprintf('Example session, Positional tuning of 100 neurons'), 'FontSize',6);
        end
        
       
    end
end


