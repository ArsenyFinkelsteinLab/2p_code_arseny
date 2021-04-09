function photostim_coupled()
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value'); 
dir_current_fig = [dir_base  '\Photostim\photostim_traces\coupled_new_far_positive'];

% key.subject_id = 462458;
% key.session =12;

key.subject_id = 462455;
key.session =2;

% key.subject_id = 447991;
% key.session =10;
% key.subject_id = 462458;
% key.session =1;
% key.subject_id = 445980;
% key.session =2;
epoch_list = fetchn(EXP2.SessionEpoch & 'session_epoch_type="spont_photo"' & key, 'session_epoch_number','ORDER BY session_epoch_number');
% key.session_epoch_number = epoch_list(end); % to take the photostim groups from
% key.session_epoch_number = epoch_list(3); % to take the photostim groups from
% epoch_list=epoch_list(1:1:3);
key.session_epoch_number = epoch_list(1); % to take the photostim groups from
epoch_list=epoch_list(1);
min_distance_to_closest_target=50; % in microns

close all;
frame_window_short=[40,40]/4;
frame_window_long=[50,100]/2;
flag_baseline_trial_or_avg=0; %1 baseline per trial, 0 - baseline averaged across trials


zoom =fetch1(IMG.FOVEpoch & key,'zoom');
kkk.scanimage_zoom = zoom;
pix2dist=  fetch1(IMG.Zoom2Microns & kkk,'fov_microns_size_x') / fetch1(IMG.FOV & key, 'fov_x_size');
try
    frame_rate= fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
catch
    frame_rate= fetch1(IMG.FOV & key, 'imaging_frame_rate');
end
min_distance_to_closest_target_pixels=min_distance_to_closest_target/pix2dist;

rel=STIM.ROIInfluence5 & 'response_p_value1<=0.01' & sprintf('response_distance_lateral_um >%.2f', min_distance_to_closest_target_pixels) & 'response_mean>0';

if flag_baseline_trial_or_avg==0 %baseline averaged across trials
    dir_suffix= 'baseline_avg';
elseif flag_baseline_trial_or_avg==1 % baseline per trial
    dir_suffix= 'baseline_trial';
elseif flag_baseline_trial_or_avg==2 % global baseline
    dir_suffix= 'baseline_global';
