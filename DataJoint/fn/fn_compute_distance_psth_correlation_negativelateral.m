function fn_compute_distance_psth_correlation_negativelateral(rel_roi, rel_data, key,self, dir_save_fig, rel_roi_xy,mesoscope_flag)

min_distance_in_xy=10; %to exclude auto-focus flourescence

column_inner_radius =[10 10  50   100   -30 -50 -100 -250]; % microns
column_outer_radius =[30 50  100  250   -10 -10 -50  -100]; % microns

lateral_distance_bins=[-100:20:0 20:20:100];
% lateral_distance_bins=[5,15,25:10:255];


DefaultFontSize =12;

% set(gcf,'DefaultAxesFontSize',6);

horizontal_dist1=0.5;
vertical_dist=0.35;

panel_width1=0.2;
panel_height1=0.25;
position_x1(1)=0.1;
position_x1(end+1)=position_x1(end)+horizontal_dist1;

position_y1(1)=0.7;
position_y1(end+1)=position_y1(end)-vertical_dist;
position_y1(end+1)=position_y1(end)-vertical_dist;
position_y1(end+1)=position_y1(end)-vertical_dist;


panel_width2=0.08;
panel_height2=0.15;

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
        temp_F=cell2mat(fetchn(rel_data & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'psth_quadrants','ORDER BY roi_number'));
    catch
        try
            temp_F=cell2mat(fetchn(rel_data & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'psth','ORDER BY roi_number'));
        catch
            
            try
                temp_F=cell2mat(fetchn(rel_data & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'psth_position_concat_regularreward','ORDER BY roi_number'));
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


dXY_x=zeros(numel(x_all),numel(x_all));
dXY_y=zeros(numel(x_all),numel(x_all));

%             d3D=zeros(numel(x_all),numel(x_all));
dZ=zeros(numel(z_all),numel(z_all));
for iROI=1:1:numel(x_all)
    x=x_all(iROI);
    y=y_all(iROI);
    z=z_all(iROI);
    dXY_x(iROI,:)= sqrt((x_all-x).^2 + (y_all-y).^2).*sign((y_all-y)); % in um
    dXY_y(iROI,:)= sqrt((x_all-x).^2 + (y_all-y).^2).*sign((x_all-x)); % in um

    dZ(iROI,:)= abs(z_all-z); % in um
    %                 d3D(iROI,:) = sqrt((x_all-x).^2 + (y_all-y).^2 + (z_all-z).^2); % in um
end

% temp=logical(tril(dXY));
% idx_up_triangle=~temp;
% dZ = dZ(idx_up_triangle);
% dXY = dXY(idx_up_triangle);

idx_lower_triangle=logical(tril(dXY_x));
dZ = dZ(idx_lower_triangle);
dXY_x = dXY_x(idx_lower_triangle);
dXY_y = dXY_y(idx_lower_triangle);

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

distance_corr_2d_x=zeros(numel(axial_distance_bins),numel(lateral_distance_bins)-1);
distance_corr_2d_y=zeros(numel(axial_distance_bins),numel(lateral_distance_bins)-1);

for i_l=1:1:numel(lateral_distance_bins)-1
    
    idx_lateral = dXY_x>lateral_distance_bins(i_l) & dXY_x<=lateral_distance_bins(i_l+1) & abs(dXY_x)>=min_distance_in_xy;
    dz_temp=dZ(idx_lateral);
    rho_lateral=rho(idx_lateral);
    distance_corr_lateral_x(i_l)=nanmean(rho_lateral);
    parfor i_a=1:1:numel(axial_distance_bins)
        idx_axial =  dz_temp==axial_distance_bins(i_a);
        distance_corr_2d_x(i_a,i_l)=nanmean(rho_lateral(idx_axial));
    end
    
    idx_lateral = dXY_y>lateral_distance_bins(i_l) & dXY_y<=lateral_distance_bins(i_l+1) & abs(dXY_y)>=min_distance_in_xy;
    dz_temp=dZ(idx_lateral);
    rho_lateral=rho(idx_lateral);
    distance_corr_lateral_y(i_l)=nanmean(rho_lateral);
    parfor i_a=1:1:numel(axial_distance_bins)
        idx_axial =  dz_temp==axial_distance_bins(i_a);
        distance_corr_2d_y(i_a,i_l)=nanmean(rho_lateral(idx_axial));
    end
end


