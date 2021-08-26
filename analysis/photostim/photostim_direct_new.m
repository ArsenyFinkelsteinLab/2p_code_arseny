function photostim_direct_new()
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value'); 
dir_current_fig = [dir_base  '\Photostim\photostim_traces\new\'];

close all;
% key.subject_id = 447990;
% key.session =8;
% key.subject_id = 462458;
% key.session =3;
% key.subject_id = 447991;
% key.session = 11;

% key.subject_id = 445873;
% key.session =5;


% key.subject_id = 462458;
% key.session =12;

% key.subject_id = 463195;
% key.session =4;

% key.subject_id = 462455;
% key.session =1;

% key.subject_id = 462455;
% key.session =3;

% key.subject_id = 463192;
% key.session =3;
% 
% key.subject_id = 462458;
% key.session =12;


% key.subject_id = 464728;
% key.session =2;

key.subject_id = 486673;
key.session =5;

% key.subject_id = 486668;
% key.session =5;

% key.subject_id = 481101;
% key.session =1;

% Take photostim groups from here:
epoch_list = fetchn(EXP2.SessionEpoch & 'session_epoch_type="spont_photo"' & key, 'session_epoch_number','ORDER BY session_epoch_number');
take_phtostim_groups_epoch = 1;
key.session_epoch_number = epoch_list(take_phtostim_groups_epoch); % to take the photostim groups from
epoch_list=epoch_list();
flag_baseline_trial_or_avg=2; %0 - baseline averaged across trials, 1 baseline per trial, 2 global baseline - mean of roi across the entire session epoch


% frame_window_short=[40,40]/4;
% frame_window_long=[200,100]/2;
% frame_window_short=[40,40];
% frame_window_long=[100,200];
smooth_bins=1; %2

if flag_baseline_trial_or_avg==0 % baseline averaged across trials
    dir_suffix= 'baseline_avg';
elseif flag_baseline_trial_or_avg==1 % baseline per trial
    dir_suffix= 'baseline_trial';
elseif flag_baseline_trial_or_avg==2 % global baseline
    dir_suffix= 'baseline_global';
end
% dir_current_fig=[dir_current_fig dir_suffix '_' num2str(frame_window_short(1)) 'frames\'];

session_date = fetch1(EXP2.Session & key,'session_date');
dir_current_fig = [dir_current_fig '\anm' num2str(key.subject_id) '\session_' num2str(key.session) '_' session_date  '\'];


zoom =fetch1(IMG.FOVEpoch & key,'zoom');
kkk.scanimage_zoom = zoom;
pix2dist=  fetch1(IMG.Zoom2Microns & kkk,'fov_microns_size_x') / fetch1(IMG.FOV & key, 'fov_x_size');

try
    frame_rate= fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
catch
    frame_rate= fetch1(IMG.FOV & key, 'imaging_frame_rate');
end

timewind_stim=[0.25,1.5];
% timewind_baseline=[0.25,1.5]-10;
% timewind_baseline = [-15,-5];
% time  = [-20: (1/frame_rate): 10];

timewind_baseline = [-5,0];
time  = [-5: (1/frame_rate): 11];

%Graphics
%---------------------------------
figure;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

panel_width=0.15;
panel_height=0.2;
horizontal_distance=0.25;
vertical_distance=0.3;

position_x(1)=0.13;
position_x(end+1)=position_x(end) + horizontal_distance;
position_x(end+1)=position_x(end) + horizontal_distance;
position_x(end+1)=position_x(end) + horizontal_distance;

position_y(1)=0.65;
position_y(end+1)=position_y(end) - vertical_distance*0.7;
position_y(end+1)=position_y(end) - vertical_distance;



G=fetch(IMG.PhotostimGroupROI & key,'*');



roi_list_direct=[G.roi_number];
distance=[G.distance_to_closest_neuron]*pix2dist;


line_color=copper(numel(epoch_list));
% line_color=flip(line_color);


for i_g=1:1:numel(roi_list_direct)
    key.photostim_group_num = G(i_g).photostim_group_num;
    
    k1=key;
    k1.roi_number = roi_list_direct(i_g);
    
    k2=key;
    
    
    for i_epoch=1:1:numel(epoch_list)
        k1.session_epoch_number = epoch_list(i_epoch);
        
        f_trace = fetch1(IMG.ROITrace & k1,'f_trace');
        f_trace_epoch{i_epoch} = f_trace;
        photostim_start_frame = fetch1(IMG.PhotostimGroup & k1,'photostim_start_frame');
        %         global_baseline=mean(movmin(f_trace_direct(i_epoch,:),1009));
        global_baseline=mean( f_trace);
        
        timewind_response = [ 0 2];
        timewind_baseline1 = [ -3 0];
        timewind_baseline2  = [-3 0] ;
        timewind_baseline3  = [ -3 0];
        [~,StimTrace] = fn_compute_photostim_response (f_trace_epoch{i_epoch} , photostim_start_frame, timewind_response, timewind_baseline1,timewind_baseline2,timewind_baseline3, flag_baseline_trial_or_avg, global_baseline, time);

        
           y=StimTrace.response_trace_mean;
            y_smooth=  movmean(y,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
            ystem=StimTrace.response_trace_stem;
            ystem_smooth=  movmean(ystem,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
            
            max_epoch(i_epoch)=max(y_smooth);
            min_epoch(i_epoch)=min(y_smooth);
            hold on;
            plot(time,y_smooth,'Color',line_color(i_epoch,:));
            shadedErrorBar(time,y_smooth,ystem_smooth,'lineprops',{'-','Color',[0 0 0]})

        end
        ylim ([min([-0.2,min_epoch]),max([1 ,max_epoch])]);
        xlabel('Time (s)');
        ylabel('\Delta F/F')    

        
        set(gca,'FontSize',60);


        set(gca,'Ytick',[-0.2, 0, 1],'Xtick',[ 0, 5, 10]);

        title(sprintf('anm %d, session %d \n Direct photostimulation \n Target # %d  \n Distance = %.1f um  \n \n \n',k2.subject_id,k2.session,G(i_g).photostim_group_num, distance(i_g)),'FontSize',12);

        
        
%         pval(i_epoch)=StimStat.p_val;
%         Fstim_mean(i_epoch)=StimStat.Fstim_mean;
%         Fstim_coefvar(i_epoch) = StimStat.Fstim_coefvar;
%         Fstim_meanwind_trials{i_epoch} = StimStat.Fstim_meanwind_trials;
%         Fbase_control_meanwind_trials{i_epoch} = StimStat.Fbase_control_meanwind_trials;
%         
%         %         Fstim_maxwind_trials{i_epoch} =StimStat.Fstim_maxwind_trials;
%         %         Fbase_control_maxwind_trials{i_epoch} =  StimStat.Fbase_control_maxwind_trials;
%         
%         dFoverF_mean=StimTrace.dFoverF_mean;
%         y_temp=dFoverF_mean;
%         y_temp= movmean(y_temp,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
%         y(i_epoch,:) = y_temp;
%         idx_stim(1)=find(time>(timewind_stim(1)),1,'first');
%         idx_stim(2)=find(time<=(timewind_stim(2)),1,'last');
%         y_norm(i_epoch,:) =  y_temp./max(y_temp(idx_stim(1):idx_stim(2)));
%         
%     end
%     
%     % Plot response
%     axes('position',[position_x(1), position_y(1), panel_width, panel_height]);
%     for i_epoch=1:1:numel(epoch_list)
%         hold on;
%         plot(time(2:end-1),y(i_epoch,2:end-1),'Color',line_color(i_epoch,:));
%         ylim ([min([-0.1,min(y(:))]),max([0.5 ,max(y(:))])]);
%         xlabel('Time from photostim (s)');
%         ylabel('\Delta F/F');
%     end
%     %     title(sprintf('Photostim group=%d    ROI=%d     p=%.6f  \ndistance = %.1f (pixels) response mean %.2f',G(i_g).photostim_group_num, k1.roi_number, pval(1), distance(i_g),Fstim_mean(1)));
%     title(sprintf('Direct photostimulation \n Target # %d   ROI=%d \n Distance = %.1f um  \nResponse %.2f dF/F \n p-val=%.6f  \n',G(i_g).photostim_group_num, k1.roi_number, distance(i_g), Fstim_mean(take_phtostim_groups_epoch),  pval(take_phtostim_groups_epoch)));
%     set(gca,'FontSize',10)
%     xlim([-7.5,7.5]);

    
%     % Plot normalized response
%     axes('position',[position_x(2), position_y(1), panel_width, panel_height]);
%     for i_epoch=1:1:numel(epoch_list)
%         hold on;
%         plot(time(2:end-1),y_norm(i_epoch, 2:end-1),'Color',line_color(i_epoch,:));
%         %         title(sprintf('Group=%d ROI=%d \ndistance=%.1f um',G(i_g).photostim_group_num, roi_list_direct(i_g), distance(i_g)*pix2dist));
%         ylim ([ nanmin([-0.1,nanmin(y_norm(:))]) , nanmax([nanmax(y_norm(:)),0.1]) ]);
%         xlabel('Time from photostim (s)');
%         ylabel('\Delta F/F, normalized');
% 
%     end
%     set(gca,'FontSize',10)
%     xlim([-7.5,7.5]);

%     % Plot response variability across trials
%     for i_epoch=1:1:numel(epoch_list)
%         axes('position',[position_x(i_epoch), position_y(2), panel_width, panel_height/2]);
%         
%         hold on;
%         %         xxx = Fstim_maxwind_trials{i_epoch};
%         %         yyy = Fbase_control_maxwind_trials{i_epoch};
%         xxx = Fstim_meanwind_trials{i_epoch};
%         yyy = Fbase_control_meanwind_trials{i_epoch};
%         bins = linspace(min([xxx;yyy]),max([xxx;yyy]),25);
%         
%         h1=histogram(xxx,bins);
%         h1.FaceColor=[0 0 1];
%         h1.Normalization = 'probability';
%         h1.EdgeColor='none';
%         %
%         %         h2=histogram(yyy,bins);
%         %         h2.Normalization = 'probability';
%         %         h2.FaceColor=[0.5 .5 .5];
%         %         h2.EdgeColor='none';
%         
%         
%         %         plot(time(2:end-1),y_norm(i_epoch, 2:end-1),'Color',line_color(i_epoch,:));
%         %         %         title(sprintf('Group=%d ROI=%d \ndistance=%.1f um',G(i_g).photostim_group_num, roi_list_direct(i_g), distance(i_g)*pix2dist));
%         %         ylim ([ nanmin([-0.1,nanmin(y_norm(:))]) , nanmax([nanmax(y_norm(:)),0.1]) ]);
%         %         xlabel('Time (s)');
%         %         ylabel('\Delta F/F, normalized');
%         set(gca,'FontSize',10);
%         if i_epoch==1
%             xlabel(('                               Response \Delta F/F (mean over response window)'));
%             ylabel('Percentage');
%         end
%         title(sprintf('Session epoch #%d\nCV = %.1f',i_epoch, Fstim_coefvar(i_epoch)));
%     end
%     
%     
%     % Plot Baseline Fluourescene fluctutation. This is not the same "baseline" used for computing the photostim response
%     axes('position',[position_x(1), position_y(3), panel_width, panel_height]);
%     for i_epoch=1:1:numel(epoch_list)
%         hold on;
%         moving_minimum=movmin(f_trace_epoch{i_epoch},frame_rate*60);
%         %                 smooth_b=smooth(smooth_b,100,'sgolay',3);
%         %                 plot(f_trace_direct(i_epoch,:),'Color','k');
%         plot([1:1:numel(moving_minimum)]/frame_rate, moving_minimum,'Color',line_color(i_epoch,:));
%         %         title(sprintf('Group=%d ROI=%d \ndistance=%.1f um',G(i_g).photostim_group_num, roi_list_direct(i_g), distance(i_g)*pix2dist));
%     end
%     set(gca,'FontSize',10)
%     title('Baseline Flourescence')
%     ylabel('F');
%     xlabel('Time (s)')
%     
%     
%     %     k2.session_epoch_number = epoch_list(i_epoch);
%     
%     %         roi_coupled=fetchn(STIM.ROIResponse & k2 & 'response_p_value<=0.05' & 'response_distance_pixels<=100','roi_number', 'ORDER BY response_mean');
%     %         if ~isempty(roi_coupled)
%     %             roi_coupled=roi_coupled(end);
%     %
%     %             k3=k2;
%     %             k3.roi_number = roi_coupled;
%     %             f_trace_coupled = fetch1(IMG.ROITrace & k3,'f_trace');
%     %             [~,StimTrace] = fn_compute_photostim_response (f_trace_coupled, photostim_start_frame, frame_window);
%     %             dFoverF_mean=StimTrace.dFoverF_mean;
%     %             subplot(2,2,2+i_epoch)
%     %             hold on;
%     %             plot(time,dFoverF_mean,'Color',line_color{i_epoch});
%     %             C=fetch(STIM.ROIResponse & k3,'*');
%     %
%     %             title(sprintf('Maximally coupled ROI=%d \ndistance=%.2f pval = %.4f', C.roi_number, C.response_distance_pixels, C.response_p_value));
%     %
%     %         end
%     %
    
    
    if isempty(dir(dir_current_fig))
        mkdir (dir_current_fig)
    end
    %
    filename=['photostim_group_' num2str(G(i_g).photostim_group_num)];
    figure_name_out=[ dir_current_fig filename];
    eval(['print ', figure_name_out, ' -dtiff  -r300']);
    % eval(['print ', figure_name_out, ' -dpdf -r200']);
    
    clf;
    
    
end
