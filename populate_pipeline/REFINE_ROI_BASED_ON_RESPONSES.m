function REFINE_ROI_BASED_ON_RESPONSES()
% close all;
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value'); 
dir_current_fig = [dir_base  '\Photostim\Photostim_targets_map\refined'];

clf;
% key.subject_id = 447991;
% key.session = 11;

% key.subject_id = 463195;
% key.session =3;

key.subject_id = 462458;
key.session =8;

% key.subject_id = 462455;
% key.session =1;

key.session_epoch_number = 1;
key.plane_num = 1; %assuming photostimulation happens at the top plane
flag_auto_select_roi = 1;

most_response_distance=15; % in microns

num_roi_automatic = 200; %choose 400 roi
num_roi_manual= 0; %typically to add additional non-neural (control) targets manually
minimal_distance=15; % in microns; minimal distance between ROI

roi_radius=4.5; %not sure about units to define photostim path


filename_save = 'dat_20200202.mat';
dir_save_file = fetch1(EXP2.SessionEpochDirectory & key,'local_path_session_registered');


zoom =fetch1(IMG.FOVEpoch & key,'zoom');
kkk.scanimage_zoom = zoom;
pix2dist=  fetch1(IMG.Zoom2Microns & kkk,'fov_microns_size_x') / fetch1(IMG.FOV & key, 'fov_x_size');
most_response_distance_pixels = most_response_distance/pix2dist; % in pixels
minimal_distance_pixels = minimal_distance/pix2dist; % in pixels

%% ROI selection

XY_chosen=[];

ROI=fetch(IMG.ROI & key,'*','ORDER BY roi_number');
XY(:,1) = [ROI.roi_centroid_x];
XY(:,2) = [ROI.roi_centroid_y];
% roi_number_good=fetchn(IMG.ROIGood  & (ANLI.IncludeROI4 & 'number_of_events>10') & key,'roi_number','ORDER BY roi_number');
roi_number_good=fetchn(IMG.ROIGood   & key,'roi_number','ORDER BY roi_number');

% plot all good ROIs from suitep
mean_img = fetch1(IMG.Plane & key,'mean_img_enhanced');
hold on
imagesc(mean_img);
colormap(gray);
plot(XY(roi_number_good,1)',XY(roi_number_good,2)','og')
set(gca,'YDir','reverse')

roi_chosen=[];
if flag_auto_select_roi==1
    % first inlcude roi that showed largest responses to photostimulation from previous days
    roi_num_responsive=unique(fetchn(STIM.ROIResponseMost & key & sprintf('most_response_distance_pixels <%.2f', most_response_distance_pixels) & 'most_response_max>0.2' ,'roi_number'));
    
    % remove responsoves ROIs that were too close
    [IDX_remove]=fn_remove_neighbors_2D(XY(roi_num_responsive,:), minimal_distance_pixels);
    
    roi_chosen=roi_num_responsive;
    roi_chosen(IDX_remove)=[];
    
    if numel(roi_chosen)>num_roi_automatic
        roi_chosen(num_roi_automatic+1:end)=[];
    end
    
    % add additional rois automatically
    for i=1:1:(num_roi_automatic-numel(roi_chosen))
        available_roi_pool = setdiff(roi_number_good,roi_chosen);
        for  j=1:1:numel(available_roi_pool)
            temp_roi = available_roi_pool(j);
            dx = XY(roi_chosen,1) - XY(temp_roi,1);
            dy = XY(roi_chosen,2) - XY(temp_roi,2);
            dist = (sqrt(dx.^2 + dy.^2));
            if sum(find(dist<=minimal_distance_pixels))==0
                roi_chosen=[roi_chosen;temp_roi];
                break
            end
        end
    end
    
    XY_chosen = XY(roi_chosen,:);
    
    % plot all ROIs chosen so far
    plot(XY(roi_chosen,1)',XY(roi_chosen,2)','or');
end

% add additional rois manually (typically to add non-neural targets)
for i_t = 1:1:num_roi_manual
    [x_manual,y_manual] = ginput(1);
    XY_chosen(end+1,:) = [x_manual,y_manual];
    plot(x_manual,y_manual','*r')
    title(sprintf('Selected %d / %d',i_t,num_roi_manual));
end

s=fetch(EXP2.Session & key,'*');
title(sprintf('Session %d epoch %d \n anm %d  %s',s.session,  key.session_epoch_number,key.subject_id, s.session_date ));

%% Creating and saving a new dat file with photostimulation targets

dir_data = fetchn(EXP2.SessionEpochDirectory & key,'local_path_session_registered');
dir_data = dir_data{1};
global dat;
rel2=IMG.PhotostimDATfile & key;
% if ~isempty (IMG.PhotostimDATfile & key)
if rel2.count>0
    dat=fetch1(IMG.PhotostimDATfile & key,'dat_file');
else
    dat = (load([dir_data 'dat.mat'])); dat=dat.dat;
    close all;
end

centroid_reference_session = cell2mat({dat.roi.centroid}');
plot(centroid_reference_session(:,1),centroid_reference_session(:,2),'*k');

dat.roi=[];

dat.IM=mean_img;
dat.dim = size(mean_img);

m=size(mean_img,1);
n=size(mean_img,2);
[I,J] = ndgrid(1:m,1:n);
plane=1;

for i=1:size(XY_chosen,1)
    
    x=round( XY_chosen(i,1) );
    y=round( XY_chosen(i,2) );
    M = double((I-y).^2+(J-x).^2<=roi_radius^2); % <-- M should be your desired array
    pixel_list = find(M);
    addROI([x,y],[],pixel_list,plane);
end


save([dir_save_file filename_save],'dat');

dir_save_figure = [dir_current_fig 'anm' num2str(s.subject_id) '\'];
if isempty(dir(dir_save_figure))
    mkdir (dir_save_figure)
end
figure_name_out = [dir_save_figure  's' num2str(s.session ) '_' s.session_date '_epoch' num2str(key.session_epoch_number)];
eval(['print ', figure_name_out, ' -dtiff  -r200']);

end






