function photostim_allpairs_distance_binning_mean()
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value'); 
dir_current_fig = [dir_base  '\Photostim\photostim_distance\'];

close all;
% frame_window_short=[40,40];
% frame_window_long=[100,100];



%
% key.subject_id = 447990;
% key.session =8;

% key.subject_id = 445980;
% key.session =5;
% key.subject_id = 445873;
% key.session =5;
% key.subject_id = 462458;
% key.session =5;

key.subject_id = 463195;
key.session =2;

neurons_or_control_flag =1; % 1 neurons, 0 control sites
flag_distance_flag = 0; % 0 lateral distance; 1 axial distance;  3d distance

epoch_list = fetchn(EXP2.SessionEpoch & 'session_epoch_type="spont_photo"' & key, 'session_epoch_number','ORDER BY session_epoch_number');
epoch_list=epoch_list(1);
% epoch_list=epoch_list(1:1:3);

% epoch_list = [1];
% rel=STIM.ROIResponse3 & 'response_p_value<=0.02';
rel=STIM.ROIResponse & 'response_p_value<=0.05';

flag_baseline_trial_or_avg = 0;

smooth_bins=1; %10

zoom =fetch1(IMG.FOVEpoch & key,'zoom','LIMIT 1');
kkk.scanimage_zoom = zoom;
pix2dist=  fetch1(IMG.Zoom2Microns & kkk,'fov_microns_size_x','LIMIT 1') / fetch1(IMG.FOV & key, 'fov_x_size','LIMIT 1');


kkkk.session_epoch_number=epoch_list(end);
frame_rate= fetch1(IMG.FOVEpoch & key & kkkk, 'imaging_frame_rate');
timewind_stim=[0.25,1.5];

timewind_baseline = [-15,-5];
time  = [-30: (1/frame_rate): 10];

xlims = [-5, 10];
ylims = [-0.1,0.4];

% distance_bins_microns = [0,25,50,75,100,125,150,200,500];
% distance_bins_microns = [0,25,50,75,100,125,175,250,500];
% distance_bins_microns = [0,25,50,75,100,150,300,600];
% distance_bins_microns = [0,25,50,75,150,300,500];
% distance_bins_microns = [0,30,60,90,120,200,300,400,500,600];
% distance_bins_microns = [0,25:25:275,300,400,500,600];

% distance_bins_microns = [0:25:100,150,200:100:500];
% distance_bins_microns = [0:25:500];
distance_bins_microns = [0:25:200,250:50:500];

%Graphics
%---------------------------------
figure;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

panel_width=0.04;
panel_height=0.06;
horizontal_distance=0.07;
vertical_distance=0.25;
position_x(1)=0.07;

position_y(1)=0.85;


session_date = fetch1(EXP2.Session & key,'session_date');
dir_current_fig = [dir_current_fig '\anm' num2str(key.subject_id) '\'];
filename=['distance_binned_session_' num2str(key.session) '_' session_date ];
if flag_distance_flag==0 % lateral distance
    distance_type_name = 'lateral';
elseif flag_distance_flag==1 % axial distance (depth)
    distance_type_name = 'axial';
elseif flag_distance_flag==2 % 3D distance in a volume
    distance_type_name = '3D';
end
filename = [filename distance_type_name];




% rel=(IMG.PhotostimGroupROI &  STIM.ROIResponseDirect & key  & 'flag_neuron_or_control=1' & 'distance_to_closest_neuron<17.25');
% G=fetch(IMG.PhotostimGroupROI & key  & 'flag_neuron_or_control=0' & 'distance_to_closest_neuron>17.25','*');


line_color=copper(numel(epoch_list));
% time=(-frame_window_long(1):1:frame_window_long(2)-1)/frame_rate;



for i_epoch=1:1:numel(epoch_list)
    k1=key;
    k1.session_epoch_number = epoch_list(i_epoch);
    %     rel_group_neurons=rel & (IMG.PhotostimGroup & (IMG.PhotostimGroupROI & STIM.ROIResponseDirect & 'flag_neuron_or_control=1' & 'distance_to_closest_neuron<10')& k1);
    
    hold on;
    plot([distance_bins_microns(2),distance_bins_microns(end)],[0,0],'-k');
    
    neurons_or_control_flag=0; % neurons
    OUTPUT =fn_bin_stimresponse_distance(rel, k1, neurons_or_control_flag,flag_distance_flag, pix2dist, distance_bins_microns);
    plot(distance_bins_microns(2:end),OUTPUT.mean_by_distance,'-b')
    OUTPUT2D =fn_bin_stimresponse_distance_2D(rel, k1, neurons_or_control_flag,pix2dist, distance_bins_microns);

%         neurons_or_control_flag=1; % control
%     OUTPUT =fn_bin_stimresponse_distance(rel, k1, neurons_or_control_flag,flag_distance_flag, pix2dist, distance_bins_microns);
%     plot(distance_bins_microns(2:end),OUTPUT.mean_by_distance,'-r')
%     mean(F_mean(distance>25))
figure
    map=OUTPUT2D.mean_by_distance';
        maxv=prctile(map(:),99);
        minv=min([prctile(map(:),0),0]);
        %rescaling
        map(map>maxv)=maxv;
        map(map<minv)=minv;
        imagesc(map);
        cmp = bluewhitered(512); % 256 element colormap



        imagesc(distance_bins_microns(2:end),OUTPUT2D.distance_axial_bins,map)
                axis tight
        axis equal
        colormap(cmp)
        colorbar
end

if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r100']);
