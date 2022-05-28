function fn_compute_distance_psth_correlation_old(rel_roi, rel_data, key,self, dir_save_fig, goodness_of_fit_vmises_threshold)

column_radius(1) =50; % microns
column_radius(2) =200; % microns




DefaultFontSize =12;

% set(gcf,'DefaultAxesFontSize',6);

horizontal_dist=0.45;
vertical_dist=0.35;

panel_width1=0.2;
panel_height1=0.25;
position_x1(1)=0.2;
position_x1(end+1)=position_x1(end)+horizontal_dist;

position_y1(1)=0.5;
position_y1(end+1)=position_y1(end)-vertical_dist;





lateral_distance_bins=[0,20,30:10:210];
min_distance_in_xy=5; %to exclude auto-focus flourescence

session_date = fetch1(EXP2.Session & key,'session_date');
try
    filename = sprintf('anm%d_s%d_%s_threshold%d',key.subject_id,key.session, session_date, 100*key.odd_even_corr_threshold);
catch
    filename = sprintf('anm%d_s%d_%s_vnmises%d',key.subject_id,key.session, session_date, 100*goodness_of_fit_vmises_threshold);
end

%% Loading Data
roi_list=fetchn(rel_roi,'roi_number','ORDER BY roi_number');
chunk_size=500;
counter=0;
for i_chunk=1:chunk_size:roi_list(end)
    roi_interval = [i_chunk, i_chunk+chunk_size];
    try
        temp_F=cell2mat(fetchn(rel_data & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'psth_quadrants','ORDER BY roi_number'));
    catch
        try
            temp_F=cell2mat(fetchn(rel_data & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'psth','ORDER BY roi_number'));
        catch
            temp_F=cell2mat(fetchn(rel_data & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'theta_tuning_curve','ORDER BY roi_number'));
        end
    end
    temp_count=(counter+1):1: (counter + size(temp_F,1));
    F(temp_count,:)=temp_F;
    counter = counter + size(temp_F,1);
end


%% Distance between all pairs

x_all=fetchn(rel_roi &key,'roi_centroid_x','ORDER BY roi_number');
y_all=fetchn(rel_roi &key,'roi_centroid_y','ORDER BY roi_number');
z_all=fetchn(rel_roi*IMG.PlaneCoordinates & key,'z_pos_relative','ORDER BY roi_number');

x_pos_relative=fetchn(rel_roi*IMG.PlaneCoordinates &key,'x_pos_relative','ORDER BY roi_number');
y_pos_relative=fetchn(rel_roi*IMG.PlaneCoordinates &key,'y_pos_relative','ORDER BY roi_number');

x_all = x_all + x_pos_relative; x_all = x_all/0.75;
y_all = y_all + y_pos_relative; y_all = y_all/0.5;



dXY=zeros(numel(x_all),numel(x_all));
%             d3D=zeros(numel(x_all),numel(x_all));
dZ=zeros(numel(z_all),numel(z_all));
parfor iROI=1:1:numel(x_all)
    x=x_all(iROI);
    y=y_all(iROI);
    z=z_all(iROI);
    dXY(iROI,:)= sqrt((x_all-x).^2 + (y_all-y).^2); % in um
    dZ(iROI,:)= abs(z_all-z); % in um
    %                 d3D(iROI,:) = sqrt((x_all-x).^2 + (y_all-y).^2 + (z_all-z).^2); % in um
end

axial_distance_bins = unique(dZ)';
key.axial_distance_bins=axial_distance_bins;

temp=logical(tril(dXY));
idx_up_triangle=~temp;
dZ = dZ(idx_up_triangle);
dXY = dXY(idx_up_triangle);


%% Computing SVD and correlations
rho=[];
F = gpuArray((F));
try
    rho=corrcoef(F','rows','pairwise');
    rho=gather(rho);
catch
    F=gather(F);
    rho=corrcoef(F','rows','pairwise');
end
rho = rho(idx_up_triangle);

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
for i_a=1:1:numel(axial_distance_bins)
    idx_lateral = dXY<=column_radius(1) & dXY>=min_distance_in_xy;
    idx_axial =  dZ==axial_distance_bins(i_a);
    distance_corr_axial_inside_column(i_a)=nanmean(rho(idx_axial & idx_lateral));
end

% axial outside column
for i_a=1:1:numel(axial_distance_bins)
    idx_lateral = dXY>column_radius(1) & dXY<=column_radius(2);
    idx_axial =  dZ==axial_distance_bins(i_a);
    distance_corr_axial_outside_column(i_a)=nanmean(rho(idx_axial & idx_lateral));
end




ax1=axes('position',[position_x1(1), position_y1(1), panel_width1, panel_height1]);

imagesc(lateral_distance_bins(1:1:end-1), axial_distance_bins, distance_corr_2d')
xlabel('Lateral Distance (um)');
ylabel('Axial Distance (um)');
% colorbar
colormap(inferno)
c_lim(1)=nanmin(distance_corr_2d(:));
c_lim(2) = nanmax(distance_corr_2d(:));
caxis([c_lim]);

axis tight
axis equal
% set(gca,'XTick',OUT1.distance_lateral_bins_centers)
xlabel([sprintf('Lateral Distance ') '(\mum)']);
% ylabel([sprintf('Axial Distance ') '(\mum)']);
% colorbar
% set(gca,'YTick',[],'XTick',[20,100:100:500]);
set(gca,'YTick',[axial_distance_bins],'XTick',[0,50:50:200]);
ylabel([sprintf('Axial      \nDistance ') '(\mum)        ']);
try
    title(sprintf('anm%d s%d %s \nodd even corr threshold = %.2f \n',key.subject_id,key.session, session_date, key.odd_even_corr_threshold));
catch
    title(sprintf('anm%d s%d %s \ngoodness of fit vonmises = %.2f \n',key.subject_id,key.session, session_date, goodness_of_fit_vmises_threshold));
end


ax2=axes('position',[position_x1(1)+0.2, position_y1(1)+0.07, panel_width1*0.2, panel_height1*0.45]);
colormap(ax2, inferno)
caxis(c_lim);
cb=colorbar;
text(12, 0.2, ['Correlation'],'Rotation',90);
axis off


if isempty(dir(dir_save_fig))
    mkdir (dir_save_fig)
end


fig = gcf;    %or one particular figure whose handle you already know, or 0 to affect all figures
set( findall(fig, '-property', 'fontsize'), 'fontsize', DefaultFontSize)



figure_name_out=[dir_save_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r300']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);
clf;

try
    key.goodness_of_fit_vmises = goodness_of_fit_vmises_threshold;
catch
end
key.lateral_distance_bins=lateral_distance_bins;
key.num_cells_included = numel(roi_list);
key.distance_corr_2d=distance_corr_2d;
key.distance_corr_lateral=distance_corr_lateral;
key.distance_corr_axial_inside_column = distance_corr_axial_inside_column;
key.distance_corr_axial_outside_column = distance_corr_axial_outside_column;

insert(self,key);

end