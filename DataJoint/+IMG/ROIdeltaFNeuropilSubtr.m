%{
# Flourescent trace
-> EXP2.SessionEpoch
-> IMG.ROI
---
dff_trace      : longblob   # (s) delta f over f
%}


classdef ROIdeltaFNeuropilSubtr < dj.Imported
    properties
        keySource = EXP2.SessionEpoch & IMG.ROI & IMG.ROITrace & IMG.ROITraceNeuropil;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            close all;
            
            running_window=60; %seconds
            neuropil_substraction_factor = 0.7;
            
            
            dir_base =fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\ROI\Neuropilcorrection\'];
            session_date = fetch1(EXP2.Session & key,'session_date');
            dir_current_fig = [dir_current_fig 'anm' num2str(key.subject_id) '\' session_date '\'];
            if isempty(dir(dir_current_fig))
                mkdir (dir_current_fig)
            end
            
            try
                frame_rate= fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
            catch
                frame_rate= fetch1(IMG.FOV & key, 'imaging_frame_rate');
            end
            
            % Will affect the baseline estimation for delfta/F calculation. Will require more fine adjustment for different frame rates
            if frame_rate>10
                smooth_window_multiply_factor =5;
            else
                smooth_window_multiply_factor =1;
            end
            
            
            %Graphics
            %---------------------------------
            figure;
            set(gcf,'DefaultAxesFontName','helvetica');
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
            set(gcf,'PaperOrientation','portrait');
            set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
            set(gcf,'color',[1 1 1]);
            
            
            
            
            key_ROITrace=fetch(IMG.ROI&key,'ORDER BY roi_number');
            
            key_mean_dff = key_ROITrace;
            key_mean_f = key_ROITrace;
            
            Fall=cell2mat(fetchn(IMG.ROITrace &key,'f_trace','ORDER BY roi_number'));
            Fall_neuropil=cell2mat(fetchn(IMG.ROITraceNeuropil &key,'f_trace','ORDER BY roi_number'));
            
            
            Fall =Fall - neuropil_substraction_factor*Fall_neuropil; % Neuropil subtraction
            
            
            for iROI=1:1:size(Fall,1)
                iROI;
                F=Fall(iROI,:);
                Fs=smoothdata(F,'gaussian',running_window*smooth_window_multiply_factor); % for baseline estimation only
                
                running_min=movmin(Fs,[running_window*frame_rate running_window*frame_rate],'Endpoints','fill');
                baseline=movmax(running_min,[running_window*frame_rate running_window*frame_rate],'Endpoints','fill'); %running max of the running min
                baseline2=smoothdata(baseline,'gaussian',running_window*frame_rate);
                dFF = (F-baseline2)./baseline2; %deltaF over F
                
                
                k2=key_ROITrace(iROI);
                k2.dff_trace = dFF;
                k2.session_epoch_type = key.session_epoch_type;
                k2.session_epoch_number = key.session_epoch_number;
                
                insert(self,k2);
                
                
                %save every 1 in 100 rois
                if mod(iROI,100)==0
                    subplot(3,1,1)
                    hold on
                    plot(Fall(iROI,:),'g')
                    plot(Fall_neuropil(iROI,:),'b')
                    xlabel('Frames')
                    ylabel('F')
                    legend({'F', 'Neuropil','Corrected'});
                    title(sprintf('anm %d %s s%d %s ROI = %d',key.subject_id,session_date,key.session,key.session_epoch_type, iROI));
                    
                    subplot(3,1,2)
                    hold on
                    plot(Fall(iROI,:) - neuropil_substraction_factor*Fall_neuropil(iROI,:),'k')
                    title(sprintf('F, Neuropil subtracted, factor = %.2f',neuropil_substraction_factor));
                    xlabel('Frames')
                    ylabel('F')
                    
                    subplot(3,1,3)
                    hold on
                    plot(dFF,'k')
                    title(sprintf('dFF, Neuropil subtracted, factor = %.2f',neuropil_substraction_factor));
                    xlabel('Frames')
                    ylabel('dFF')
                    
                    
                    filename=['roi' num2str(iROI) '_epoch' num2str(key.session_epoch_number)];
                    figure_name_out=[ dir_current_fig filename];
                    eval(['print ', figure_name_out, ' -dtiff  -r50']);
                    clf
                end
            end
                        close all;
        end
    end
end