% axial within column
for i_c=1:1:numel(column_inner_radius)
    for i_a=1:1:numel(axial_distance_bins)
        idx_axial =  dZ==axial_distance_bins(i_a);
        
        idx_lateral = dXY_x>=column_inner_radius(i_c) & dXY_x<column_outer_radius(i_c);
        distance_corr_axial_columns_x(i_a, i_c)=nanmean(rho(idx_axial & idx_lateral));
        
        idx_lateral = dXY_y>=column_inner_radius(i_c) & dXY_y<column_outer_radius(i_c);
        distance_corr_axial_columns_y(i_a, i_c)=nanmean(rho(idx_axial & idx_lateral));

    end
end


%% 2D

%% Positive negative in X
ax1=axes('position',[position_x1(1), position_y1(1), panel_width1, panel_height1]);
bins_lateral_center = lateral_distance_bins(1:end-1) + mean(diff(lateral_distance_bins))/2;

imagesc(lateral_distance_bins,axial_distance_bins,  distance_corr_2d_x)
xlabel('Lateral Distance (um)');
ylabel('Axial Distance (um)');
% colorbar
colormap(inferno)
c_lim(1)=nanmin(distance_corr_2d_x(:));
c_lim(2) = nanmax(distance_corr_2d_x(:));
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
    title(sprintf('anm%d s%d %s \nodd even corr threshold >= %.2f \n \n Positive negative in X',key.subject_id,key.session, session_date, key.odd_even_corr_threshold), 'Color', [1 0 0]);
catch
    title(sprintf('anm%d s%d %s \ngoodness of fit Vonmises >= %.2f \n Positive negative in X',key.subject_id,key.session, session_date, goodness_of_fit_vmises_threshold), 'Color', [1 0 0]);
end

%colorbar
ax2=axes('position',[position_x1(1)+0.2, position_y1(1)+0.07, panel_width1*0.2, panel_height1*0.45]);
colormap(ax2, inferno)
caxis(c_lim);
cb1=colorbar;
text(8, 0.2, ['Correlation'],'Rotation',90);
axis off


%% Positive negative in Y
ax3=axes('position',[position_x1(2), position_y1(1), panel_width1, panel_height1]);
bins_lateral_center = lateral_distance_bins(1:end-1) + mean(diff(lateral_distance_bins))/2;

imagesc(lateral_distance_bins,axial_distance_bins,  distance_corr_2d_y)
xlabel('Lateral Distance (um)');
ylabel('Axial Distance (um)');
% colorbar
colormap(inferno)
c_lim(1)=nanmin(distance_corr_2d_y(:));
c_lim(2) = nanmax(distance_corr_2d_y(:));
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
    title(sprintf('anm%d s%d %s \nodd even corr threshold >= %.2f \n \n Positive negative in Y',key.subject_id,key.session, session_date, key.odd_even_corr_threshold), 'Color', [0 0 1]);
catch
    title(sprintf('anm%d s%d %s \ngoodness of fit Vonmises >= %.2f \n Positive negative in Y',key.subject_id,key.session, session_date, goodness_of_fit_vmises_threshold), 'Color', [0 0 1]);
end

%colorbar
ax4=axes('position',[position_x1(2)+0.2, position_y1(1)+0.07, panel_width1*0.2, panel_height1*0.45]);
colormap(ax4, inferno)
caxis(c_lim);
cb1=colorbar;
text(8, 0.2, ['Correlation'],'Rotation',90);
axis off


%% Lateral marginal
axes('position',[position_x2(1), position_y1(2), panel_width2, panel_height2]);
hold on
plot(bins_lateral_center,distance_corr_lateral_x,'.-r')
plot(bins_lateral_center,distance_corr_lateral_y,'.-b')
xlabel('Lateral Distance (um)');
ylabel('Correlation');

%% Axial Marginal X
%Axial marginal, in various column sizes
column_id=1;
axes('position',[position_x2(2), position_y1(2), panel_width2, panel_height2]);
hold on
plot(axial_distance_bins,distance_corr_axial_columns_x(:,column_id),'.-k')
plot(axial_distance_bins,distance_corr_axial_columns_x(:,column_id+4),'.-g')
xlabel('Axial Distance (um)');
title(sprintf('Column radius\n%.0f=<r<%.0fum',column_inner_radius(column_id), column_outer_radius(column_id)),'Color',[1 0 0])

