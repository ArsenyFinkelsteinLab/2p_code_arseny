function [information_per_spike_XY, field_size, field_size_without_baseline, centroid, centroid_without_baseline, percent_coverage,  preferred_bin] ...
    = fn_compute_generic_2D_field_stats (map_XY_FR, min_percent_coverage)

% to avoid negative "firing rates" -- which can be if instead of spikes we use df/f imaging traces
if nanmin(map_XY_FR(:))<0
    map_XY_FR = map_XY_FR - nanmin(map_XY_FR(:));
end


%% Compute the following Stats if there is enough 2D coverage
percent_coverage=100*(1-sum(isnan(map_XY_FR(:)))/numel(map_XY_FR(:)));
if percent_coverage>=min_percent_coverage % minimal coverage needed for calculation
    
    %% Preferred bin
    [~,preferred_bin]=nanmax(map_XY_FR(:));

    
    %% Spatial Information
    %==========================================================================
    % On unsmoothed field:
    [information_per_spike_XY] = fn_compute_spatial_info (ones(size(map_XY_FR))+map_XY_FR*0, map_XY_FR);
    
    
    %% Field Size (at half max)
    M = map_XY_FR;
    max_m=nanmax(M (:));
    field_size=100*sum(M (:)>max_m*0.5)/size(M (:),1);
    
    % Centroid
    props = regionprops(true(size(M )), M , 'WeightedCentroid');
    centroid(1)=props.WeightedCentroid(1);
    centroid(2)=props.WeightedCentroid(2);
    
    %% Field Size without baseline (at half max, after baseline subtraction)
    M_without_baseline =map_XY_FR-nanmin(map_XY_FR(:));
    max_m=nanmax(M_without_baseline (:));
    field_size_without_baseline =100*sum(M_without_baseline (:)>max_m*0.5)/size(M_without_baseline (:),1);
    
    % Centroid without baseline (after baseline subtraction, and then after zeroing everything that  is below half max)
    M_without_baseline(isnan(M_without_baseline ))=0;
    M_without_baseline (M_without_baseline <max_m*0.5)=0;
    props = regionprops(true(size(M_without_baseline )), M_without_baseline , 'WeightedCentroid');
    centroid_without_baseline(1)=props.WeightedCentroid(1);
    centroid_without_baseline(2)=props.WeightedCentroid(2);
else
    information_per_spike_XY=NaN;
    field_size=NaN;
    field_size_without_baseline=NaN;
    centroid(1)=NaN;
    centroid(2)=NaN;
    centroid_without_baseline(1)=NaN;
    centroid_without_baseline(2)=NaN;
    preferred_bin = NaN;
end
