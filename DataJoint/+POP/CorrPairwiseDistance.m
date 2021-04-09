%{
# Pairwise correlation as a function of distance
-> EXP2.SessionEpoch
threshold_for_event        : double            # threshold in deltaf_overf
---
num_of_rois                : int               # number of rois analyzed
distance_corr_all          :blob               # average pairwise pearson coeff, binned  by percentiles according to lateral distance between neurons
distance_corr_positive     :blob               # average positive pairwise pearson coeff, binned by percentiles according to lateral distance between neurons
distance_corr_negative     :blob               # average negative pairwise pearson coeff, binned by percentiles according to lateral distance between neurons
distance_bins              :blob
distance_corr_all_fixed_bins          :blob         # same as above but binned in fixed bins, e.g. [0:25:1000]
distance_corr_positive_fixed_bins     :blob         #
distance_corr_negative_fixed_bins     :blob         #
distance_bins_fixed_bins    :blob


%}


classdef CorrPairwiseDistance < dj.Computed
    properties
        keySource = ((EXP2.SessionEpoch  & IMG.ROI & IMG.ROIdeltaF & IMG.Mesoscope) - EXP2.SessionEpochSomatotopy) ;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            close all;
            %Graphics
            %---------------------------------
            figure;
            set(gcf,'DefaultAxesFontName','helvetica');
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
            set(gcf,'PaperOrientation','portrait');
            set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
            set(gcf,'color',[1 1 1]);
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_save_fig = [dir_base  '\POP\corr_distance\'];
            
            threshold_for_event_vector = [0, 0.25, 0.5, 1, 2];
            min_num_events = 20; %per hour
            imaging_frame_rate = fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
            
            x_all=fetchn(IMG.ROI &key,'roi_centroid_x','ORDER BY roi_number');
            y_all=fetchn(IMG.ROI &key,'roi_centroid_y','ORDER BY roi_number');
            z_all=fetchn(IMG.ROI*IMG.PlaneCoordinates & key,'z_pos_relative','ORDER BY roi_number');
            
            x_pos_relative=fetchn(IMG.ROI*IMG.PlaneCoordinates &key,'x_pos_relative','ORDER BY roi_number');
            y_pos_relative=fetchn(IMG.ROI*IMG.PlaneCoordinates &key,'y_pos_relative','ORDER BY roi_number');
            
            x_all = x_all + x_pos_relative; x_all = x_all/0.75;
            y_all = y_all + y_pos_relative; y_all = x_all/0.5;
            
            
            
            dXY=zeros(numel(x_all),numel(x_all));
            d3D=zeros(numel(x_all),numel(x_all));
            parfor iROI=1:1:numel(x_all)
                x=x_all(iROI);
                y=y_all(iROI);
                z=z_all(iROI);
                dXY(iROI,:)= sqrt((x_all-x).^2 + (y_all-y).^2); % in um
                d3D(iROI,:) = sqrt((x_all-x).^2 + (y_all-y).^2 + (z_all-z).^2); % in um
            end
            
            
            
            roi_list=fetchn(IMG.ROIdeltaF &key,'roi_number','ORDER BY roi_number');
            chunk_size=500;
            for i_chunk=1:chunk_size:numel(roi_list)
                roi_interval = [i_chunk, i_chunk+chunk_size];
                if roi_interval(end)>numel(roi_list)
                    roi_interval(end) = numel(roi_list)+1;
                end
                temp_Fall=cell2mat(fetchn(IMG.ROIdeltaF & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'dff_trace','ORDER BY roi_number'));
                temp_roi_num=fetchn(IMG.ROIdeltaF & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'roi_number','ORDER BY roi_number');
                Fall(temp_roi_num,:)=temp_Fall;
            end
            
            duration_hours=(size(temp_Fall,2)/imaging_frame_rate)/3600;
            
            for i_th = 1:1:numel(threshold_for_event_vector)
                threshold= threshold_for_event_vector(i_th);
                Fall_thresholded=Fall;
                Fall_thresholded(Fall<=threshold)=0;
                idx_enough_events = sum(Fall_thresholded>0,2)>=(duration_hours*min_num_events);
                [rho,~]=corr(Fall_thresholded(idx_enough_events,:)');
                %                 rho(isnan(rho(:)))=0;
                
                key.num_of_rois=sum(idx_enough_events);
                key.threshold_for_event = threshold;
                
                flag_fixed_bins=0;
                kk=fn_POP_bin_pairwise_corr_by_distance(key, rho, dXY(idx_enough_events,idx_enough_events), threshold_for_event_vector, i_th, flag_fixed_bins);
                
                flag_fixed_bins=1;
                kk=fn_POP_bin_pairwise_corr_by_distance(kk, rho, dXY(idx_enough_events,idx_enough_events), threshold_for_event_vector, i_th, flag_fixed_bins);
                
                insert(self,kk);
            end
            
            session_date = fetch1(EXP2.Session & key,'session_date');
            session_epoch_type = fetch1(EXP2.SessionEpoch & key, 'session_epoch_type');
            if strcmp(session_epoch_type,'spont_only')
                session_epoch_label = 'Spontaneous';
            elseif strcmp(session_epoch_type,'behav_only')
                session_epoch_label = 'Behavior';
            end
            
            filename = ['anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date '_' session_epoch_label num2str(key.session_epoch_number)];
            if isempty(dir(dir_save_fig))
                mkdir (dir_save_fig)
            end
            %
            figure_name_out=[ dir_save_fig filename];
            eval(['print ', figure_name_out, ' -dtiff  -r150']);
            % eval(['print ', figure_name_out, ' -dpdf -r200']);
            
            
            
        end
    end
end
 