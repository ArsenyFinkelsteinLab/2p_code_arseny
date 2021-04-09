function [xlimits, ylimits] = plot2D_field (field_density_mat_X_Y, X_bins_vector, X_bins_vector_of_centers,Y_bins_vector, Y_bins_vector_of_centers)

xlimits=[X_bins_vector(1) X_bins_vector(end)];
ylimits=[Y_bins_vector(1) Y_bins_vector(end)];

hhh=imagesc(X_bins_vector_of_centers, Y_bins_vector_of_centers,field_density_mat_X_Y);
colormap_map=jet;
colormap_map(64,:) = [1 1 1] ; % Set the highest-value pixel to White = [1 1 1] : I will use White as the Color of NaN pixels
cdata_mat = field_density_mat_X_Y / max(field_density_mat_X_Y(:)) * ...
    ( size(colormap_map,1) - 1 ) ; % Scale the colors in 'cdata' to ( 1 : length(colormap) - 1 ), so that the highest value will be reserved to NaN's
idx_isNaN_Field_X_Y = find( isnan( field_density_mat_X_Y  ) ); % Find the indexes of NaN bins
cdata_mat( idx_isNaN_Field_X_Y ) = size(colormap_map,1) ; % Replace NaN values with the highest values (they will be colored white)
colormap( colormap_map );
caxis([0 65]); % Scale the lowest value (deep blue) to 0
set(hhh, 'cdatamapping', 'direct', 'cdata', cdata_mat );
set(gca,'xlim',xlimits,'ylim',ylimits, 'FontSize', 8);
hold on;