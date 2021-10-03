function lick2D_behaviorperform()
close all;
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value'); 


% key.subject_id = 464725;
% key.session =6;

key.subject_id = 463189;
key.session =5;

key.number_of_bins=4;

rel = EXP2.BehaviorTrial*EXP2.TrialLickBlock*EXP2.TrialLickPort & key;

B=fetch(rel, '*');
%% Rescaling, rotation, and binning
[POS] = fn_rescale_and_rotate_lickport_pos (key);
pos_x = POS.pos_x;
pos_z = POS.pos_z;

x_bins = linspace(-1, 1,key.number_of_bins+1);
x_bins_centers=x_bins(1:end-1)+mean(diff(x_bins))/2;

z_bins = linspace(-1,1,key.number_of_bins+1);
z_bins_centers=z_bins(1:end-1)+mean(diff(z_bins))/2;

x_bins(1)= -inf;
x_bins(end)= inf;
z_bins(1)= -inf;
z_bins(end)= inf;



%% Compute maps
[hhhhh, ~, ~, x_idx, z_idx] = histcounts2(pos_x,pos_z,x_bins,z_bins);

outcome ={B.outcome};


    for i_x=1:1:numel(x_bins_centers)
        for i_z=1:1:numel(z_bins_centers)
            idx = find((x_idx==i_x)  &  (z_idx==i_z));
            percent_ignore = 100*sum(contains(outcome(idx),'ignore'))./numel(idx);

            map_xz_percent_response(i_z,i_x) = 100-percent_ignore;
                                    num_response(i_z,i_x) = sum(~contains(outcome(idx),'ignore'));
                                                                        num_trials(i_z,i_x) = numel(idx);

end
end


    %% Maps
subplot(2,2,1)
imagescnan(x_bins_centers, z_bins_centers, map_xz_percent_response)
    max_map=max(map_xz_percent_response(:));
    caxis([0 max_map]); % Scale the lowest value (deep blue) to 0
    colormap(parula)
%     title(sprintf('ROI %d anm%d %s\n \n Positional (2D) tuning  \n I = %.2f bits/spike  \n  p-val = %.4f  ',roi_number(i_roi),key.subject_id, session_date, M(i_roi).information_per_spike, M(i_roi).pval_information_per_spike ), 'FontSize',10);
    axis xy
    axis equal;
    axis tight
    colorbar
    xlabel(sprintf('Lickport X-pos \n(normalized)'), 'FontSize',10);
    ylabel(sprintf('Lickport  Z-pos '), 'FontSize',10);
    set(gca,'YDir','normal');
    set(gca, 'FontSize',10);
    title('% responded');
    
    
    
    subplot(2,2,2)

    %     axes('position',[position_x2(4),position_y2(1)-0.03, panel_width2*1.5, panel_height2*1.5])
    imagescnan(x_bins_centers, z_bins_centers, num_response)
    max_map=max(num_response(:));
    caxis([0 max_map]); % Scale the lowest value (deep blue) to 0
    colormap(parula)
%     title(sprintf('ROI %d anm%d %s\n \n Positional (2D) tuning  \n I = %.2f bits/spike  \n  p-val = %.4f  ',roi_number(i_roi),key.subject_id, session_date, M(i_roi).information_per_spike, M(i_roi).pval_information_per_spike ), 'FontSize',10);
    axis xy
    axis equal;
    axis tight
    colorbar
    xlabel(sprintf('Lickport X-pos \n(normalized)'), 'FontSize',10);
    ylabel(sprintf('Lickport  Z-pos '), 'FontSize',10);
    set(gca,'YDir','normal');
    set(gca, 'FontSize',10);
    title('number of responses');
    
    
    subplot(2,2,3)

    %     axes('position',[position_x2(4),position_y2(1)-0.03, panel_width2*1.5, panel_height2*1.5])
    imagescnan(x_bins_centers, z_bins_centers, num_trials)
    max_map=max(num_trials(:));
    caxis([0 max_map]); % Scale the lowest value (deep blue) to 0
    colormap(parula)
%     title(sprintf('ROI %d anm%d %s\n \n Positional (2D) tuning  \n I = %.2f bits/spike  \n  p-val = %.4f  ',roi_number(i_roi),key.subject_id, session_date, M(i_roi).information_per_spike, M(i_roi).pval_information_per_spike ), 'FontSize',10);
    axis xy
    axis equal;
    axis tight
    colorbar
    xlabel(sprintf('Lickport X-pos \n(normalized)'), 'FontSize',10);
    ylabel(sprintf('Lickport  Z-pos '), 'FontSize',10);
    set(gca,'YDir','normal');
    set(gca, 'FontSize',10);
    title('number of trials');

