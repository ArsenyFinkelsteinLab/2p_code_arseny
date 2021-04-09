%{
#
-> EXP2.SessionEpoch
-> IMG.ROI
threshold_for_event             : double      # threshold in deltaf_overf
num_svd_components_removed      : int         # how many of the first svd components were removed
n_clust                         : int         #
---
heirar_cluster_id               : int         # cluster to which this cell belongs. Note that this id is not unique, because clustering is done independently for different combinations of the primary keys, and the cluster_id would change accordingly
heirar_cluster_percent          : double      # percentage of cells belonging to this cluster
%}

classdef ROIClusterCorrSVD < dj.Computed
    properties
        
        keySource = (EXP2.SessionEpoch & IMG.ROIdeltaF & IMG.Mesoscope) - EXP2.SessionEpochSomatotopy;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            rel_ROI = (IMG.ROI - IMG.ROIBad) & key;
            rel_data1 = IMG.ROIdeltaF & rel_ROI & key;
            
            time_bin=1.5; %s
            %             threshold_for_event_vector = [0, 0.25];
            threshold_for_event_vector = [0];
            %             num_svd_components_removed_vector = [0, 1, 10];
            num_svd_components_removed_vector = [0, 1,5, 10];
            

            dir_base =fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_save_figure_original = [dir_base 'Lick2D\Clusters\CorrSVD\'];
            n_clust_vector = [20, 100];
%                         n_clust_vector = [100];

            clusterparam.metric='correlation'; %euclidean or correlation
            
            clusterparam.agregate_clusters_flag = 0; %itiratively agregate clusters smaller than min_cluster_percent by merging them to clusters with higest correlation to them
            
            clusterparam.corr_thresh_across_clusters_for_merging = 0.8; %won't merge clusters that has correlation value below that
            clusterparam.corr_thresh_within_cluster_origin = 0.8; %won't merge clusters that has correlation value below that
            clusterparam.corr_thresh_within_cluster_target = 0.8;
            
            imaging_frame_rate = fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
            
            
            %% Loading Data
            key_ROIs= fetch(rel_ROI, 'ORDER BY roi_number');
            roi_list=fetchn(rel_ROI,'roi_number','ORDER BY roi_number');
            
            chunk_size=500;
            counter=0;
            for i_chunk=1:chunk_size:roi_list(end)
                roi_interval = [i_chunk, i_chunk+chunk_size];
                try
                    temp_F=cell2mat(fetchn(rel_data1 & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'dff_trace','ORDER BY roi_number'));
                catch
                    temp_F=cell2mat(fetchn(rel_data1 & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'spikes_trace','ORDER BY roi_number'));
                end
                temp_count=(counter+1):1: (counter + size(temp_F,1));
                Fall(temp_count,:)=temp_F;
                counter = counter + size(temp_F,1);
            end
            
            
%             chunk_size=500;
%             for i_chunk=1:chunk_size:numel(roi_list)
%                 roi_interval = [i_chunk, i_chunk+chunk_size];
%                 if roi_interval(end)>numel(roi_list)
%                     roi_interval(end) = numel(roi_list)+1;
%                 end
%                 temp_Fall=cell2mat(fetchn(IMG.ROIdeltaF & rel_ROI & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'dff_trace','ORDER BY roi_number'));
%                 temp_roi_num=fetchn(IMG.ROIdeltaF & rel_ROI & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'roi_number','ORDER BY roi_number');
%                 Fall(temp_roi_num,:)=temp_Fall;
%             end
            
            
            %% binning in time
            bin_size_in_frame=ceil(time_bin*imaging_frame_rate);
            
            bins_vector=1:bin_size_in_frame:size(Fall,2);
            bins_vector=bins_vector(2:1:end);
            for  i= 1:1:numel(bins_vector)
                ix1=(bins_vector(i)-bin_size_in_frame):1:(bins_vector(i)-1);
                F(:,i)=mean(Fall(:,ix1),2);
            end
            clear Fall temp_Fall
            
            
            %% Thresholding activity and computing SVD and correlations
            for i_th = 1:1:numel(threshold_for_event_vector)
                threshold= threshold_for_event_vector(i_th);
                for i_c = 1:1:numel(num_svd_components_removed_vector)
                    
                    dir_save_figure = [dir_save_figure_original sprintf('Threshold%.2f\\SVD%d\\',threshold,num_svd_components_removed_vector(i_c))];
                    
                    %% We take neurons with enough events during spont + behav session combined
                    %                     if threshold==0
                    % %                         idx_enough_events=ones(size(F,1),1);
                    %                     else
                    
                    %                         kkk=key;
                    %                         kkk.session_epoch_type='spont_only';
                    %                         kkk.threshold_for_event=threshold;
                    %                         epoch_spont_duration = fetchn(IMG.SessionEpochFrame & kkk, 'session_epoch_end_frame');
                    %                         events_spont = fetchn((IMG.ROIdeltaFPeak-EXP2.SessionEpochSomatotopy) & kkk, 'number_of_events','ORDER BY roi_number');
                    %
                    %
                    %                         kkk=key;
                    %                         kkk.session_epoch_type='behav_only';
                    %                         kkk.threshold_for_event=threshold;
                    %                         epoch_behav_duration = fetchn(IMG.SessionEpochFrame & kkk, 'session_epoch_end_frame');
                    %                         events_behav = fetchn((IMG.ROIdeltaFPeak-EXP2.SessionEpochSomatotopy) & kkk, 'number_of_events','ORDER BY roi_number');
                    %
                    %                         if isempty(events_behav)
                    %                             events=events_spont;
                    %                             duration = epoch_spont_duration;
                    %                         elseif isempty(events_spont)
                    %                             events=events_behav;
                    %                             duration = epoch_behav_duration;
                    %                         else
                    %                             events = events_behav + events_spont;
                    %                             duration = epoch_spont_duration + epoch_behav_duration;
                    %                         end
                    %                         duration_hours=(duration/imaging_frame_rate)/3600;
                    %                         idx_enough_events = events>=(duration_hours*min_num_events);
                    %                     end
                    
                    F_thresholded=F;
                    if threshold>0
                        F_thresholded(F<=threshold)=0;
                    end
                    %                     F_thresholded = F_thresholded(idx_enough_events,:);
                    
                    F_thresholded = gpuArray((F_thresholded));
                    if num_svd_components_removed_vector(i_c)>0
                        
                        num_comp = num_svd_components_removed_vector(i_c);
                        %                         F_thresholded = F_thresholded-mean(F_thresholded,2);
                        F_thresholded=zscore(F_thresholded,[],2);
                        
                        [U,S,V]=svd(F_thresholded); % S time X neurons; % U time X time;  V neurons x neurons
                        
                        singular_values =diag(S);
                        
                        %                         variance_explained=singular_values.^2/sum(singular_values.^2); % a feature of SVD. proportion of variance explained by each component
                        %                         cumulative_variance_explained=cumsum(variance_explained);
                        
                        U=U(:,(1+num_comp):end);
                        %             S=S(1:num_comp,1:num_comp);
                        V=V(:,(1+num_comp):end);
                        S = S((1+num_comp):end, (1+num_comp):end);
                        
                        
                        F_reconstruct = U*S*V';
                        clear U S V F_thresholded
                        %                         [rho,~]=corr(F_reconstruct');
                        try
                            rho=corrcoef(F_reconstruct');
                            rho=gather(rho);
                        catch
                            F_reconstruct=gather(F_reconstruct);
                            rho=corrcoef(F_reconstruct');
                        end
                    else
                        try
                            rho=corrcoef(F_thresholded');
                            rho=gather(rho);
                        catch
                            F_thresholded=gather(F_thresholded);
                            rho=corrcoef(F_thresholded');
                        end
                        
                        %                         [rho,~]=corr(F_thresholded');
                    end
                    
                    
                    
                    rho(isnan(rho))=0;
                    for in = 1:1:numel(n_clust_vector)
                        if in==1
                            flag_plot =1;
                        else
                            flag_plot =0;
                        end
                        
                        key.n_clust=n_clust_vector(in);
                        clusterparam.n_clust=n_clust_vector(in);
                        [cl_id, cluster_percent] = fn_ClusterROI_corr(rho, key, clusterparam, dir_save_figure, flag_plot);
                        k = key;
                        % Insert
                        for i=1:1:size(key_ROIs,1)
                            k(i).subject_id=key.subject_id;
                            k(i).session=key.session;
                            k(i).session_epoch_type=key.session_epoch_type;
                            k(i).session_epoch_number=key.session_epoch_number;
                            k(i).fov_num=key_ROIs(i).fov_num;
                            k(i).plane_num=key_ROIs(i).plane_num;
                            k(i).channel_num=key_ROIs(i).channel_num;
                            k(i).roi_number=key_ROIs(i).roi_number;
                            
                            k(i).threshold_for_event=threshold;
                            k(i).num_svd_components_removed=num_svd_components_removed_vector(i_c);
                            k(i).n_clust=n_clust_vector(in);
                            k(i).heirar_cluster_id = cl_id(i);
                            k(i).heirar_cluster_percent = cluster_percent(cl_id(i));
                            
                        end
                        insert(self,k);
                    end
                end
                
            end
        end
    end
end
