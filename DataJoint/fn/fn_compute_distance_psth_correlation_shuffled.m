function fn_compute_distance_psth_correlation_shuffled(rel_roi, rel_data, key,self, dir_save_fig, rel_roi_xy,mesoscope_flag)

num_shuffles=10;
min_distance_in_xy=10; %to exclude auto-focus flourescence
column_inner_radius =[10 10 10 10 10 10 10 10  10  10  10  10  25 25 25  30 30 30 30  30  40  40 40  50  50  60  60  60  60  100 120 120]; % microns
column_outer_radius =[25 30 40 50 60 75 90 100 120 150 200 250 50 40 100 50 60 75 100 120 60  70 100 100 250 250 100 250 120 250 250 500]; % microns

lateral_distance_bins=[0,10,20,30:10:500];
% lateral_distance_bins=[5,15,25:10:255];


%% Real distance between cells
if mesoscope_flag>0 %its mesoscpe recordings
    x_all=fetchn(rel_roi &key,'roi_centroid_x','ORDER BY roi_number');
    y_all=fetchn(rel_roi &key,'roi_centroid_y','ORDER BY roi_number');
    
    x_pos_relative=fetchn(rel_roi*IMG.PlaneCoordinates &key,'x_pos_relative','ORDER BY roi_number');
    y_pos_relative=fetchn(rel_roi*IMG.PlaneCoordinates &key,'y_pos_relative','ORDER BY roi_number');
    
    x_all = x_all + x_pos_relative; x_all = x_all/0.75;
    y_all = y_all + y_pos_relative; y_all = y_all/0.5;
    
else
    zoom =fetch1(IMG.FOVEpoch & key,'zoom');
    kkk.scanimage_zoom = zoom;
    pix2dist=  fetch1(IMG.Zoom2Microns & kkk,'fov_microns_size_x') / fetch1(IMG.FOV & key, 'fov_x_size');
    
    x_all=fetchn(rel_roi_xy &key,'roi_centroid_x_corrected','ORDER BY roi_number');
    y_all=fetchn(rel_roi_xy &key,'roi_centroid_y_corrected','ORDER BY roi_number');
    
    x_all=x_all*pix2dist;
    y_all=y_all*pix2dist;
    
end

z_all=fetchn(rel_roi*IMG.PlaneCoordinates & key,'z_pos_relative','ORDER BY roi_number');



%% Loading Data
roi_list=fetchn(rel_roi,'roi_number','ORDER BY roi_number');
if numel(roi_list)<10
    return
end

chunk_size=500;
counter=0;
if isempty(roi_list)
    return
end
for i_chunk=1:chunk_size:roi_list(end)
    roi_interval = [i_chunk, i_chunk+chunk_size];
    try
        temp=fetchn(rel_data & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'lickmap_fr_regular','ORDER BY roi_number');
        temp_F=[];
        for i=1:1:numel(temp)
            temp_F(i,:) = temp{i}(:)';
        end
    catch
        try
            temp_F=cell2mat(fetchn(rel_data & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'psth_regular','ORDER BY roi_number'));
        catch
            
            try
                temp=fetchn(rel_data & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'psth_per_position_regular','ORDER BY roi_number');
                temp_F=[];
                for i=1:1:numel(temp)
                    temp2 = cell2mat(temp{i}(:))';
                    temp_F(i,:) = temp2(:)';
                end
            catch
                temp_F=cell2mat(fetchn(rel_data & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'theta_tuning_curve','ORDER BY roi_number'));
            end
        end
    end
    temp_count=(counter+1):1: (counter + size(temp_F,1));
    F(temp_count,:)=temp_F;
    counter = counter + size(temp_F,1);
end


%% Computing Correlations
F = gpuArray((F));
try
    rho=corrcoef(F','rows','pairwise');
    rho=gather(rho);
catch
    F=gather(F);
    rho=corrcoef(F','rows','pairwise');
end

idx_lower_triangle=logical(tril(rho));

% rho = rho(idx_up_triangle);
rho = rho(idx_lower_triangle);

if isempty(rho)
    return
end



%% Shuffling distances
for i_sh=1:1:num_shuffles
    [axial_distance_bins, distance_corr_2d_shuffled, distance_corr_lateral_shuffled, distance_corr_axial_columns_shuffled] ...
        = fn_correlation_vs_distance_shuffled (x_all,y_all,z_all, rho, lateral_distance_bins, min_distance_in_xy, column_inner_radius, column_outer_radius);
    distance_corr_2d (i_sh,:,:) = distance_corr_2d_shuffled;
    distance_corr_lateral (i_sh,:) = distance_corr_lateral_shuffled;
    distance_corr_axial_columns (i_sh,:,:) = distance_corr_axial_columns_shuffled;
end

distance_corr_2d = squeeze(nanmean(distance_corr_2d,1));
distance_corr_lateral = nanmean(distance_corr_lateral,1);
distance_corr_axial_columns = squeeze(nanmean(distance_corr_axial_columns,1));

key.axial_distance_bins=axial_distance_bins;


try
    key.goodness_of_fit_vmises = goodness_of_fit_vmises_threshold;
catch
end

key.lateral_distance_bins=lateral_distance_bins;
key.num_cells_included = numel(roi_list);
key.distance_corr_2d=distance_corr_2d;
key.distance_corr_lateral=distance_corr_lateral;
key.distance_corr_axial_columns  = distance_corr_axial_columns;
key.column_inner_radius = column_inner_radius;
key.column_outer_radius = column_outer_radius;
insert(self,key);

end