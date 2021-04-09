function photostim_direct_mean()
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value'); 
dir_current_fig = [dir_base  '\Photostim_traces\mean_direct_20190426\'];

close all;
frame_rate=20;
frame_window=[200,200];

key.subject_id = 445105;
key.session =2;
key.session_epoch_number = 2;
epoch_list = [5,4,3,2,1];
% epoch_list = [2];
smooth_bins=10;

pix2dist= fetch1(IMG.Parameters & 'parameter_name="fov_size_microns_z1.1"', 'parameter_value')/fetch1(IMG.FOV & key, 'fov_x_size');


%Graphics
%---------------------------------
figure;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

panel_width=0.4;
panel_height=0.4;
horizontal_distance=0.2;
vertical_distance=0.3;

position_x(1)=0.13;
position_x(end+1)=position_x(end) + horizontal_distance;

position_y(1)=0.5;







G=fetch(IMG.PhotostimGroupROI & key  & 'flag_neuron_or_control=1' & 'distance_to_closest_neuron<17.25','*');
% G=fetch(IMG.PhotostimGroupROI & key  & 'flag_neuron_or_control=0' & 'distance_to_closest_neuron>17.25','*');

roi_list_direct=[G.roi_number];
distance=[G.distance_to_closest_neuron];


line_color=copper(numel(epoch_list));
line_color=flip(line_color);
time=(-frame_window(1):1:frame_window(2)-1)/frame_rate;


axes('position',[position_x(1), position_y(1), panel_width, panel_height]);

for i_epoch=1:1:numel(epoch_list)
    
    for i_g=1:1:numel(roi_list_direct)
        key.photostim_group_num = G(i_g).photostim_group_num;
        
        k1=key;
        k1.roi_number = roi_list_direct(i_g);
        k1.session_epoch_number = epoch_list(i_epoch);
        
        f_trace_direct = fetch1(IMG.ROITrace & k1,'f_trace');
        photostim_start_frame = fetch1(IMG.PhotostimGroup & k1,'photostim_start_frame');
        
        [~,StimTrace] = fn_compute_photostim_response2 (f_trace_direct, photostim_start_frame, frame_window);
        dFoverF_mean=StimTrace.dFoverF_mean;
        y(i_g,:)=dFoverF_mean;
        
    end
    y_m = mean(y);
    y_smooth=  movmean(y_m,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
    
    max_epoch(i_epoch)=max(y_smooth);
    min_epoch(i_epoch)=min(y_smooth);
    hold on;
    plot(time(2:end-1),y_smooth(2:end-1),'Color',line_color(i_epoch,:));
    
    
    ylim ([min([-0.1,min_epoch]),max([0.5 ,max_epoch])]);
    xlabel('Time (s)');
    ylabel('\Delta F/F');
    
end

if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
filename=['control'];
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r100']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);