end
session_date = fetch1(EXP2.Session & key,'session_date');
dir_current_fig = [dir_current_fig '\anm' num2str(key.subject_id) '\session_' num2str(key.session) '_' session_date  '\'];



smooth_bins=1;







%Graphics
%---------------------------------
figure;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

panel_width=0.2;
panel_height=0.25;
horizontal_distance=0.2;
vertical_distance=0.3;

position_x(1)=0.13;
position_x(end+1)=position_x(end) + horizontal_distance;

position_y(1)=0.7;


G=fetch(IMG.PhotostimGroupROI & key,'*');

group_list=[G.photostim_group_num];


line_color=copper(numel(epoch_list)); %bright - later epoch
% line_color=flip(line_color);

time=(-frame_window_long(1):1:frame_window_long(2)-1)/frame_rate;



for i_g=1:1:numel(group_list)
    key.photostim_group_num = group_list(i_g);
    
    
    k1=key;
    signif_roi=[];
%     signif_roi = fetchn(rel & k1 ,'roi_number','ORDER BY roi_number');
%     response_p_value = fetchn(rel & k1 ,'response_p_value','ORDER BY roi_number');
%     response_mean = fetchn(rel & k1 ,'response_mean','ORDER BY roi_number');
%     response_distance_pixels = fetchn(rel & k1 ,'response_distance_pixels','ORDER BY roi_number');  % in pixels
%     response_distance_pixels = response_distance_pixels * pix2dist; % in microns
    DATA =fetch(rel & k1 ,'*','ORDER BY roi_number');
    signif_roi = [DATA.roi_number];
%     flag_distance_flag=5
%         if flag_distance_flag==0 % lateral distance
%         distance=[DATA.response_distance_pixels];
%         distance=pix2dist*distance;
%     elseif flag_distance_flag==1 % axial distance
%         distance=[DATA.response_distance_axial_um];
%     elseif flag_distance_flag==2 % 3D distance
%         distance=[DATA.response_distance_3d_um];
%         end
        
    
    
    for i_r = 1:1:numel(signif_roi)
        k2=k1;
        k2.roi_number = signif_roi(i_r);
        
        
        for i_epoch=1:1:numel(epoch_list)
            
            k2.session_epoch_number = epoch_list(i_epoch);
            photostim_start_frame = fetch1(IMG.PhotostimGroup & k2,'photostim_start_frame');
            
            f_trace_direct{i_epoch} = fetch1(IMG.ROITrace & k2,'f_trace');
            
            global_baseline=mean( f_trace_direct{i_epoch});
            
            timewind_response = [ 0 2];
            timewind_baseline1 = [ -3 0];
            timewind_baseline2  = [-3 0] ;
            timewind_baseline3  = [ -3 0];
            [~,StimTrace] = fn_compute_photostim_response (f_trace_direct{i_epoch} , photostim_start_frame, timewind_response, timewind_baseline1,timewind_baseline2,timewind_baseline3, flag_baseline_trial_or_avg, global_baseline, time);
            
            
            y=StimTrace.response_trace_mean;
            y_smooth=  movmean(y,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
            ystem=StimTrace.response_trace_stem;
            ystem_smooth=  movmean(ystem,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
            
            max_epoch(i_epoch)=max(y_smooth);
            min_epoch(i_epoch)=min(y_smooth);
            hold on;
            plot(time(1:end-1),y_smooth,'Color',line_color(i_epoch,:));
            shadedErrorBar(time(1:end-1),y_smooth,ystem_smooth,'lineprops',{'-','Color',[0 0 0]})

        end
        ylim ([min([-0.2,min_epoch]),max([0.5 ,max_epoch])]);
        xlabel('Time (s)');
        ylabel('\Delta F/F')    
%         title(sprintf('Coupled responses \n Target # %d   ROI=%d \n Distance = %.1f (um), Amplitude %.2f, p-val=%.6f  \n',G(i_g).photostim_group_num, k2.roi_number, DATA(i_r).response_distance_pixels * pix2dist,  DATA(i_r).response_mean,  DATA(i_r).response_p_value));

        
%         title(sprintf('Photostim group=%d    ROI=%d    \n p=%.6f  distance = %.1f (pixels) response mean %.2f',G(i_g).photostim_group_num, k2.roi_number, response_p_value(i_r), response_distance_pixels(i_r), response_mean(i_r)));
        set(gca,'FontSize',60);
                title(sprintf('anm %d, session %d \n Coupled responses \n Target # %d   ROI=%d \n Distance lateral = %.1f (um) \n Distance axial = %.1f (um) \n Distance 3D = %.1f (um)\n Amplitude %.2f, p-val=%.6f  \n \n \n',k2.subject_id,k2.session, G(i_g).photostim_group_num, k2.roi_number, DATA(i_r).response_distance_lateral_um, DATA(i_r).response_distance_axial_um, DATA(i_r).response_distance_3d_um, DATA(i_r).response_mean,  DATA(i_r).response_p_value1),'FontSize',10);

        set(gca,'Ytick',[-0.2, 0, 0.5]);

          
    if isempty(dir(dir_current_fig))
        mkdir (dir_current_fig)
    end
    %
        filename=['photostim_group_' num2str(group_list(i_g)) '_roi_' num2str(signif_roi(i_r))];
    figure_name_out=[ dir_current_fig filename];
    eval(['print ', figure_name_out, ' -dtiff  -r100']);
    % eval(['print ', figure_name_out, ' -dpdf -r200']);
    
    clf;
        
%         %% save figure
%         %             dir_current_fig2 = [dir_current_fig '\group_' num2str(group_list(i_g)) '\'];
%         dir_current_fig2 = [dir_current_fig '\'];
%         
%         if isempty(dir(dir_current_fig2))
%             mkdir (dir_current_fig2)
%         end
%         %
%         filename=['photostim_group_' num2str(group_list(i_g)) '_roi_' num2str(signif_roi(i_r))];
%         figure_name_out=[ dir_current_fig2 filename];
%         eval(['print ', figure_name_out, ' -dtiff  -r100']);
%         % eval(['print ', figure_name_out, ' -dpdf -r200']);
%         
%         clf;
        
    end
end




end
