function PLOTS_Multiple_Cells2DTuning (key, dir_current_fig, flag_spikes, rel_rois, cells_in_row, cells_in_column)
close all;
max_num_bins_to_legalize =1; % max number of missing bins to legalize (complete) by averaging the surrounding bins
max_num_bins_to_legalize_od_even =2; % max number of missing bins to legalize (complete) by averaging the surrounding bins

if flag_spikes==0 % if based on dff
else  % if based on spikes
    rel_map_and_psth = LICK2D.ROILick2DmapSpikes *LICK2D.ROILick2DmapPSTHSpikes*LICK2D.ROILick2DmapPSTHStabilitySpikes *LICK2D.ROILick2DmapStatsSpikes * LICK2D.ROILick2DPSTHSpikes  & rel_rois;
    rel_stats = LICK2D.ROILick2DPSTHStatsSpikes *LICK2D.ROILick2DmapStatsSpikes & rel_rois;
end

session_date = fetch1(EXP2.Session & key,'session_date');
filename_prefix = [ 'anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date];

roi_number=fetchn(rel_rois  & key,'roi_number','ORDER BY roi_number');
roi_uid=fetchn(rel_rois  & key,'roi_number_uid','ORDER BY roi_number');

if isempty(roi_number)
    return
end

% number_of_bins =fetch1(rel_map_and_psth & key,'number_of_bins','LIMIT 1');
% pos_x_bins_centers =fetch1(rel_map_and_psth  & key,'pos_x_bins_centers','LIMIT 1');

%% Cells maps on grid
horizontal_dist1=(1/(cells_in_column))*0.3;
vertical_dist1=(1/(cells_in_row))*0.3;
panel_width1=(1/(cells_in_row))*0.25;
panel_height1=(1/(cells_in_column))*0.25;

position_x1_grid(1)=0.1;
for i=1:1:cells_in_column
    position_x1_grid(end+1)=position_x1_grid(end)+horizontal_dist1;
end

position_y1_grid(1)=0.8;
for i=1:1:cells_in_row
    position_y1_grid(end+1)=position_y1_grid(end)-vertical_dist1;
end

%% other plots
horizontal_dist2=0.15;
vertical_dist2=0.15;
panel_width2=0.1;
panel_height2=0.1;
position_x2(1)=0.5;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;

position_y2(1)=0.7;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;
position_y2(end+1)=position_y2(end)-vertical_dist2;



%Graphics
%---------------------------------
% figure;
figure("Visible",false);
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 23]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

M.lickmap_fr_regular=[fetchn(rel_map_and_psth,'lickmap_fr_regular','ORDER BY roi_number')];
M.lickmap_fr_regular_odd=[fetchn(rel_map_and_psth,'lickmap_fr_regular_odd','ORDER BY roi_number')];
M.lickmap_fr_regular_even=[fetchn(rel_map_and_psth,'lickmap_fr_regular_even','ORDER BY roi_number')];
M.lickmap_regular_odd_vs_even_corr=[fetchn(rel_map_and_psth,'lickmap_regular_odd_vs_even_corr','ORDER BY roi_number')];
M.information_per_spike_regular=fetchn(rel_map_and_psth,'information_per_spike_regular','ORDER BY roi_number');
M.psth_regular_odd_vs_even_corr=[fetchn(rel_stats,'psth_regular_odd_vs_even_corr','ORDER BY roi_number')];
M.psth_position_concat_regular_odd_even_corr=[fetchn(rel_stats,'psth_position_concat_regular_odd_even_corr','ORDER BY roi_number')];
M.psth_position_concat_regular_odd_even_corr=[fetchn(rel_stats,'psth_position_concat_regular_odd_even_corr','ORDER BY roi_number')];
M.field_size_regular=[fetchn(rel_map_and_psth,'field_size_regular','ORDER BY roi_number')];
M.field_size_without_baseline_regular=[fetchn(rel_map_and_psth,'field_size_without_baseline_regular','ORDER BY roi_number')];
number_of_response_trials=[fetch1(rel_map_and_psth,'number_of_response_trials','LIMIT 1')];

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
        axes('position',[position_x1_grid(i_x), position_y1_grid(i_y), panel_width1, panel_height1]);
        mmm=M.lickmap_fr_regular{i_roi};
        mmm=mmm./nanmax(mmm(:));
        mmm = fn_map_2D_legalize_by_neighboring(mmm, max_num_bins_to_legalize);
        imagescnan(mmm);
        max_map=max(mmm(:));
        caxis([0 max_map]); % Scale the lowest value (deep blue) to 0
        colormap(inferno)
        axis xy
        axis tight
        set(gca,'YDir','normal');
        set(gca, 'FontSize',10);
        axis off
        if i_roi==1
            title(sprintf('anm%d s%d\n%s\n %d tuned cells\n %d response trials\n\nAll trials\n',key.subject_id,key.session, session_date, total_roi, number_of_response_trials), 'FontSize',10);
        end
        
        % Map odd
        axes('position',[position_x1_grid(i_x), position_y1_grid(i_y)-0.4, panel_width1, panel_height1]);
        mmm=M.lickmap_fr_regular_odd{i_roi};
        mmm=mmm./nanmax(mmm(:));
        mmm = fn_map_2D_legalize_by_neighboring(mmm, max_num_bins_to_legalize_od_even);
        imagescnan(mmm);
        max_map=max(mmm(:));
        caxis([0 max_map]); % Scale the lowest value (deep blue) to 0
        colormap(inferno)
        axis xy
        axis tight
        set(gca,'YDir','normal');
        set(gca, 'FontSize',10);
        axis off
        if i_roi==1
            title(sprintf(' Odd trials\n'))
        end
        
        % Map even
        axes('position',[position_x1_grid(i_x)+0.5, position_y1_grid(i_y)-0.4, panel_width1, panel_height1]);
        mmm=M.lickmap_fr_regular_even{i_roi};
        mmm=mmm./nanmax(mmm(:));
        mmm = fn_map_2D_legalize_by_neighboring(mmm, max_num_bins_to_legalize_od_even);
        imagescnan(mmm);
        max_map=max(mmm(:));
        caxis([0 max_map]); % Scale the lowest value (deep blue) to 0
        colormap(inferno)
        axis xy
        axis tight
        set(gca,'YDir','normal');
        set(gca, 'FontSize',10);
        axis off
        if i_roi==1
            title(sprintf(' Even trials\n'))
        end
    end
end


% Spatial Information histogram
axes('position',[position_x2(1),position_y2(1), panel_width2, panel_height2])
hold on;
histogram (M.information_per_spike_regular,'FaceColor',[0 0 0])
xlabel(sprintf('Spatial information\n(bits/spike)'));
ylabel(sprintf('Counts'));

% 2D map stability
axes('position',[position_x2(2),position_y2(1), panel_width2, panel_height2])
hold on;
histogram (M.lickmap_regular_odd_vs_even_corr,'FaceColor',[0 0 0])
xlabel(sprintf('2D tuning stability'));
ylabel(sprintf('Counts'));

% 2D Field size
axes('position',[position_x2(3),position_y2(1), panel_width2, panel_height2])
hold on;
histogram (M.field_size_regular,7,'FaceColor',[0 0 0])
xlabel(sprintf('Field size (%%)'));
ylabel(sprintf('Counts'));

if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
filename=[filename_prefix 'multiple_cells'];
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r300']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);


clf


