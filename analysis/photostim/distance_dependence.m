function distance_dependence()
close all;
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value'); 
dir_current_fig = [dir_base  '\Photostim\photostim_distance\'];

% key.subject_id = 447990;
% key.session =8;

% key.subject_id = 445980;
% key.session =7;

% key.subject_id = 445873;
% key.session =5;

% key.subject_id = 462458;
% key.session =12;

% key.subject_id = 463195;
% key.session =4;


% key.subject_id = 462455;
% key.session =3;

key.subject_id = 463192;
key.session =3;

% key.subject_id = 464728;
% key.session =2;

flag_distance_flag =0; % 0 lateral distance; 1 axial distance;  2  3d distance

if flag_distance_flag==0 % lateral distance
    distance_type_name = 'Lateral';
elseif flag_distance_flag==1 % axial distance (depth)
    distance_type_name = 'Axial';
elseif flag_distance_flag==2 % 3D distance in a volume
    distance_type_name = '3D';
end


epoch_list = fetchn(EXP2.SessionEpoch & 'session_epoch_type="spont_photo"' & key, 'session_epoch_number','ORDER BY session_epoch_number');
key.session_epoch_number = epoch_list(1); % to take the photostim groups from
% epoch_list=epoch_list(1:end-1);

rel=STIM.ROIResponse;

% distance_to_closest_neuron=35; % in microns
% response_p_value=0.001;
% min_distance_to_closest_neuron=15; % in microns to be considered target neurons (versus contro sites)
response_p_value=0.01; % for signficance

% distance_bins = [0:10:120,inf]; % in microns
distance_bins = [0:10:150]; % in microns


zoom =fetch1(IMG.FOVEpoch & key,'zoom');
kkk.scanimage_zoom = zoom;
pix2dist=  fetch1(IMG.Zoom2Microns & kkk,'fov_microns_size_x') / fetch1(IMG.FOV & key, 'fov_x_size');

% min_distance_to_closest_neuron = min_distance_to_closest_neuron/pix2dist; % in pixels

%Graphics
%---------------------------------
figure;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

panel_width=0.09;
panel_height=0.1;
horizontal_distance=0.15;
vertical_distance=0.18;

position_x(1)=0.07;
position_x(end+1)=position_x(end) + horizontal_distance+0.19;
position_x(end+1)=position_x(end) + horizontal_distance;
position_x(end+1)=position_x(end) + horizontal_distance;
position_x(end+1)=position_x(end) + horizontal_distance;

position_y(1)=0.8;


session_date = fetch1(EXP2.Session & key,'session_date');
dir_current_fig = [dir_current_fig '\anm' num2str(key.subject_id) '\'];
filename=['distance_session_' num2str(key.session) '_' session_date ];
filename = [filename distance_type_name];


% G_controls=fetch(IMG.PhotostimGroupROI & key  & 'flag_neuron_or_control=0' & sprintf('distance_to_closest_neuron > %d', min_distance_to_closest_neuron),'*');
G_controls=(IMG.PhotostimGroupROI -STIM.ROIResponseDirect) & key;
G_controls = fetch(G_controls,'*');
% G_neurons=fetch(IMG.PhotostimGroupROI & key  & 'flag_neuron_or_control=1' & sprintf('distance_to_closest_neuron <= %d', distance_to_closest_neuron),'*');
G_neurons=fetch(IMG.PhotostimGroupROI & (IMG.PhotostimGroup & (STIM.ROIResponseDirect & key & 'response_p_value<0.01')) ,'*');





for i_epoch=1:1:numel(epoch_list)
    k1=key;
    k1.session_epoch_number = epoch_list(i_epoch);
    
    
    %% Neural sites
    axes('position',[position_x(2), position_y(end), panel_width, panel_height]);
    line_color=[1 0 1];
    hold on;
    %     rel_group_neurons= rel & (IMG.PhotostimGroup & (IMG.PhotostimGroupROI & 'flag_neuron_or_control=1'  & sprintf('distance_to_closest_neuron <= %d', distance_to_closest_neuron) & k1)) ;
    
    %     rel_target_neurons =  IMG.PhotostimGroup &(STIM.ROIResponseDirect & k1 & 'response_p_value<=0.05');
    rel_target_neurons =  IMG.PhotostimGroup &(STIM.ROIResponseDirect & k1 & 'response_p_value<=0.01');
    
    number_of_target_neurons = rel_target_neurons.count;
    rel_group_neurons= rel & rel_target_neurons;
    
    [distance_bins_neurons,y_neurons, N_signif_neurons,N_all_neurons, idx_nonempty_bins_neurons] = fn_plot_distance_dependence(rel_group_neurons, distance_bins, flag_distance_flag, response_p_value,line_color);
    title(sprintf('Neuronal targets \nn = %d',(number_of_target_neurons)),'Color',line_color);
    xlabel([sprintf('                                       %s distance from nearest target',distance_type_name)  ' (\mum)']);
    ylabel('\Delta F/F');
    xlim([0,max(distance_bins)])
    set(gca,'Xtick',[0,50,100,150]);
    
    %% Control sites
    axes('position',[position_x(3), position_y(end), panel_width, panel_height]);
    line_color = [0 0 1];
    hold on;
    %     rel_target_controls =  (IMG.PhotostimGroup & (IMG.PhotostimGroupROI & 'flag_neuron_or_control=0' &  sprintf('distance_to_closest_neuron > %d', min_distance_to_closest_neuron) & k1));
    % rel_target_controls= IMG.PhotostimGroup &((IMG.PhotostimGroupROI -STIM.ROIResponseDirect)& k1) ;
    rel_target_controls = IMG.PhotostimGroup &(STIM.ROIResponseDirect & k1 & 'response_p_value>0.1');
    
    number_of_target_controls = rel_target_controls.count;
    rel_group_controls= rel & rel_target_controls;
    
    [distance_bins_control,y_control, N_signif_control,N_all_control, idx_nonempty_bins_control] =  fn_plot_distance_dependence(rel_group_controls, distance_bins, flag_distance_flag, response_p_value,line_color);
    
    title(sprintf('Control targets \nn = %d',(number_of_target_controls)),'Color',line_color);
    
    xlim([0,max(distance_bins)])
    set(gca,'Xtick',[0,50,100,150]);
    

    distance_bins_neurons = distance_bins_neurons(2:1:end);
    distance_bins_control = distance_bins_control(2:1:end);

    %% Connection probability normalized to number of photostim sites
    axes('position',[position_x(4), position_y(end), panel_width, panel_height]);
    hold on;
    plot(distance_bins_neurons(idx_nonempty_bins_neurons),N_signif_neurons(idx_nonempty_bins_neurons)/number_of_target_neurons,'Color',[1 0 1],'LineWidth',2);
    plot(distance_bins_control(idx_nonempty_bins_control),N_signif_control(idx_nonempty_bins_control)/number_of_target_controls,'Color',[0 0 1],'LineWidth',2);
    xlim([0,max(distance_bins)])
    set(gca,'Xtick',[0,50,100,150]);
    ylabel('Connections per target');
    xlabel([sprintf('                                       %s distance from nearest target',distance_type_name)  ' (\mum)']);
    
    %% Connection probability normalized to number of pairs at that distance bin
    axes('position',[position_x(5), position_y(end), panel_width, panel_height]);
    hold on;
    plot(distance_bins_neurons(idx_nonempty_bins_neurons),N_signif_neurons(idx_nonempty_bins_neurons)./N_all_neurons(idx_nonempty_bins_neurons),'Color',[1 0 1],'LineWidth',2);
    plot(distance_bins_control(idx_nonempty_bins_control),N_signif_control(idx_nonempty_bins_control)./N_all_control(idx_nonempty_bins_control),'Color',[0 0 1],'LineWidth',2);
    xlim([0,max(distance_bins)])
    set(gca,'Xtick',[0,50,100,150]);
    ylabel('Connection probability');
%     xlabel(' Distance from nearest target (\mum)');
    %     ylim([0,0.2])
    
    position_y(end+1)=position_y(end) -vertical_distance;

end
% & sprintf('duration > %d', duration)

axes('position',[position_x(1), 0.7, 0.25, 0.25]);

% R=fetch((IMG.ROI&IMG.ROIGood) & key & 'plane_num=1','*');
R=fetch((IMG.ROI&IMG.ROIGood) & key,'*');
mean_img_enhanced = fetch1(IMG.Plane & key & 'plane_num=1','mean_img_enhanced');
x_dim = [0:1:(size(mean_img_enhanced,1)-1)]*pix2dist;
y_dim = [0:1:(size(mean_img_enhanced,2)-1)]*pix2dist;
imagesc(x_dim, y_dim, mean_img_enhanced);
colormap(gray)
hold on
% plot ROIS
for i_f=1:1:numel(R)
    x=R(i_f).roi_centroid_x*pix2dist;
    y=R(i_f).roi_centroid_y*pix2dist;
    plot(x,y,'og','MarkerSize',3)
end

% plot neuron targets
for i_f=1:1:numel(G_neurons)
    x=G_neurons(i_f).photostim_center_x*pix2dist;
    y=G_neurons(i_f).photostim_center_y*pix2dist;
    plot(x,y,'.m','MarkerSize',10)
end

% plot control targets
for i_f=1:1:numel(G_controls)
    x=G_controls(i_f).photostim_center_x*pix2dist;
    y=G_controls(i_f).photostim_center_y*pix2dist;
    plot(x,y,'.b','MarkerSize',10)
end

axis xy
set(gca,'YDir','reverse')
set(gca,'Xlim',[min(x_dim),max(x_dim)],'Xtick',[0, ceil(max(x_dim))], 'Ylim',[min(y_dim),max(y_dim)],'Ytick',[0,ceil(max(y_dim))],'TickLength',[0.01,0],'TickDir','out')
axis equal
axis tight
xlabel('Anterior - Posterior (\mum)');
ylabel('Lateral - Medial (\mum)');
plane_num = numel(fetchn(IMG.Plane & key,'plane_num'));
title(sprintf('ROIs from %d planes',plane_num));

if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r500']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);





