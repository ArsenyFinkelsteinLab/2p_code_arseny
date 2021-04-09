function photostim_allpairs_distance_binning()
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
% key.session =3;

key.subject_id = 463195;
key.session =2;

neurons_or_control_flag =0; % 0 neurons, 1 control sites
flag_distance_flag = 0; % 0 lateral distance; 1 axial distance;  3d distance

epoch_list = fetchn(EXP2.SessionEpoch & 'session_epoch_type="spont_photo"' & key, 'session_epoch_number','ORDER BY session_epoch_number');
epoch_list=epoch_list(1:1:3);

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
distance_bins_microns = [0:25:100,150,200:100:500];
% distance_bins_microns = [0,25:25:275,300,400,500,600];

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
if neurons_or_control_flag == 0
%     rel_group_targets=rel & (IMG.PhotostimGroup & (IMG.PhotostimGroupROI & (STIM.ROIResponseDirect &'response_p_value<0.01'))& k1);
    rel_group_targets =  rel & (IMG.PhotostimGroup & (STIM.ROIResponseDirect & k1 & 'response_p_value<=0.001')) & k1;

    elseif neurons_or_control_flag == 1
    rel_group_targets =  rel & (IMG.PhotostimGroup & (STIM.ROIResponseDirect & k1 & 'response_p_value>0.1')) & k1;
end

    %     rel_group_neurons=rel & (IMG.PhotostimGroup & (IMG.PhotostimGroupROI & STIM.ROIResponseDirect & 'flag_neuron_or_control=0' & 'distance_to_closest_neuron>10')& k1);
    
    DATA=fetch(rel_group_targets,'*');
    
    F=zeros(size(DATA,1),212);
    F_mean=zeros(size(DATA));
    
    parfor i_r=1:1:numel(DATA)
        i_r
        k2=DATA(i_r,:);
        photostim_start_frame = fetch1(IMG.PhotostimGroup & k2,'photostim_start_frame');
        f_trace = fetch1(IMG.ROITrace & k2,'f_trace');
        global_baseline=mean( f_trace);
        
        [StimStat,StimTrace] = fn_compute_photostim_response (f_trace, photostim_start_frame, timewind_stim, timewind_baseline, flag_baseline_trial_or_avg,global_baseline, time);
        
        %         [StimStat,StimTrace] = fn_compute_photostim_response (f_trace , photostim_start_frame, frame_window_short,frame_window_long, flag_baseline_trial_or_avg, global_baseline, time);
        F(i_r,:)=StimTrace.dFoverF_mean;
        F_mean(i_r)=StimStat.Fstim_mean;
        
    end
    
    if flag_distance_flag==0 % lateral distance
        distance=[DATA.response_distance_pixels]';
        distance=pix2dist*distance;
    elseif flag_distance_flag==1 % axial distance
        distance=[DATA.response_distance_axial_um]';
    elseif flag_distance_flag==2 % 3D distance
        distance=[DATA.response_distance_3d_um]';
    end
    
    ix_excit= F_mean>=0;
    ix_inhbit= F_mean<0;
    num_roi_bin_all =[];
    num_roi_bin_excit =[];
    num_roi_bin_inhibit =[];
    
    for i_d=1:1:numel(distance_bins_microns)-1
        ix_d = distance>=distance_bins_microns(i_d) & distance<distance_bins_microns(i_d+1);
        
        num_roi_bin_all(i_d)=sum(ix_d);
        num_roi_bin_excit(i_d) =sum(ix_d & ix_excit);
        num_roi_bin_inhibit(i_d) =sum(ix_d & ix_inhbit);
        
        trace_mean_by_distance_all(i_d,:)=mean(F(ix_d,:),1);
        trace_mean_by_distance_excit(i_d,:)=mean(F(ix_d & ix_excit,:),1);
        trace_mean_by_distance_inhibit(i_d,:)=mean(F(ix_d & ix_inhbit,:),1);
        mean_by_distance(i_d) =mean(F_mean(ix_d));
    end
    
    plot(distance_bins_microns(2:end),mean_by_distance)
    
    
    for i_d=1:1:numel(distance_bins_microns)-1
        
        %         if num_roi_bin_excit(i_d)>0
        % Positive
        axes('position',[position_x(i_d), position_y(i_epoch), panel_width, panel_height]);
        y_m = trace_mean_by_distance_all(i_d,:);
        %        y_smooth=  y_m;
        y_smooth=  movmean(y_m,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
        position_x(end+1)=position_x(end) +horizontal_distance;
        plot(time(2:end-1),y_smooth(2:end-1),'Color',line_color(i_epoch,:));
        %         max_epoch(i_d)=max(y_smooth);
        %         min_epoch(i_d)=min(y_smooth);
        %       ylims = [ min([-0.05, floor(10*min_epoch(i_d))/10]),  max([0.1, ceil(10*max_epoch(i_d))/10])];
        title(sprintf('[%d %d] um\n %d cells',distance_bins_microns(i_d),distance_bins_microns(i_d+1),num_roi_bin_all(i_d)),'FontSize',10);
        
        set(gca, 'YLim',ylims,'YTick', [])
        if i_d==1
            %             xlabel(' Time(s)');
            ylabel('\Delta F/F');
            set(gca,'YLim',ylims,'YTick', [0, ylims(2)],'YTickLabels',[0, ylims(2)]);
        end
        set(gca,'FontSize',10, 'Xlim', xlims, 'XTick', [xlims(1),0,xlims(2)]);
        %        end
        
        %         if num_roi_bin_inhibit(i_d)>0
        % Negative
        axes('position',[position_x(i_d), position_y(i_epoch)-0.1, panel_width, panel_height]);
        y_m = trace_mean_by_distance_inhibit(i_d,:);
        %        y_smooth=  y_m;
        y_smooth=  movmean(y_m,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
        plot(time(2:end-1),y_smooth(2:end-1),'Color',line_color(i_epoch,:));
        %         max_epoch(i_d)=max(y_smooth);
        %         min_epoch(i_d)=min(y_smooth);
        %       ylims = [ min([-0.05, floor(10*min_epoch(i_d))/10]),  max([0.1, ceil(10*max_epoch(i_d))/10])];
        title(sprintf('%d cells',num_roi_bin_inhibit(i_d)),'FontSize',10);
        
        set(gca, 'YLim',ylims,'YTick', [])
        if i_d==1
            xlabel(' Time (s)');
            ylabel('\Delta F/F');
            text(-20,diff(ylims)/2,' Inhibition','Rotation',90);
            set(gca,'YLim',ylims,'YTick', [0, ylims(2)],'YTickLabels',[0, ylims(2)]);
            
        end
        set(gca,'FontSize',10, 'Xlim', xlims, 'XTick', [xlims(1),0,xlims(2)]);
        %         end
        
        position_x(end+1)=position_x(end) +horizontal_distance;
        
    end
    
    
    
    %     hold on;
    %     plot(time(2:end-1),y_smooth(2:end-1),'Color',line_color(i_epoch,:));
    %
    %
    %     xlabel('Time (s)');
    %     ylabel('\Delta F/F');
    %
    position_y(end+1)=position_y(end) -vertical_distance;
    
    
end

if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r100']);