%Axial marginal, in various column sizes
column_id=2;
axes('position',[position_x2(3), position_y1(2), panel_width2, panel_height2]);
hold on
plot(axial_distance_bins,distance_corr_axial_columns_x(:,column_id),'.-k')
plot(axial_distance_bins,distance_corr_axial_columns_x(:,column_id+4),'.-g')
xlabel('Axial Distance (um)');
title(sprintf('Column radius\n%.0f<=r<%.0fum',column_inner_radius(column_id), column_outer_radius(column_id)),'Color',[1 0 0])

%Axial marginal, in various column sizes
column_id=3;
axes('position',[position_x2(4), position_y1(2), panel_width2, panel_height2]);
hold on
plot(axial_distance_bins,distance_corr_axial_columns_x(:,column_id),'.-k')
plot(axial_distance_bins,distance_corr_axial_columns_x(:,column_id+4),'.-g')
xlabel('Axial Distance (um)');
title(sprintf('Column radius\n%.0f<=r<%.0fum',column_inner_radius(column_id), column_outer_radius(column_id)),'Color',[1 0 0])

%Axial marginal, in various column sizes
column_id=4;
axes('position',[position_x2(5), position_y1(2), panel_width2, panel_height2]);
hold on
plot(axial_distance_bins,distance_corr_axial_columns_x(:,column_id),'.-k')
plot(axial_distance_bins,distance_corr_axial_columns_x(:,column_id+4),'.-g')
xlabel('Axial Distance (um)');
title(sprintf('Column radius\n%.0f<=r<%.0fum',column_inner_radius(column_id), column_outer_radius(column_id)),'Color',[1 0 0])


%% Axial marginal Y, in various column sizes
column_id=1;
axes('position',[position_x2(2), position_y1(3), panel_width2, panel_height2]);
hold on
plot(axial_distance_bins,distance_corr_axial_columns_y(:,column_id),'.-k')
plot(axial_distance_bins,distance_corr_axial_columns_y(:,column_id+4),'.-g')
xlabel('Axial Distance (um)');
title(sprintf('Column radius\n%.0f=<r<%.0fum',column_inner_radius(column_id), column_outer_radius(column_id)),'Color',[0 0 1])

%Axial marginal, in various column sizes
column_id=2;
axes('position',[position_x2(3), position_y1(3), panel_width2, panel_height2]);
hold on
plot(axial_distance_bins,distance_corr_axial_columns_y(:,column_id),'.-k')
plot(axial_distance_bins,distance_corr_axial_columns_y(:,column_id+4),'.-g')
xlabel('Axial Distance (um)');
title(sprintf('Column radius\n%.0f<=r<%.0fum',column_inner_radius(column_id), column_outer_radius(column_id)),'Color',[0 0 1])

%Axial marginal, in various column sizes
column_id=3;
axes('position',[position_x2(4), position_y1(3), panel_width2, panel_height2]);
hold on
plot(axial_distance_bins,distance_corr_axial_columns_y(:,column_id),'.-k')
plot(axial_distance_bins,distance_corr_axial_columns_y(:,column_id+4),'.-g')
xlabel('Axial Distance (um)');
title(sprintf('Column radius\n%.0f<=r<%.0fum',column_inner_radius(column_id), column_outer_radius(column_id)),'Color',[0 0 1])

%Axial marginal, in various column sizes
column_id=4;
axes('position',[position_x2(5), position_y1(3), panel_width2, panel_height2]);
hold on
plot(axial_distance_bins,distance_corr_axial_columns_y(:,column_id),'.-k')
plot(axial_distance_bins,distance_corr_axial_columns_y(:,column_id+4),'.-g')
xlabel('Axial Distance (um)');
title(sprintf('Column radius\n%.0f<=r<%.0fum',column_inner_radius(column_id), column_outer_radius(column_id)),'Color',[0 0 1])


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

key.distance_corr_2d_x=distance_corr_2d_x;
key.distance_corr_2d_y=distance_corr_2d_y;

key.distance_corr_lateral_x=distance_corr_lateral_x;
key.distance_corr_lateral_y=distance_corr_lateral_y;

key.distance_corr_axial_columns_x  = distance_corr_axial_columns_x;
key.distance_corr_axial_columns_y  = distance_corr_axial_columns_y;


key.column_inner_radius = column_inner_radius;
key.column_outer_radius = column_outer_radius;
insert(self,key);

end