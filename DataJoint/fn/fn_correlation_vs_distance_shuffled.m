function [axial_distance_bins, distance_corr_2d, distance_corr_lateral, distance_corr_axial_columns] ...
    = fn_correlation_vs_distance_shuffled (x_all,y_all,z_all, rho, lateral_distance_bins, min_distance_in_xy, column_inner_radius, column_outer_radius)

%% Distance between all pairs, shuffled
x_all = x_all(randperm(numel(x_all)));
y_all = y_all(randperm(numel(y_all)));
z_all = z_all(randperm(numel(z_all)));

dXY=zeros(numel(x_all),numel(x_all));
% d3D=zeros(numel(x_all),numel(x_all));
dZ=zeros(numel(z_all),numel(z_all));
parfor iROI=1:1:numel(x_all)
    x=x_all(iROI);
    y=y_all(iROI);
    z=z_all(iROI);
    dXY(iROI,:)= sqrt((x_all-x).^2 + (y_all-y).^2); % in um
    dZ(iROI,:)= abs(z_all-z); % in um
    % d3D(iROI,:) = sqrt((x_all-x).^2 + (y_all-y).^2 + (z_all-z).^2); % in um
end

idx_lower_triangle=logical(tril(dXY));
dZ = dZ(idx_lower_triangle);
dXY = dXY(idx_lower_triangle);

axial_distance_bins = unique(dZ)';

 
%% Computing correlations versus distance


distance_corr_2d=zeros(numel(axial_distance_bins),numel(lateral_distance_bins)-1);
for i_l=1:1:numel(lateral_distance_bins)-1
    idx_lateral = dXY>lateral_distance_bins(i_l) & dXY<=lateral_distance_bins(i_l+1) & dXY>=min_distance_in_xy;
    dz_temp=dZ(idx_lateral);
    rho_lateral=rho(idx_lateral);
    distance_corr_lateral(i_l)=nanmean(rho_lateral);
    parfor i_a=1:1:numel(axial_distance_bins)
        idx_axial =  dz_temp==axial_distance_bins(i_a);
        distance_corr_2d(i_a,i_l)=nanmean(rho_lateral(idx_axial));
    end
end


% axial within column
for i_c=1:1:numel(column_inner_radius)
    for i_a=1:1:numel(axial_distance_bins)
        idx_lateral = dXY>=column_inner_radius(i_c) & dXY<column_outer_radius(i_c);
        idx_axial =  dZ==axial_distance_bins(i_a);
        distance_corr_axial_columns(i_a, i_c)=nanmean(rho(idx_axial & idx_lateral));
    end
end
