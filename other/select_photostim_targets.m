function [group_targets] = select_photostim_targets()
    hold on

n_target=10;
n_group=2;


key.trial_epoch_name = 'all';
key.session =8;


label='R-L selectivity';
map=fetch1(IMG.FOVMapSelectivity & key, 'map_selectivity_f');
map=smooth2a(map,1,1);
map=map*(-1);
colorbar_label = 'Selectivity (R-L), Fluorescence';
[cmp] = fn_plot_map4 (map, label, key, colorbar_label);
colormap(cmp);

ROI=fetch(IMG.ROI & key,'*');
for i_roi=1:1:numel(ROI)
%     x_pix = double(ROI(i_roi).roi_x_pix);
%     y_pix = double(ROI(i_roi).roi_y_pix);
%     b = boundary(x_pix', y_pix');
%     plot(x_pix(b),y_pix(b),'-k');
    x_centroid (i_roi) = ROI(i_roi).roi_centroid_x_y(2);
    y_centroid (i_roi)  = ROI(i_roi).roi_centroid_x_y(1);
    
end

% group_targets = fn_select_photostim_targets (n_target, n_group);
color_g = {[0 0 1], [1 0 0]};
for i_g = 1:1: n_group
    for i_t = 1:1:n_target
        [x_targ,y_targ] = ginput(1);
        group_targets{i_g}.x(i_t) = x_targ;
        group_targets{i_g}.y(i_t) = y_targ;
        
        dx = x_centroid- x_targ;
        dy = y_centroid- y_targ;

        [~ , idx] = min(sqrt(dx.^2 + dy.^2));
         x_pix = double(ROI(idx).roi_x_pix);
    y_pix = double(ROI(idx).roi_y_pix);
    b = boundary(x_pix', y_pix');
    plot(x_pix(b),y_pix(b),'-', 'Color', color_g{i_g});

%         plot (x_centroid(idx),y_centroid(idx),'*r')
    end
    
end
