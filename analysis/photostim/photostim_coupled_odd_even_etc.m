function photostim_coupled_odd_even_etc()
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value'); 
dir_current_fig = [dir_base  '\Photostim_traces\coupled3'];

close all;
frame_rate=20;
frame_window=200;
key.session_epoch_number = 2;

group_list = fetchn(IMG.PhotostimGroup & key,'photostim_group_num','ORDER BY photostim_group_num');


line_color{1}=[0.5 0 0];
line_color{2}=[1 0 0];
epoch_list = [2:3];

x=(-frame_window:1:frame_window)/frame_rate;


for i_g=1:1:numel(group_list)
    key.photostim_group_num = group_list(i_g);
    
    for i_epoch=1:1:1%numel(epoch_list)
        k1=key;
        k1.session_epoch_number = epoch_list(i_epoch);
        signif_roi = fetchn(IMG.ROICoupled & k1 & 'coupling_p_value<=0.005','roi_number','ORDER BY roi_number');
        coupling_p_value = fetchn(IMG.ROICoupled & k1 & 'coupling_p_value<=0.005','coupling_p_value','ORDER BY roi_number');
        coupling_distance_pixels = fetchn(IMG.ROICoupled & k1 & 'coupling_p_value<=0.005','coupling_distance_pixels','ORDER BY roi_number');
        photostim_start_frame = fetch1(IMG.PhotostimGroup & k1,'photostim_start_frame');
        
        
        
        for i_r = 1:1:numel(signif_roi)
            k2=k1;
            k2.roi_number = signif_roi(i_r);
            f_trace = fetch1(IMG.ROITrace & k2,'f_trace','ORDER BY roi_number');
            
            
            F=[];
            for i_stim=1:1:numel(photostim_start_frame)-1
                s_fr = photostim_start_frame(i_stim);
                F(i_stim,:)=f_trace(s_fr-frame_window:1:s_fr+frame_window);
            end
            
            
            
            
            mF = mean(F,1);
            baseline= mean(mF(1:frame_window-1));
            mdFoverF=(mF - baseline)/baseline;
            hold on;
            smth=smooth(mdFoverF,10);
            plot(x(5:1:end-5),smth(5:1:end-5),'Color',line_color{i_epoch});
            
            
            title(sprintf('Photostim group=%d    ROI=%d    p=%.6f  distance = %.1f (pixels)',group_list(i_g), signif_roi(i_r), coupling_p_value(i_r), coupling_distance_pixels(i_r)));
            
            
            %% save figure
            %             dir_current_fig2 = [dir_current_fig '\group_' num2str(group_list(i_g)) '\'];
            dir_current_fig2 = [dir_current_fig '\'];
            
            if isempty(dir(dir_current_fig2))
                mkdir (dir_current_fig2)
            end
            %
            filename=['photostim_group_' num2str(group_list(i_g)) '_roi_' num2str(signif_roi(i_r))];
            figure_name_out=[ dir_current_fig2 filename];
            eval(['print ', figure_name_out, ' -dtiff  -r100']);
            % eval(['print ', figure_name_out, ' -dpdf -r200']);
            
            clf;
            
        end
    end
    
    
    
    
end
