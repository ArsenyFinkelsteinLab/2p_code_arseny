function fn_compute_distance_psth_correlation(rel_roi, rel_data, key,self, dir_save_fig, rel_roi_xy,mesoscope_flag)

min_distance_in_xy=10; %to exclude auto-focus flourescence

column_inner_radius =[10 10 10 10 10 10 10 10  10  10  10  10  25 25 25  30 30 30 30  30  40  40 40  50  50  60  60  60  60  100 120 120]; % microns
column_outer_radius =[25 30 40 50 60 75 90 100 120 150 200 250 50 40 100 50 60 75 100 120 60  70 100 100 250 250 100 250 120 250 250 500]; % microns

lateral_distance_bins=[0,10,20,30:10:500];
% lateral_distance_bins=[5,15,25:10:255];


DefaultFontSize =12;

% set(gcf,'DefaultAxesFontSize',6);

horizontal_dist1=0.5;
vertical_dist=0.35;

panel_width1=0.2;
panel_height1=0.25;
position_x1(1)=0.1;
position_x1(end+1)=position_x1(end)+horizontal_dist1;

position_y1(1)=0.5;
position_y1(end+1)=position_y1(end)-vertical_dist;
position_y1(end+1)=position_y1(end)-vertical_dist;
position_y1(end+1)=position_y1(end)-vertical_dist;


panel_width2=0.08;
panel_height2=0.25;

horizontal_dist2=0.15;

position_x2(1)=0.1;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;
position_x2(end+1)=position_x2(end)+horizontal_dist2;


session_date = fetch1(EXP2.Session & key,'session_date');
try
    filename = sprintf('anm%d_s%d_%s_threshold%d',key.subject_id,key.session, session_date, 100*key.odd_even_corr_threshold);
catch
    filename = sprintf('anm%d_s%d_%s_vnmises%d',key.subject_id,key.session, session_date, 100*goodness_of_fit_vmises_threshold);
end

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


%% Distance between all pairs


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

% temp=logical(tril(dXY));
% idx_up_triangle=~temp;
% dZ = dZ(idx_up_triangle);
% dXY = dXY(idx_up_triangle);

idx_lower_triangle=logical(tril(dXY));
dZ = dZ(idx_lower_triangle);
dXY = dXY(idx_lower_triangle);

axial_distance_bins = unique(dZ)';
key.axial_distance_bins=axial_distance_bins;


%% Computing SVD and correlations
F = gpuArray((F));
try
    rho=corrcoef(F','rows','pairwise');
    rho=gather(rho);
catch
    F=gather(F);
    rho=corrcoef(F','rows','pairwise');
end
% rho = rho(idx_up_triangle);
rho = rho(idx_lower_triangle);

if isempty(rho)
    return
end

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


%% 2D

ax1=axes('position',[position_x1(1), position_y1(1), panel_width1, panel_height1]);
bins_lateral_center = lateral_distance_bins(1:end-1) + mean(diff(lateral_distance_bins))/2;

imagesc(lateral_distance_bins,axial_distance_bins,  distance_corr_2d)
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
    title(sprintf('anm%d s%d %s \nodd even corr threshold >= %.2f \n',key.subject_id,key.session, session_date, key.odd_even_corr_threshold));
catch
    title(sprintf('anm%d s%d %s \ngoodness of fit Vonmises >= %.2f \n',key.subject_id,key.session, session_date, goodness_of_fit_vmises_threshold));
end

%colorbar
ax2=axes('position',[position_x1(1)+0.2, position_y1(1)+0.07, panel_width1*0.2, panel_height1*0.45]);
colormap(ax2, inferno)
caxis(c_lim);
cb1=colorbar;
text(8, 0.2, ['Correlation'],'Rotation',90);
axis off

%% 2D thresholded -- only showing negative correlations to check for potential lateral inhibition
distance_corr_2d_negative=distance_corr_2d;
distance_corr_2d_negative(distance_corr_2d(:)>=0)=0;


ax3=axes('position',[position_x1(2), position_y1(1), panel_width1, panel_height1]);

imagesc(bins_lateral_center,axial_distance_bins,  distance_corr_2d_negative)
xlabel('Lateral Distance (um)');
ylabel('Axial Distance (um)');
% colorbar
colormap(inferno)
c_lim(1)=nanmin([distance_corr_2d_negative(:);-0.01]);
c_lim(2) = nanmax(0);
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

title(sprintf('Negative correlations thresholded'));

%colorbar
ax4=axes('position',[position_x1(2)+0.2, position_y1(1)+0.07, panel_width1*0.2, panel_height1*0.45]);
colormap(ax3, inferno)
caxis(c_lim);
cb2=colorbar;
text(8, 0.2, ['Correlation'],'Rotation',90);
axis off


%Lateral marginal
axes('position',[position_x2(1), position_y1(2), panel_width2, panel_height2]);
plot(bins_lateral_center,distance_corr_lateral,'.-k')
xlabel('Lateral Distance (um)');
ylabel('Correlation');

%Axial marginal, in various column sizes
column_id=2;
axes('position',[position_x2(2), position_y1(2), panel_width2, panel_height2]);
plot(axial_distance_bins,distance_corr_axial_columns(:,column_id),'.-k')
xlabel('Axial Distance (um)');
title(sprintf('Column radius\n%.0f=<r<%.0fum',column_inner_radius(column_id), column_outer_radius(column_id)))

%Axial marginal, in various column sizes
column_id=3;
axes('position',[position_x2(3), position_y1(2), panel_width2, panel_height2]);
plot(axial_distance_bins,distance_corr_axial_columns(:,column_id),'.-k')
xlabel('Axial Distance (um)');
title(sprintf('Column radius\n%.0f<=r<%.0fum',column_inner_radius(column_id), column_outer_radius(column_id)))

%Axial marginal, in various column sizes
column_id=16;
axes('position',[position_x2(4), position_y1(2), panel_width2, panel_height2]);
plot(axial_distance_bins,distance_corr_axial_columns(:,column_id),'.-k')
xlabel('Axial Distance (um)');
title(sprintf('Column radius\n%.0f<=r<%.0fum',column_inner_radius(column_id), column_outer_radius(column_id)))

%Axial marginal, in various column sizes
column_id=24;
axes('position',[position_x2(5), position_y1(2), panel_width2, panel_height2]);
plot(axial_distance_bins,distance_corr_axial_columns(:,column_id),'.-k')
xlabel('Axial Distance (um)');
title(sprintf('Column radius\n%.0f<=r<%.0fum',column_inner_radius(column_id), column_outer_radius(column_id)))


%Axial marginal, in various column sizes
column_id=30;
axes('position',[position_x2(6), position_y1(2), panel_width2, panel_height2]);
plot(axial_distance_bins,distance_corr_axial_columns(:,column_id),'.-k')
xlabel('Axial Distance (um)');
title(sprintf('Column radius\n%.0f<=r<%.0fum',column_inner_radius(column_id), column_outer_radius(column_id)))


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
key.distance_corr_axial_columns  = distance_corr_axial_columns;
key.column_inner_radius = column_inner_radius;
key.column_outer_radius = column_outer_radius;
insert(self,key);

end