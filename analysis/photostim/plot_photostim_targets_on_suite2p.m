function plot_photostim_targets_on_suite2p()
close all

dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value'); 
dir_current_fig = [dir_base  '\Photostim\Photostim_targets_map\'];
% key.subject_id = 447990;
% key.session =1;
key.subject_id = 447991;
key.session= 11;
epoch_list = fetchn(EXP2.SessionEpoch & 'session_epoch_type="spont_photo"' & key, 'session_epoch_number','ORDER BY session_epoch_number');
key.session_epoch_number = epoch_list(end); % to take the photostim groups from


%Graphics
%---------------------------------
figure;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

session_date = fetch1(EXP2.Session & key,'session_date');
dir_current_fig = [dir_current_fig '\anm' num2str(key.subject_id) '\'];
filename=['distance_session_' num2str(key.session) '_' session_date ];




% G=fetch(IMG.PhotostimGroupROI & key  & 'flag_neuron_or_control=1' & 'distance_to_closest_neuron<15','*');
G=fetch(IMG.PhotostimGroupROI & key  & 'flag_neuron_or_control=1','*');
R=fetch((IMG.ROI) & key & IMG.ROIGood,'*');


mean_img_enhanced = fetch1(IMG.Plane & key,'mean_img_enhanced');

imagesc(mean_img_enhanced)
colormap(gray)
hold on

for i_f=1:1:numel(R)
    x=R(i_f).roi_centroid_x;
        y=R(i_f).roi_centroid_y;
    plot(x,y,'og')
end
title(sprintf('anm%d session%d %s',key.subject_id,  key.session, session_date ));
for i_f=1:1:numel(G)
    x=G(i_f).photostim_center_x;
        y=G(i_f).photostim_center_y;
    plot(x,y,'*m')
end
axis equal
axis tight;

if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r500']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);
