function map_2d = fn_map_2D_legalize_by_neighboring  (map_2d, max_num_bins_to_legalize)
if sum(isnan(map_2d(:)))==0 ||  sum(isnan(map_2d(:)))>max_num_bins_to_legalize %skip this function if there are no missing mips, or if there are too many missing bins
    return
end

X_num_bins = size(map_2d,1);
Y_num_bins = size(map_2d,2);
map_2d_legalized=zeros(Y_num_bins+2, X_num_bins+2 ) + NaN; %to deal with edge related problems
map_2d_legalized(2:end-1,2:end-1)=map_2d;

for ii_X_bin = 2 : X_num_bins+1  % Loop over X-bins
    for ii_Y_bin = 2 : Y_num_bins+1  % Loop over Y-bins
        if isnan(map_2d_legalized(ii_Y_bin,ii_X_bin))==1
            matrix_3x3_of_neighbors = ...
                map_2d_legalized( ii_Y_bin-1 : ii_Y_bin+1, ii_X_bin-1 : ii_X_bin+1 ) ;
            sum_including_the_central_bin = nansum(matrix_3x3_of_neighbors(:)); % Count the matrix_3x3_of_neighbors + the central bin itself
            if ( sum_including_the_central_bin  > 0 ) % If the animal visited any of this bin's 8 neighbors (3x3 region)
                map_2d_legalized(ii_Y_bin,ii_X_bin) = nanmean(matrix_3x3_of_neighbors(:));
            end
        end
    end
end
map_2d=map_2d_legalized(2:end-1,2:end-1);